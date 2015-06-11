/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/freedom-typings/freedom-common.d.ts' />
/// <reference path='../../../third_party/freedom-typings/udp-socket.d.ts' />
/// <reference path='../../../third_party/ipaddrjs/ipaddrjs.d.ts' />

// TODO(ldixon): reorganize the utransformers and rename uproxy-obfuscators.
// Ideal:
//  import Transformer = require('uproxy-obfuscators/transformer');
// Current:
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />


// TODO(ldixon): re-enable FTE and regex2dfa. But this time, start with a pre-
// computed set of DFAs because the regex2dfa.js library is 4MB in size. Also
// experiment with uglify and zip to see if that size drops significantly.
//
// import regex2dfa = require('regex2dfa');

import arraybuffers = require('../arraybuffers/arraybuffers');
import churn_pipe_types = require('../churn-pipe/freedom-module.interface');
import churn_types = require('./churn.types');
import handler = require('../handler/queue');
import ipaddr = require('ipaddr.js');
import logging = require('../logging/logging');
import net = require('../net/net.types');
import peerconnection = require('../webrtc/peerconnection');
import random = require('../crypto/random');
import signals = require('../webrtc/signals');

import ChurnSignallingMessage = churn_types.ChurnSignallingMessage;
import ChurnPipe = churn_pipe_types.freedom_ChurnPipe;

var log :logging.Log = new logging.Log('churn');

  export var filterCandidatesFromSdp = (sdp:string) : string => {
    return sdp.split('\n').filter((s) => {
      return s.indexOf('a=candidate') != 0;
    }).join('\n');
  }

  var splitCandidateLine_ = (candidate:string) : string[] => {
    var lines = candidate.split(' ');
    if (lines.length < 8 || lines[6] != 'typ') {
      throw new Error('cannot parse candidate line: ' + candidate);
    }
    return lines;
  }

  var splitHostCandidateLine_ = (candidate:string) : string[] => {
    var lines = splitCandidateLine_(candidate)
    var typ = lines[7];
    if (typ != 'host') {
      throw new Error('not a host candidate line: ' + candidate);
    }
    return lines;
  }

  export var extractEndpointFromCandidateLine = (
      candidate:string) : net.Endpoint => {
    var lines = splitHostCandidateLine_(candidate);
    var address = lines[4];
    var port = parseInt(lines[5]);
    if (port != port) {
      // Check for NaN.
      throw new Error('invalid port in candidate line: ' + candidate);
    }
    return {
      address: address,
      port: port
    };
  }

  export var setCandidateLineEndpoint = (
      candidate:string, endpoint:net.Endpoint) : string => {
    var lines = splitHostCandidateLine_(candidate);
    lines[4] = endpoint.address;
    lines[5] = endpoint.port.toString();
    return lines.join(' ');
  }

  export interface NatPair {
    internal: net.Endpoint;
    external: net.Endpoint;
  }

  // This function implements a heuristic to select the single candidate
  // that is most likely to work for this connection.  The heuristic
  // expresses a preference ordering:
  // Most preferred: public IP address bound as a host candidate
  //  - rare outside of servers, but offers the very best connectivity
  // Next best: server-reflexive IP address
  //  - most common
  // Worst: private IP address in a host candidate
  //  - indicates that STUN has failed.  Connection is still possible
  //    if the other side is directly routable.
  // If none of these are present, the function will throw an exception.
  // TODO: Allow selecting more than one public address.  This would help
  // when there are multiple interfaces or IPv6 and IPv4.
  export var selectPublicAddress =
      (candidates:freedom_RTCPeerConnection.RTCIceCandidate[])
      : NatPair => {
    // TODO: Note that we cannot currently support IPv6 addresses:
    //         https://github.com/uProxy/uproxy/issues/1107
    var publicHostCandidates :net.Endpoint[] = [];
    var srflxCandidates :NatPair[] = [];
    var privateHostCandidates :net.Endpoint[] = [];
    for (var i = 0; i < candidates.length; ++i) {
      var line = candidates[i].candidate;
      var tokens = splitCandidateLine_(line);
      if (tokens[2].toLowerCase() != 'udp') {
        // Skip non-UDP candidates
        continue;
      }
      var typ = tokens[7];
      if (typ === 'srflx') {
        var srflxAddress = tokens[4];
        if (ipaddr.process(srflxAddress).kind() === 'ipv6') {
          continue;
        }
        var port = parseInt(tokens[5]);
        if (tokens[8] != 'raddr') {
          throw new Error('no raddr in candidate line: ' + line);
        }
        var raddr = tokens[9];
        if (ipaddr.process(raddr).kind() === 'ipv6') {
          continue;
        }
        if (tokens[10] != 'rport') {
          throw new Error('no rport in candidate line: ' + line);
        }
        var rport = parseInt(tokens[11]);
        srflxCandidates.push({
          external: {
            address: srflxAddress,
            port: port
          },
          internal: {
            address: raddr,
            port: rport
          }
        });
      } else if (typ === 'host') {
        var hostAddress = ipaddr.process(tokens[4]);
        // Store the host address in case no srflx candidates are found.
        if (hostAddress.kind() !== 'ipv6') {
          var endpoint :net.Endpoint = {
            address: tokens[4],
            port: parseInt(tokens[5])
          };
          if (hostAddress.range() === 'unicast') {
            publicHostCandidates.push(endpoint);
          } else {
            privateHostCandidates.push(endpoint);
          }
        }
      }
    }
    if (publicHostCandidates.length > 0) {
      return {
        internal: publicHostCandidates[0],
        external: publicHostCandidates[0]
      }
    } else if (srflxCandidates.length > 0) {
      return srflxCandidates[0];
    } else if (privateHostCandidates.length > 0) {
      return {
        internal: privateHostCandidates[0],
        external: privateHostCandidates[0]
      }
    }
    throw new Error('no srflx or host candidate found');
  };

  // Generates a key suitable for use with CaesarCipher, viz. 1-255.
  var generateCaesarKey_ = (): number => {
    try {
      return (random.randomUint32() % 255) + 1;
    } catch (e) {
      // https://github.com/uProxy/uproxy/issues/1593
      log.warn('crypto unavailable, using Math.random');
      return Math.floor((Math.random() * 255)) + 1;
    }
  }

  /**
   * A uproxypeerconnection-like Freedom module which establishes obfuscated
   * connections.
   *
   * DTLS packets are intercepted by pointing WebRTC at a local "forwarding"
   * port; connectivity to the remote host is achieved with the help of
   * another preceding, short-lived, peer-to-peer connection.
   *
   * This is mostly a thin wrapper over uproxypeerconnection except for the
   * magic required during setup.
   *
   * Right now, CaesarCipher is used with a key which is randomly generated
   * each time a new connection is negotiated.
   *
   * TODO: Give the uproxypeerconnections name, to help debugging.
   * TODO: Allow obfuscation parameters be configured.
   */
  export class Connection implements peerconnection.PeerConnection<ChurnSignallingMessage> {

    public peerOpenedChannelQueue :handler.QueueHandler<peerconnection.DataChannel, void>;
    public signalForPeerQueue :handler.Queue<ChurnSignallingMessage, void>;
    public peerName :string;

    public onceConnected :Promise<void>;
    public onceClosed :Promise<void>;

    // A short-lived connection used to determine network addresses on which
    // we might be able to communicate with the remote host.
    private probeConnection_
        :peerconnection.PeerConnection<signals.Message>;

    // The list of all candidates returned by the probe connection.
    private probeCandidates_ :freedom_RTCPeerConnection.RTCIceCandidate[] = [];

    // Fulfills once we have collected all candidates from the probe connection.
    private probingComplete_ :(endpoints:NatPair) => void;
    private onceProbingComplete_ = new Promise((F, R) => {
      this.probingComplete_ = F;
    });

    // The obfuscated connection.
    private obfuscatedConnection_
        :peerconnection.PeerConnection<signals.Message>;

    // Fulfills once we know on which port the local obfuscated RTCPeerConnection
    // is listening.
    private haveWebRtcEndpoint_ :(endpoint:net.Endpoint) => void;
    private onceHaveWebRtcEndpoint_ = new Promise((F, R) => {
      this.haveWebRtcEndpoint_ = F;
    });

    // Fulfills once we know on which port the remote CHURN pipe is listening.
    private haveRemoteEndpoint_ :(endpoint:net.Endpoint) => void;
    private onceHaveRemoteEndpoint_ = new Promise((F, R) => {
      this.haveRemoteEndpoint_ = F;
    });

    // Fulfills once we've successfully allocated the mirror pipe representing the
    // remote peer's signalled transport address.
    // At that point, we can inject its address into candidate messages destined
    // for the local RTCPeerConnection.
    private haveForwardingSocketEndpoint_ :(endpoint:net.Endpoint) => void;
    private onceHaveForwardingSocketEndpoint_ = new Promise((F, R) => {
      this.haveForwardingSocketEndpoint_ = F;
    });

    // Fulfills once we know the obfuscation key for caesar cipher.
    private haveCaesarKey_ :(key:number) => void;
    private onceHaveCaesarKey_ = new Promise((F, R) => {
      this.haveCaesarKey_ = F;
    });

    private pipe_ :ChurnPipe;

    private static internalConnectionId_ = 0;

    constructor(probeRtcPc:freedom_RTCPeerConnection.RTCPeerConnection,
                peerName?:string) {
      this.peerName = peerName || 'churn-connection-' +
          (++Connection.internalConnectionId_);

      this.signalForPeerQueue = new handler.Queue<ChurnSignallingMessage,void>();

      // Configure the probe connection.  Once it completes, inform the remote
      // peer which public endpoint we will be using.
      this.onceProbingComplete_.then((endpoints:NatPair) => {
        this.signalForPeerQueue.handle({
          publicEndpoint: endpoints.external
        });
      });

      // Start the obfuscated connection.
      this.configureObfuscatedConnection_();

      // Once the obfuscated connection's local endpoint is known, the remote
      // peer has sent us its public endpoint, and probing is complete, we can
      // configure the obfuscating pipe and allow traffic to flow.
      this.configureProbeConnection_(probeRtcPc);
      Promise.all([this.onceHaveWebRtcEndpoint_,
                   this.onceHaveRemoteEndpoint_,
                   this.onceProbingComplete_,
                   this.onceHaveCaesarKey_]).then((answers:any[]) => {
        this.configurePipe_(answers[0], answers[1], answers[2], answers[3]);
      });

      // Forward onceXxx promises.
      this.onceConnected = this.obfuscatedConnection_.onceConnected;
      this.onceClosed = this.obfuscatedConnection_.onceClosed;

      // Debugging.
      this.onceProbingComplete_.then((endpoint:NatPair) => {
        log.debug('%1: NAT endpoints of probe connection are %2',
          this.peerName, endpoint);
      });
      this.onceHaveWebRtcEndpoint_.then((endpoint:net.Endpoint) => {
        log.debug('%1: obfuscated connection is bound to %2',
          this.peerName, endpoint);
      });
      this.onceHaveRemoteEndpoint_.then((endpoint:net.Endpoint) => {
        log.debug('%1: remote peer is contactable at %2',
          this.peerName, endpoint);
      });
      this.onceHaveForwardingSocketEndpoint_.then((endpoint: net.Endpoint) => {
        log.debug('%1: forwarding socket is at %2',
          this.peerName, endpoint);
      });
      this.onceHaveCaesarKey_.then((key: number) => {
        log.info('%1: caesar key is %2', this.peerName, key);
      });
    }

    private configureProbeConnection_ = (
        freedomPc:freedom_RTCPeerConnection.RTCPeerConnection) => {
      var probePeerName = this.peerName + '-probe';
      this.probeConnection_ = new peerconnection.PeerConnectionClass(
          freedomPc, probePeerName);
      this.probeConnection_.signalForPeerQueue.setSyncHandler(
          (message:signals.Message) => {
        if (message.type === signals.Type.CANDIDATE) {
          this.probeCandidates_.push(message.candidate);
        } else if (message.type === signals.Type.NO_MORE_CANDIDATES) {
          this.probeConnection_.close().then(() => {
            this.probingComplete_(selectPublicAddress(this.probeCandidates_));
          });
        }
      });
      this.probeConnection_.negotiateConnection();
    }

    private configurePipe_ = (
        webRtcEndpoint:net.Endpoint,
        remoteEndpoint:net.Endpoint,
        natEndpoints:NatPair,
        key:number) : void => {
      this.pipe_ = freedom['churnPipe']();
      this.pipe_.setTransformer('caesar',
          new Uint8Array([key]).buffer,
          '{}');
      // TODO(ldixon): renable FTE support instead of caesar cipher.
      //     'fte',
      //     arraybuffers.stringToArrayBuffer('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'),
      //     JSON.stringify({
      //       'plaintext_dfa': regex2dfa('^.*$'),
      //       'plaintext_max_len': 1400,
      //       // This is equivalent to Rabbit cipher.
      //       'ciphertext_dfa': regex2dfa('^.*$'),
      //       'ciphertext_max_len': 1450
      //     }
      this.pipe_.bindLocal(natEndpoints.internal).then(() => {
        return this.pipe_.setBrowserEndpoint(webRtcEndpoint);
      }).then(() => {
        this.pipe_.bindRemote(remoteEndpoint).then((e: net.Endpoint) => {
          log.info('%1: initial mirror socket for remote peer at %2 on %3',
              this.peerName, remoteEndpoint, e);
          this.haveForwardingSocketEndpoint_(e);
        });
      });
    }

    private configureObfuscatedConnection_ = () => {
      // We use an empty configuration to ensure that no STUN servers are pinged.
      var obfConfig :freedom_RTCPeerConnection.RTCConfiguration = {
        iceServers: []
      };
      var obfPeerName = this.peerName + '-obfuscated';
      var freedomPc = freedom['core.rtcpeerconnection'](obfConfig);
      this.obfuscatedConnection_ = new peerconnection.PeerConnectionClass(
          freedomPc, obfPeerName);
      this.obfuscatedConnection_.signalForPeerQueue.setSyncHandler(
          (message:signals.Message) => {
        if (message.type === signals.Type.OFFER ||
            message.type === signals.Type.ANSWER) {
          // Super-paranoid check: remove candidates from SDP messages.
          // This can happen if a connection is re-negotiated.
          // TODO: We can safely remove this once we can reliably interrogate
          //       peerconnection endpoints.
          message.description.sdp =
              filterCandidatesFromSdp(message.description.sdp);
          var churnSignal :ChurnSignallingMessage = {
            webrtcMessage: message
          };
          this.signalForPeerQueue.handle(churnSignal);
        } else if (message.type === signals.Type.CANDIDATE) {
          // This will tell us on which port webrtc is operating.
          // There's no need to send this to the peer because it can
          // trivially formulate a candidate line with the address of
          // its pipe.
          try {
            if (!message.candidate || !message.candidate.candidate) {
              throw new Error('no candidate line');
            }
            var address = extractEndpointFromCandidateLine(
                message.candidate.candidate);
            // TODO: We cannot currently support IPv6 addresses:
            //         https://github.com/uProxy/uproxy/issues/1107
            if (ipaddr.process(address.address).kind() === 'ipv6') {
              throw new Error('ipv6 unsupported');
            }
            this.haveWebRtcEndpoint_(address);
          } catch (e) {
            log.debug('%1: ignoring candidate line %2: %3',
                this.peerName,
                JSON.stringify(message),
                e.message);
          }
        }
      });
      this.peerOpenedChannelQueue =
          this.obfuscatedConnection_.peerOpenedChannelQueue;
    }

    public negotiateConnection = () : Promise<void> => {
      // Generate a key and send it to the remote party.
      // Once they've received it, they'll be able to establish
      // a matching pipe.
      var key = generateCaesarKey_();
      this.haveCaesarKey_(key);
      this.signalForPeerQueue.handle({
        caesar: key
      });
      return this.obfuscatedConnection_.negotiateConnection();
    }

    // Forward the message to the relevant stage: churn-pipe or obfuscated.
    // In the case of obfuscated signalling channel messages, we inject our
    // local forwarding socket's endpoint.
    public handleSignalMessage = (
        churnMessage:ChurnSignallingMessage) : void => {
      if (churnMessage.publicEndpoint !== undefined) {
        this.haveRemoteEndpoint_(churnMessage.publicEndpoint);
      }
      if (churnMessage.caesar !== undefined) {
        this.haveCaesarKey_(churnMessage.caesar);
      }
      if (churnMessage.webrtcMessage) {
        var message = churnMessage.webrtcMessage;
        if (message.type == signals.Type.OFFER ||
            message.type == signals.Type.ANSWER) {
          // Remove candidates from the SDP.  This is redundant, but ensures
          // that a bug in the remote client won't cause us to send
          // unobfuscated traffic.
          message.description.sdp = filterCandidatesFromSdp(
              message.description.sdp);
          this.obfuscatedConnection_.handleSignalMessage(message);

          // Send a candidate to the peerconnection.
          // Its address is the socket on which the pipe is listening.
          this.onceHaveForwardingSocketEndpoint_.then(
              (forwardingSocketEndpoint:net.Endpoint) => {
            this.obfuscatedConnection_.handleSignalMessage({
              type: 2,
              candidate: {
                candidate: setCandidateLineEndpoint(
                    'candidate:0 1 UDP 2130379007 0.0.0.0 0 typ host',
                    forwardingSocketEndpoint),
                sdpMid: '',
                sdpMLineIndex: 0
              }
            });
          });
        }
      }
    }

    public openDataChannel = (channelLabel:string,
        options?:freedom_RTCPeerConnection.RTCDataChannelInit)
        : Promise<peerconnection.DataChannel> => {
      return this.obfuscatedConnection_.openDataChannel(channelLabel);
    }

    public close = () : Promise<void> => {
      return this.obfuscatedConnection_.close();
    }

    public toString = () : string => {
      return this.obfuscatedConnection_.toString();
    };
  }
