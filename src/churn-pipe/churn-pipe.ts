/// <reference path='../../../third_party/ipaddrjs/ipaddrjs.d.ts' />
/// <reference path='../../../third_party/freedom-typings/freedom-common.d.ts' />
/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/freedom-typings/udp-socket.d.ts' />

// TODO(ldixon): reorganize the utransformers and rename uproxy-obfuscators.
// Ideal:
//  import Transformer = require('uproxy-obfuscators/transformer');
//  import Rabbit = require('uproxy-obfuscators/rabbit.transformer');
//  import Fte = require('uproxy-obfuscators/fte.transformer');
// Current:
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

// import Rabbit = require('utransformers/src/transformers/uTransformers.fte');
// import Fte = require('utransformers/src/transformers/uTransformers.rabbit');

import PassThrough = require('../simple-transformers/passthrough');
import CaesarCipher = require('../simple-transformers/caesar');

import logging = require('../logging/logging');

import net = require('../net/net.types');
import ipaddr = require('ipaddr.js');

import Socket = freedom_UdpSocket.Socket;

var log :logging.Log = new logging.Log('churn-pipe');

// Retry an async function with exponential backoff for up to 2 seconds
// before failing.
var retry_ = <T>(func:() => Promise<T>, delayMs?:number) : Promise<T> => {
  delayMs = delayMs || 10;
  return func().catch((err) => {
    delayMs *= 2;
    if (delayMs > 2000) {
      return Promise.reject(err);
    }
    return new Promise<T>((F, R) => {
      setTimeout(() => {
        retry_(func, delayMs).then(F, R);
      }, delayMs);
    });
  });
}

var makeTransformer_ = (
    // Name of transformer to use, e.g. 'rabbit' or 'none'.
    name :string,
    // Key for transformer, if any.
    key ?:ArrayBuffer,
    // JSON-encoded configuration, if any.
    config ?:string)
  : Transformer => {
  var transformer :Transformer;
  // TODO(ldixon): re-enable rabbit and FTE once we can figure out why they
  // don't load in freedom.
  /* if (name == 'rabbit') {
     transformer = Rabbit.Transformer();
     } else if (name == 'fte') {
     transformer = Fte.Transformer();
     } else */ if (name == 'caesar') {
       transformer = new CaesarCipher();
     } else if (name == 'none') {
       transformer = new PassThrough();
     } else {
       throw new Error('unknown transformer: ' + name);
     }
  if (key) {
    transformer.setKey(key);
  }
  if (config) {
    transformer.configure(config);
  }
  return transformer;
}

interface MirrorSet {
  // If true, these mirrors represent a remote endpoint that has been
  // explicitly signaled to us.
  signaled: boolean;

  // This array may be transiently sparse for signaled mirrors, and
  // persistently sparse for non-signaled mirrors (i.e. peer-reflexive).
  // Taking its length is therefore likely to be unhelpful.
  sockets: Promise<Socket>[];
}

/**
 * A Churn Pipe is a transparent obfuscator/deobfuscator for transforming the
 * apparent type of browser-generated UDP datagrams.
 *
 * This implementation makes the simplifying assumption that the browser only
 * allocates one endpoint per interface.  Relaxing this assumption would allow
 * us to achieve the same performance while allocating fewer ports, at the cost
 * of slightly more complex logic.
 */
class Pipe {

  // For each physical network interface, this provides a list of the open
  // public sockets on that interface.  Each socket corresponds to a port that
  // is intended to be publicly routable (possibly thanks to NAT), and is
  // used only for sending and receiving obfuscated traffic with the remote
  // endpoints.
  private publicSockets_ :{ [address:string]: Socket[] } = {};

  // Promises to track the progress of binding any public port.  This is used
  // to return the appropriate Promise when there is a redundant call to
  // |bindLocal|.
  private publicPorts_ : { [address:string]: { [port:number]: Promise<void> } } =
      {};

  // The maximum number of bound remote ports on any single interface.  This is
  // also the number of mirror sockets that are needed for each signaled remote
  // port.
  private maxSocketsPerInterface_ :number = 0;

  // Each mirror socket is bound to a port on localhost, and corresponds to a
  // specific remote endpoint.  When the public socket receives an obfuscated
  // packet from that remote endpoint, the mirror socket sends the
  // corresponding deobfuscated message to the browser endpoint.  Similarly,
  // when a mirror socket receives a (unobfuscated) message from the browser
  // endpoint, the public socket sends the corresponding obfuscated packet to
  // that mirror socket's remote endpoint.
  private mirrorSockets_ : { [address:string]: { [port:number]: MirrorSet } } =
      {};

  // Obfuscates and deobfuscates messages.
  private transformer_ :Transformer = makeTransformer_('none');

  // Endpoint to which incoming obfuscated messages are forwarded on each
  // interface.  The key is the interface, and the value is the port.
  // This requires the simplifying assumption that the browser allocates at
  // most one port on each interface.
  private browserEndpoints_ : { [address:string]: number } = {};

  // TODO: define a type for event dispatcher in freedom-typescript-api
  constructor (private dispatchEvent_:(name:string, args:Object) => void) {
  }

  // Set the current transformer parameters.  The default is no transformation.
  public setTransformer = (
      transformerName :string,
      key ?:ArrayBuffer,
      config ?:string) : Promise<void> => {
    try {
      this.transformer_ = makeTransformer_(transformerName, key, config);
      return Promise.resolve<void>();
    } catch (e) {
      return Promise.reject(e);
    }
  }

  /**
   * Returns a promise to create a socket, bind to the specified address, and
   * start listening for datagrams, which will be deobfuscated and forwarded to the
   * browser endpoint.
   */
  // TODO: Clarify naming between bindLocal (binds local public obfuscated
  // candidate) and bindRemote (set up private local bindings to allow
  // sending to that remote candidate).
  public bindLocal = (publicEndpoint:net.Endpoint) :Promise<void> => {
    if (!this.publicPorts_[publicEndpoint.address]) {
      this.publicPorts_[publicEndpoint.address] = {};
    }
    var portPromise =
        this.publicPorts_[publicEndpoint.address][publicEndpoint.port];
    if (portPromise) {
      log.debug('Redundant public endpoint: %1', publicEndpoint);
      return portPromise;
    }

    log.debug('Binding public endpoint: %1', publicEndpoint);
    var socket = freedom['core.udpsocket']();
    var index = this.addPublicSocket_(socket, publicEndpoint);
    // Firefox only supports binding to ANY and localhost, so bind to ANY.
    // TODO: Figure out how to behave correctly when we are instructed
    // to bind the same port on two different interfaces.  Currently, this
    // code will bind the port twice, probably duplicating all incoming
    // packets (but this is not verified).
    var anyInterface = Pipe.anyInterface_(publicEndpoint.address);
    // This retry is needed because the browser releases the UDP port
    // asynchronously after we call close() on the RTCPeerConnection, so
    // this call to bind() may initially fail, until the port is released.
    portPromise = retry_(() => {
      return socket.bind(anyInterface, publicEndpoint.port).
          then((resultCode:number) => {
        if (resultCode != 0) {
          return Promise.reject(new Error(
            'bindLocal failed with result code ' + resultCode));
        }
      });
    }).then(() => {
      socket.on('onData', (recvFromInfo:freedom_UdpSocket.RecvFromInfo) => {
        this.onIncomingData_(recvFromInfo, publicEndpoint.address, index);
      });
    });
    
    this.publicPorts_[publicEndpoint.address][publicEndpoint.port] = portPromise;
    return portPromise;
  }

  // Given a socket, and the endpoint to which it is bound, this function adds
  // the endpoint to the set of sockets for that interface, performs any
  // updates necessary to make the new socket functional, and returns an index
  // that identifies the socket within its interface.
  private addPublicSocket_ = (socket:Socket, endpoint:net.Endpoint)
      : number => {
    if (!(endpoint.address in this.publicSockets_)) {
      this.publicSockets_[endpoint.address] = [];
    }
    this.publicSockets_[endpoint.address].push(socket);
    if (this.publicSockets_[endpoint.address].length >
        this.maxSocketsPerInterface_) {
      this.increaseReplication_();
    }
    return this.publicSockets_[endpoint.address].length - 1;
  }

  // Some interface has broken the record for the number of bound local sockets.
  // Add another mirror socket for every signaled remote candidate, to represent
  // the routes through this newly bound local socket.
  private increaseReplication_ = () => {
    for (var remoteAddress in this.mirrorSockets_) {
      for (var port in this.mirrorSockets_[remoteAddress]) {
        var mirrorSet = this.mirrorSockets_[remoteAddress][port];
        if (mirrorSet.signaled) {
          var endpoint :net.Endpoint = {
            address: remoteAddress,
            port: port
          };
          this.getMirrorSocket_(endpoint, this.maxSocketsPerInterface_).
              then((socket) => {
            this.emitMirror_(endpoint, socket)
          });
        }
      }
    }
    ++this.maxSocketsPerInterface_;
  }

  // A new mirror port has been allocated for a signaled remote endpoint. Report
  // it to the client.
  private emitMirror_ = (remoteEndpoint:net.Endpoint, socket:Socket) => {
    socket.getInfo().then(Pipe.endpointFromInfo_).then((localEndpoint) => {
      log.debug('Emitting mirror for %1: %2', remoteEndpoint, localEndpoint);
      this.dispatchEvent_('mappingAdded', {
        local: localEndpoint,
        remote: remoteEndpoint
      });
    });
  }

  // Informs this module about the existence of a browser endpoint.
  public addBrowserEndpoint = (browserEndpoint:net.Endpoint) :Promise<void> => {
    log.debug('Adding browser endpoint: %1', browserEndpoint);
    if (this.browserEndpoints_[browserEndpoint.address]) {
      log.warn('Port %1 is already open on this interface',
          this.browserEndpoints_[browserEndpoint.address])
    }
    this.browserEndpoints_[browserEndpoint.address] = browserEndpoint.port;
    return Promise.resolve<void>();
  }

  // Establishes an empty data structure to hold mirror sockets for this remote
  // endpoint, if necessary.  If |signaled| is true, the structure will be
  // marked as signaled, whether or not it already existed.
  private ensureRemoteEndpoint_ = (endpoint:net.Endpoint, signaled:boolean)
      : MirrorSet => {
    if (!(endpoint.address in this.mirrorSockets_)) {
      this.mirrorSockets_[endpoint.address] = {};
    }
    if (!(endpoint.port in this.mirrorSockets_[endpoint.address])) {
      this.mirrorSockets_[endpoint.address][endpoint.port] = {
        signaled: false,
        sockets: []
      };
    }
    if (signaled) {
      this.mirrorSockets_[endpoint.address][endpoint.port].signaled = true;
    }
    return this.mirrorSockets_[endpoint.address][endpoint.port];
  }

  /**
   * Given an endpoint from which obfuscated datagrams may arrive, this method
   * constructs a corresponding mirror socket, and returns its endpoint.
   */
  public bindRemote = (remoteEndpoint:net.Endpoint) : Promise<void> => {
    this.ensureRemoteEndpoint_(remoteEndpoint, true);
    var promises :any[] = [];
    for (var i = 0; i < this.maxSocketsPerInterface_; ++i) {
      promises.push(this.getMirrorSocket_(remoteEndpoint, i).then((socket) => {
        this.emitMirror_(remoteEndpoint, socket);
      }));
    }
    return Promise.all(promises).then((fulfills:any[]) : void => {});
  }

  private static anyInterface_ = (address:string) => {
    return ipaddr.IPv6.isValid(address) ? '::' : '0.0.0.0';
  }

  private getMirrorSocket_ = (remoteEndpoint:net.Endpoint, index:number)
      : Promise<Socket> => {
    var mirrorSet = this.ensureRemoteEndpoint_(remoteEndpoint, false);
    var socketPromise :Promise<Socket> = mirrorSet.sockets[index];
    if (socketPromise) {
      return socketPromise;
    }

    var mirrorSocket = freedom['core.udpsocket']();
     mirrorSocket;
    // Bind to INADDR_ANY owing to restrictions on localhost candidates
    // in Firefox:
    //   https://github.com/uProxy/uproxy/issues/1597
    // TODO: bind to an actual, non-localhost address (see the issue)
    var anyInterface = Pipe.anyInterface_(remoteEndpoint.address);
    socketPromise = mirrorSocket.bind(anyInterface, 0).then((resultCode:number)
        : Socket => {
      if (resultCode != 0) {
        throw new Error('bindRemote failed with result code ' + resultCode);
      }
      mirrorSocket.on('onData', (recvFromInfo:freedom_UdpSocket.RecvFromInfo) => {
        // Ignore packets that do not originate from the browser, for a
        // theoretical security benefit.
        if (recvFromInfo.port !==
            this.browserEndpoints_[recvFromInfo.address]) {
          log.warn('mirror socket for %1 ignoring incoming packet from %2 ' +
              'which should have had source port %3',
              remoteEndpoint, {
                address: recvFromInfo.address,
                port: recvFromInfo.port
              },
              this.browserEndpoints_[recvFromInfo.address]);
        } else {
          var publicSocket = this.publicSockets_[recvFromInfo.address] &&
              this.publicSockets_[recvFromInfo.address][index];
          // Public socket may be null, especially if the index is too great.
          // Drop the packet in that case.
          if (publicSocket) {
            this.sendTo_(publicSocket, recvFromInfo.data, remoteEndpoint);
          }
        }
      });
      return mirrorSocket;
    });
    mirrorSet.sockets[index] = socketPromise;
    return socketPromise;
  }

  private static endpointFromInfo_ = (socketInfo:freedom_UdpSocket.SocketInfo) => {
    if (!socketInfo.localAddress) {
      throw new Error('Cannot process incomplete info: ' +
          JSON.stringify(socketInfo));
    }
    // freedom-for-firefox currently reports the bound address as 'localhost',
    // which is unsupported in candidate lines by Firefox:
    //   https://github.com/freedomjs/freedom-for-firefox/issues/62
    // This will result in |fakeLocalAddress| being IPv4 localhost, so this
    // issue is blocking IPv6 Churn support on Firefox.
    var fakeLocalAddress = ipaddr.IPv6.isValid(socketInfo.localAddress) ?
        '::1' : '127.0.0.1';
    return {
      address: fakeLocalAddress,
      port: socketInfo.localPort
    };
  }

  /**
   * Sends a message over the network to the specified destination.
   * The message is obfuscated before it hits the wire.
   */
  private sendTo_ = (publicSocket:Socket, buffer:ArrayBuffer, to:net.Endpoint)
      : void => {
    var transformedBuffer = this.transformer_.transform(buffer);
    publicSocket.sendTo.reckless(
      transformedBuffer,
      to.address,
      to.port);
  }

  /**
   * Called when a message is received over the network from the remote side.
   * The message is de-obfuscated before being passed to the browser endpoint
   * via a corresponding mirror socket.
   */
  private onIncomingData_ = (recvFromInfo:freedom_UdpSocket.RecvFromInfo,
      iface:string, index:number) => {
    var browserPort = this.browserEndpoints_[iface];
    if (!browserPort) {
      // There's no browser port for this interface, so drop the packet.
      return;
    }
    var transformedBuffer = recvFromInfo.data;
    var buffer = this.transformer_.restore(transformedBuffer);
    this.getMirrorSocket_(recvFromInfo, index).then((mirrorSocket:Socket) => {
      mirrorSocket.sendTo.reckless(
          buffer,
          iface,
          browserPort);
    });
  }

  public on = (name:string, listener:(event:any) => void) : void => {
    throw new Error('Placeholder function to keep Typescript happy');
  }
}

export = Pipe;
