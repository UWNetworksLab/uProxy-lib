
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
class PacketLengthNormalizer extends PacketLengthShaper implements Transformer {
  /** Length to which packets should be normalized. */
  private targetLength_ :number;

  public constructor() {
    super();
    log.info('Constructed packet length normalizer');
  }

  /** Get the target length. */
  public configure = (json:string) : void => {
    this.superConfigure(json);

    var dict = JSON.parse(json);
    this.setTargetLength_(dict['targetLength']);
    log.info('Configured packet length normalizer %1', this.targetLength_);
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
//    log.info('Transforming');
    return this.shapePacketLength(buffer, this.targetLength_);
  }

  /**
   * Packet length normalizer requires just one parameter: the target length to
   * which packets should be normalized. target should be a number in the range
   * 1-1500 inclusive. All packets will be normalized to this length.
   */
  private setTargetLength_ = (target:number) : void => {
    if (target < 1 || target > 1500) {
      throw new Error('target packet length must be in the range 1-1500');
    }
    this.targetLength_ = target;
  }
}

export = PacketLengthNormalizer;
