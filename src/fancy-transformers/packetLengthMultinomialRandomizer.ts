
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import PacketLengthShaper = require('./packetLengthShaper');

var log :logging.Log = new logging.Log('fancy-transformers');

// An obfuscator that only modifies packet length.
// The packet length is randomized according to a multinomial distribution.
class PacketLengthMultinomialRandomizer extends PacketLengthShaper implements Transformer {
  // Length to which packets should be normalized.
  private targetDistribution_ :Array<number>;

  public constructor() {
    super();
    log.info('Constructed packet length normalizer');
  }

  // Get the target distribution.
  public configure = (json:string) : void => {
    this.superConfigure(json);

    var data=JSON.parse(json);
    // TODO(bwiley): Throw error on missing distribution parameter
    this.targetDistribution_=data['distribution'];
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
//    log.info('Transforming');
    return this.shapePacketLength(buffer, this.nextTargetLength());
  }

  // Generates a random number from 1-1440 inclusive
  private nextTargetLength = () : number => {
    var random=Math.random();
    var index=0;
    while(index<this.targetDistribution_.length-1) {
      if(random>=this.targetDistribution_[index] &&
         random<this.targetDistribution_[index+1]) {
        break;
      } else {
        index=index+1;
      }
    }

    return index;
  }
}

export = PacketLengthMultinomialRandomizer;
