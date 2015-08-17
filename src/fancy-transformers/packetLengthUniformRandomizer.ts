
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import PacketLengthShaper = require('./packetLengthShaper');

var log :logging.Log = new logging.Log('fancy-transformers');

// An obfuscator that only modifies packet length.
// The packet length is randomized according to a uniform distribution.
class PacketLengthUniformRandomizer extends PacketLengthShaper implements Transformer {
  // Length to which packets should be normalized
  private targetMinimum_ :number;
  private targetMaximum_ :number;

  public constructor() {
    super();
    log.info('Constructed packet length uniform randomizer');
  }

  // Get the target minimum and maximum lengths.
  public configure = (json:string) : void => {
    this.superConfigure(json);

    var dict = JSON.parse(json);
    this.setTargetMinimum_(dict['targetMinimum']);
    this.setTargetMaximum_(dict['targetMaximum']);
    log.info('Configured packet length normalizer %1 %2', this.targetMinimum_, this.targetMaximum_);
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
//    log.info('Transforming');
    return this.shapePacketLength(buffer, this.nextTargetLength());
  }

  private setTargetMinimum_ = (minimum:number) : void => {
    if(minimum>=37) {
      this.targetMinimum_=minimum;
    } else {
      throw new Error('Target packet length is too small');
    }
  }

  private setTargetMaximum_ = (maximum:number) : void => {
    if(maximum<=1440) {
      this.targetMaximum_=maximum;
    } else {
      throw new Error('Target packet length is too large');
    }
  }

  // Generates a random number from 1-1440 inclusive
  private nextTargetLength = () : number => {
    return Math.floor(Math.random()*(this.targetMaximum_-this.targetMinimum_)+this.targetMinimum_);
  }
}

export = PacketLengthUniformRandomizer;
