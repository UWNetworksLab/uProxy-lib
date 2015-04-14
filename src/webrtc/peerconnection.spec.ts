/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/typings/jasmine/jasmine.d.ts' />
/// <reference path="../../../third_party/freedom-typings/rtcpeerconnection.d.ts" />

import MockFreedomRtcDataChannel =
  require('../freedom/mocks/mock-rtcdatachannel');
import MockFreedomRtcPeerConnection =
  require('../freedom/mocks/mock-rtcpeerconnection');
import RTCPeerConnection = freedom_RTCPeerConnection.RTCPeerConnection;
import RTCDataChannelInit = freedom_RTCPeerConnection.RTCDataChannelInit;

import freedomMocker = require('../freedom/mocks/mock-freedom-in-module-env');
freedom = freedomMocker.makeMockFreedomInModuleEnv({
  'rtcdatachannel': () => { return new MockFreedomRtcDataChannel(); }
});

import signals = require('./signals');
import peerconnection = require('./peerconnection');
import datachannel = require('./datachannel');

describe('PeerConnection', function() {
  var mockRtcPeerConnection :MockFreedomRtcPeerConnection;

  beforeEach(function() {
    mockRtcPeerConnection = new MockFreedomRtcPeerConnection();
  });

  // Check that early onmessage events are received and processed.
  it('early onmessage works', (done) => {
    var rtcDc :MockFreedomRtcDataChannel;
    var onSpy :any;
    freedom['core.rtcdatachannel'] = <any>((id:string) => {
      expect(id).toEqual('theChannelId');
      rtcDc = new MockFreedomRtcDataChannel();
      onSpy = spyOn(rtcDc, 'on').and.callThrough();
      return rtcDc;
    });
    var pc = new peerconnection.PeerConnectionClass(
        mockRtcPeerConnection, 'test');
    mockRtcPeerConnection.handleEvent('ondatachannel', {channel: 'theChannelId'});
    expect(rtcDc).not.toBeUndefined();

    // The data channel message event listener should be registered synchronously
    // after receiving the ondatachannel event.
    expect(onSpy).toHaveBeenCalledWith('onmessage', jasmine.any(Function));

    // Mock synchronously emit onmessage immediately after ondatachannel.
    rtcDc.handleEvent('onmessage', {text: 'foo'});
    
    pc.peerOpenedChannelQueue.setSyncNextHandler((dc:datachannel.DataChannel) => {
      dc.dataFromPeerQueue.setSyncNextHandler((data:datachannel.Data) => {
        expect(data.str).toEqual('foo');
        done();
      });
    });
  });

  // Ensure that ICE candidate gathering, which is initiated by a call to
  // |setLocalDescription|, is not initiated prior to sending the OFFER signal:
  //   https://github.com/uProxy/uproxy/issues/784
  it('Candidate gathering should not start before offer signal is sent',
      (done) => {
    // When |mockRtcPeerConnection.createDataChannel| is called (happens when
    // calling |pc.negotiateConnection| below), we make a fake
    // 'onnegotiationneeded' event. This will cause
    // |mockRtcPeerConnection.createOffer| to be called. We also resolve with a
    // fake channel id for the created channel.
    var createDataChannelSpy =
      spyOn(mockRtcPeerConnection, 'createDataChannel');
    createDataChannelSpy.and.callFake((
          label:string, init:RTCDataChannelInit) => {
      mockRtcPeerConnection.handleEvent('onnegotiationneeded');
      return Promise.resolve('foo-channel-id');
    });

    // Make |createOffer| resolve to a mock offer.
    var createOfferSpy = spyOn(mockRtcPeerConnection, 'createOffer');
    var mockOffer :freedom_RTCPeerConnection.RTCSessionDescription = {
      type: 'sdp',
      sdp: 'mock:sdp'
    };
    createOfferSpy.and.returnValue(Promise.resolve(mockOffer));

    // We mock setLocalDescription, because we want to check that it has not
    // been called by the time the first signalling message is added to the
    // handler queue.
    var setLocalDescriptionSpy =
      spyOn(mockRtcPeerConnection, 'setLocalDescription');

    var pc = new peerconnection.PeerConnectionClass(
        mockRtcPeerConnection, 'test');
    pc.negotiateConnection();

    pc.signalForPeerQueue.setSyncNextHandler(
        (message:signals.Message) => {
      expect(message.type).toEqual(signals.Type.OFFER);
      expect(mockRtcPeerConnection.setLocalDescription).not.toHaveBeenCalled();
      done();
    });

  });
});
