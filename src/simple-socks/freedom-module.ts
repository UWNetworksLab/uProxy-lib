/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/typings/freedom/freedom-module-env.d.ts' />

import arraybuffers = require('../arraybuffers/arraybuffers');
import bridge = require('../bridge/bridge');
import churn_types = require('../churn/churn.types');
import encryption = require('../fancy-transformers/encryptionShaper');
import logging = require('../logging/logging');
import loggingTypes = require('../loggingprovider/loggingprovider.types');
import net = require('../net/net.types');
import protean = require('../fancy-transformers/protean');
import rtc_to_net = require('../rtc-to-net/rtc-to-net');
import socks_to_rtc = require('../socks-to-rtc/socks-to-rtc');
import sequence = require('../fancy-transformers/byteSequenceShaper');
import tcp = require('../net/tcp');

const loggingController = freedom['loggingcontroller']();
loggingController.setDefaultFilter(loggingTypes.Destination.console,
                                   loggingTypes.Level.debug);

const log :logging.Log = new logging.Log('simple-socks');

const socksEndpoint:net.Endpoint = {
  address: '0.0.0.0',
  port: 9999
};

const pcConfig :freedom.RTCPeerConnection.RTCConfiguration = {
  iceServers: [{urls: ['stun:stun.l.google.com:19302']},
               {urls: ['stun:stun.services.mozilla.com']}]
};

export const socksToRtc = new socks_to_rtc.SocksToRtc();
export const rtcToNet = new rtc_to_net.RtcToNet();

rtcToNet.start({
  allowNonUnicast: true
}, bridge.best('rtctonet', pcConfig)).then(() => {
  log.info('RtcToNet ready');
}, (e:Error) => {
  log.error('failed to start RtcToNet: %1', e.message);
});

// Must do this after calling start.
rtcToNet.signalsForPeer.setSyncHandler(socksToRtc.handleSignalFromPeer);

// Must do this before calling start.
socksToRtc.on('signalForPeer', rtcToNet.handleSignalFromPeer);


// We are going to inject a fake packet at the very
// start of the stream. It will be between 200 and 1000
// bytes in length with a randomly generated ASCII header
// between 4 and 8 characters in length.
// TODO: don't use Math.random
let headerLength = 4 + Math.floor(Math.random() * 5);
let headerBytes = new Uint8Array(headerLength);
crypto.getRandomValues(headerBytes);
for (let i = 0; i < headerLength; i++) {
  headerBytes[i] = 65 + (headerBytes[i] % 27); // 'A' in ASCII
}
var headerHex = arraybuffers.arrayBufferToHexString(headerBytes.buffer);

var transformerConfig = <churn_types.TransformerConfig>{
  name: 'protean',
  config: JSON.stringify(<protean.ProteanConfig>{
    encryption: <encryption.EncryptionConfig>{
      key: arraybuffers.arrayBufferToHexString(
          crypto.getRandomValues(new Uint8Array(16)).buffer)
    },
    injection: <sequence.SequenceConfig>{
       addSequences: [{
         index: 0,
         length: 200 + Math.floor(Math.random() * 800),
         offset: 0,
         sequence: headerHex
       }],
       removeSequences: []
    }
  })
};

log.info('obfuscation config: %1', transformerConfig);

socksToRtc.start(new tcp.Server(socksEndpoint),
    bridge.best('sockstortc',
                pcConfig,
                undefined,
                transformerConfig)).then((endpoint:net.Endpoint) => {
  log.info('SocksToRtc listening on %1', endpoint);
  log.info('curl -x socks5h://%1:%2 www.example.com',
      endpoint.address, endpoint.port);
}, (e:Error) => {
  log.error('failed to start SocksToRtc: %1', e.message);
});
