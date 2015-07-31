
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import arraybuffers = require('../arraybuffers/arraybuffers');

var log :logging.Log = new logging.Log('fancy-transformers');

// TODO(bwiley): Convert /* */ to // as specified in the style guide

export interface SerializedSequenceConfig {addSequences: SerializedSequenceModel[]; removeSequences: SerializedSequenceModel[]}
export interface SerializedSequenceModel {index: number; offset: number; sequence: string; length: number}

export interface SequenceConfig {addSequences: SequenceModel[]; removeSequences: SequenceModel[]}
export interface SequenceModel {index: number; offset: number; sequence: ArrayBuffer; length: number}

/**
 * An obfuscator that injects byte sequences.
 */
export class ByteSequenceShaper implements Transformer {
  private addSequences_ : SequenceModel[];
  private removeSequences_ : SequenceModel[];
  private firstIndex_ : number;
  private lastIndex_ : number;
  private indices_ : number[]=[];
  private outputIndex_ : number=0;

  public constructor() {
    log.info('Constructed byte sequence shaper');
  }

  /**
   * This method is required to implement the Transformer API.
   * @param {ArrayBuffer} key Key to set, not used by this class.
   */
  public setKey = (key:ArrayBuffer) : void => {
    /* Do nothing. */
  }

  /** Get the target length. */
  public superConfigure = (json:string) : void => {
    var config=JSON.parse(json);

    // Required parameter
    if('sequences' in config) {
      log.debug('typcasting');
      var sequenceConfig=this.deserializeConfig_(<SerializedSequenceConfig>config.sequences);
      log.debug('typecasted');
      this.addSequences_=sequenceConfig.addSequences;
      this.removeSequences_=sequenceConfig.removeSequences;
      this.firstIndex_=this.addSequences_[0].index;
      this.lastIndex_=this.addSequences_[this.addSequences_.length-1].index;
      for (var i = 0; i < this.addSequences_.length; i++) {
        this.indices_.push(this.addSequences_[i].index);
      }
      log.debug('done');
    } else {
      log.error('Bad JSON config file');
      log.error(json);
      throw new Error("Byte sequence shaper requires sequences parameter");
    }
  }

  public configure = (json:string) : void => {
    log.debug("Configuring byte sequence shaper");

    try {
      this.superConfigure(json);
    } catch(err) {
      log.error("Config crashed");
    }

    log.debug("Configured byte sequence shaper");
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
    log.info('Transforming byte sequence');
    if((this.outputIndex_ <= this.lastIndex_) && (this.outputIndex_ >= this.firstIndex_)) {
      var results : ArrayBuffer[]=[];

      // Inject fake packets before the real packet
      var nextPacket=this.findNextPacket_(this.outputIndex_);
      while(nextPacket!=null) {
        results.push(this.makePacket_(nextPacket));
        this.outputIndex_=this.outputIndex_+1;
        nextPacket=this.findNextPacket_(this.outputIndex_);
      }

      // Inject the real packet
      results.push(buffer);

      //Inject fake packets after the real packet
      nextPacket=this.findNextPacket_(this.outputIndex_);
      while(nextPacket!=null) {
        results.push(this.makePacket_(nextPacket));
        this.outputIndex_=this.outputIndex_+1;
        nextPacket=this.findNextPacket_(this.outputIndex_);
      }

      return results;
    } else {
      this.outputIndex_=this.outputIndex_+1;
      return [buffer];
    }
  }

  public restore = (buffer:ArrayBuffer) : ArrayBuffer[] => {
    var match=this.findMatchingPacket_(buffer);
    if(match!=null) {
      return [];
    } else {
      return [buffer];
    }
  }

  // No-op (we have no state or any resources to dispose).
  public dispose = () : void => {}

  private deserializeConfig_ = (config:SerializedSequenceConfig) : SequenceConfig => {
    var adds : SequenceModel[]=[];
    var rems : SequenceModel[]=[];

    for(var i=0; i<config.addSequences.length; i++) {
      adds.push(this.deserializeModel_(config.addSequences[i]));
    }

    for(var i=0; i<config.removeSequences.length; i++) {
      rems.push(this.deserializeModel_(config.removeSequences[i]));
    }

    return {addSequences: adds, removeSequences: rems};
  }

  private deserializeModel_ = (model:SerializedSequenceModel) : SequenceModel => {
    return {index: model.index, offset: model.offset,
      sequence: arraybuffers.hexStringToArrayBuffer(model.sequence),
      length: model.length
    }
  }

  private findNextPacket_ = (index:number) => {
    for(var i=0; i<this.addSequences_.length; i++) {
      if(index==this.addSequences_[i].index) {
        return this.addSequences_[i];
      }
    }

    return null;
  }

  private findMatchingPacket_ = (sequence:ArrayBuffer) => {
    for(var i=0; i<this.removeSequences_.length; i++) {
      if(sequence==this.removeSequences_[i].sequence) {
        return this.removeSequences_.splice(i, 1);
      }
    }

    return null;
  }

  private makePacket_ = (model:SequenceModel) : ArrayBuffer => {
    var parts : ArrayBuffer[]=[];
    if(model.offset>0) {
      var length=model.offset;
      parts.push(arraybuffers.randomBytes(length));
    }

    parts.push(model.sequence);

    if(model.offset<1440) {
      length=1440-model.offset;
      parts.push(arraybuffers.randomBytes(length));
    }

    return arraybuffers.assemble(parts);
  }
}
