
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import arraybuffers = require('../arraybuffers/arraybuffers');
import arithmetic = require('./arithmetic');

var log :logging.Log = new logging.Log('fancy-transformers');

// TODO(bwiley): Convert /* */ to // as specified in the style guide

export interface CompressionConfig {frequencies: number[]}

/**
 * An obfuscator that injects byte sequences.
 */
export class CompressionShaper implements Transformer {
  private frequencies_ : number[];
  private encoder_ : arithmetic.Encoder;
  private decoder_ : arithmetic.Decoder;

  public constructor() {
    log.info('Constructed compression shaper');
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
    if('frequencies' in config) {
      log.debug('typcasting');
      var compressionConfig=<CompressionConfig>config;
      log.debug('typecasted');
      this.frequencies_=compressionConfig.frequencies;
      this.encoder_=new arithmetic.Encoder(this.frequencies_);
      this.decoder_=new arithmetic.Decoder(this.frequencies_);
    } else {
      log.error('Bad JSON config file');
      log.error(json);
      throw new Error("Compression shaper requires frequencies parameter");
    }
  }

  public configure = (json:string) : void => {
    log.debug("Configuring configuration shaper");

    try {
      this.superConfigure(json);
    } catch(err) {
      log.error("Config crashed");
    }

    log.debug("Configured configuration shaper");
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
//    buffer=arraybuffers.stringToArrayBuffer('\x00\x01\x02\x03');
    log.debug('encoding %1', arraybuffers.arrayBufferToHexString(buffer));
    var encoded=this.encoder_.encode(buffer);
    log.debug('final encoded %1', arraybuffers.arrayBufferToHexString(encoded));
    return [encoded];
  }

  public restore = (buffer:ArrayBuffer) : ArrayBuffer[] => {
    var decoded=this.decoder_.decode(buffer);
    log.debug('final decoded %1', arraybuffers.arrayBufferToHexString(decoded));
    log.debug('--------------------------------------------------------------');
    return [decoded];
  }

  // No-op (we have no state or any resources to dispose).
  public dispose = () : void => {}
}
