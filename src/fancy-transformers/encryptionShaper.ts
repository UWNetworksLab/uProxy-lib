
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import arraybuffers = require('../arraybuffers/arraybuffers');
import aes = require('./aes');

var log :logging.Log = new logging.Log('fancy-transformers');

export interface EncryptionConfig {key:ArrayBuffer}
export interface SerializedEncryptionConfig {key:string}

// An obfuscator that encrypts the packets with AES CBC.
export class EncryptionShaper implements Transformer {
  private key_ :ArrayBuffer;

  public constructor() {
    log.info('Constructed encryption shaper');
  }

  // This method is required to implement the Transformer API.
  // @param {ArrayBuffer} key Key to set, not used by this class.
  public setKey = (key:ArrayBuffer) :void => {
    // Do nothing.
  }

  // Get the target length.
  public superConfigure = (json:string) :void => {
    var config=JSON.parse(json);

    // Required parameter
    if('key' in config) {
      log.debug('typcasting');
      var encryptionConfig=this.deserializeConfig_(<SerializedEncryptionConfig>config);
      log.debug('typecasted');
      this.key_=encryptionConfig.key;
    } else {
      log.error('Bad JSON config file');
      log.error(json);
      throw new Error("Encryption shaper requires key parameter");
    }
  }

  public configure = (json:string) :void => {
    log.debug("Configuring encryption shaper");

    try {
      this.superConfigure(json);
    } catch(err) {
      log.error("Config crashed");
    }

    log.debug("Configured encryption shaper");
  }

  public transform = (buffer:ArrayBuffer) :ArrayBuffer[] => {
    var iv :ArrayBuffer=this.makeIV_();
    var encrypted :ArrayBuffer=this.encrypt_(iv, buffer);
    var parts=[iv, encrypted]
    return [arraybuffers.assemble(parts)];
  }

  public restore = (buffer:ArrayBuffer) :ArrayBuffer[] => {
    var parts :ArrayBuffer[] = arraybuffers.split(buffer, 16);
    var iv=parts[0];
    var ciphertext=parts[1];
    return [this.decrypt_(iv, ciphertext)];
  }

  // No-op (we have no state or any resources to dispose).
  public dispose = () :void => {}

  private deserializeConfig_ = (config:SerializedEncryptionConfig) :EncryptionConfig => {
    return {key:arraybuffers.hexStringToArrayBuffer(config.key)};
  }

  private makeIV_ = () :ArrayBuffer => {
    return arraybuffers.randomBytes(16);
  }

  private encrypt_ = (iv:ArrayBuffer, buffer:ArrayBuffer) :ArrayBuffer => {
    var len :ArrayBuffer = arraybuffers.encodeShort(buffer.byteLength);
    var remainder = (len.byteLength + buffer.byteLength) % 16;
    var plaintext:ArrayBuffer;
    if (remainder === 0) {
      plaintext=arraybuffers.assemble([len, buffer]);
    } else {
      var padding :ArrayBuffer = arraybuffers.randomBytes(16-remainder);
      plaintext=arraybuffers.assemble([len, buffer, padding]);
    }

    var cbc :aes.ModeOfOperationCBC = new aes.ModeOfOperationCBC(this.key_, iv);
    var ciphertext=cbc.encrypt(plaintext);

    return ciphertext;
  }

  private decrypt_ = (iv:ArrayBuffer, ciphertext:ArrayBuffer) :ArrayBuffer => {
    var cbc :aes.ModeOfOperationCBC = new aes.ModeOfOperationCBC(this.key_, iv);
    var plaintext :ArrayBuffer = cbc.decrypt(ciphertext);

    var parts = arraybuffers.split(plaintext, 2);
    var lengthBytes = parts[0];
    var length = arraybuffers.decodeShort(lengthBytes);
    var rest = parts[1];
    if(rest.byteLength > length) {
      parts=arraybuffers.split(rest, length);
      return parts[0];
    } else {
      return rest;
    }
  }
}
