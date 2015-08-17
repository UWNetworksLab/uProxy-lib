
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import PacketLengthShaper = require('./packetLengthShaper');

var log :logging.Log = new logging.Log('fancy-transformers');

// An obfuscator that only modifies packet length.
// The packet length is shortened by 1 byte.
class PacketLengthShortener extends PacketLengthShaper implements Transformer {
  public constructor() {
    super();
    log.info('Constructed packet length shortener');
  }

  // Get the target minimum and maximum lengths.
  public configure = (json:string) : void => {
    this.superConfigure(json);
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
//    log.info('Transforming');
    var results=this.shapePacketLength(buffer, buffer.byteLength+35);
//    log.info('Sending %1 packets', results.length);
    return results;
  }
}

export = PacketLengthShortener;
