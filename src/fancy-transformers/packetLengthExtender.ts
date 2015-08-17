
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import PacketLengthShaper = require('./packetLengthShaper');

var log :logging.Log = new logging.Log('fancy-transformers');

// An obfuscator that only modifies packet length.
// The packet length is extended by 1 byte.
class PacketLengthExtender extends PacketLengthShaper implements Transformer {
  public constructor() {
    super();
    log.info('Constructed packet length extender');
  }

  // Get the target minimum and maximum lengths.
  public configure = (json:string) :void => {
    this.superConfigure(json);
  }

  public transform = (buffer:ArrayBuffer) :ArrayBuffer[] => {
    log.info('Transforming');
    return this.shapePacketLength(buffer, buffer.byteLength+37);
  }
}

export = PacketLengthExtender;
