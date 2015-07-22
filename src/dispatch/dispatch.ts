/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />

// This module provides a dispatcher for handling new data channels
// created from a peer.  Clients register a regex with closure that
// takes a peerconnection.DataChannel.  If the data channel's name
// matches that regex, that closure will be invoked with the channel.
// Regexs are tried in registration order, until one matches.  Only
// one closure will be invoked per incoming data channel.  Unmatched
// data channels will be logged and immediately closed.

import logging = require('../logging/logging');
import peerconnection = require('../webrtc/peerconnection');

var log :logging.Log = new logging.Log('Dispatch');

class DispatchEntry {
  public pattern: RegExp;
  public closure: (dc:peerconnection.DataChannel) => void;
  constructor(p:string, c:(dc:peerconnection.DataChannel)=>void) {
    this.pattern = new RegExp(p);
    this.closure = c;
  }
}
export class Dispatch {
  private entries_ :DispatchEntry[] = [];

  public constructor(private name_:string,
                     pc:peerconnection.PeerConnection<Object>) {
    pc.peerOpenedChannelQueue.setHandler(this.dispatch);
  }

  public register = (pattern: string,
                     closure: (dc:peerconnection.DataChannel)=>void) => {
    var entry = new DispatchEntry(pattern, closure);
    console.log("register(" + pattern + ", lambda()): adding to list of "
                + this.entries_.length + " elements.");
    this.entries_.push(entry);
  }

  public dispatch = (chan:peerconnection.DataChannel) => {
    var name = chan.getLabel();
    console.log("dispatch: checking label " + name);
    for (var d in this.entries_) {
      console.log("dispatch: checking against regex " + d.pattern.toString());
      if (d.pattern.test(name)) {
        console.log("dispatch: found it.");
        return Promise.resolve(d.closure(chan));
      }
    }
    console.log(this.name_+ ": Failed ot find dispatcher for channel with name " + name);
    log.error(this.name_ + ": Failed to find a dispatcher for channel with " +
              "label " + name);
    return Promise.resolve();
  }
};