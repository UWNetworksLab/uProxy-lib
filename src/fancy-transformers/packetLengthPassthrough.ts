
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import PacketLengthShaper = require('./packetLengthShaper');

var log :logging.Log = new logging.Log('fancy-transformers');

// TODO(bwiley): Convert /* */ to // as specified in the style guide

/**
 * An obfuscator that only modifies packet length.
 * To start out, this is a very simple (and bad) packet length obfuscator.
 * It follows this logic:
 * Case 1 - buffer length + 2 == target: return length(buffer) + buffer
 * Case 2 - buffer length + 2 > target:  return length(target) + randomBytes(target)
 * Case 3 - buffer length + 2 < target:  return length(target) + buffer + randomBytes(target)
 */
class PacketLengthPassthrough extends PacketLengthShaper implements Transformer {
  public constructor() {
    super();
    log.info('Constructed packet length passthrough');
  }

  /** Get the target minimum and maximum lengths. */
  public configure = (json:string) : void => {
    this.superConfigure(json);
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
    log.info('Transforming');
    return this.shapePacketLength(buffer, buffer.byteLength+36);
  }
}

export = PacketLengthPassthrough;
