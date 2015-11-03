/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />
/// <reference path='../../../third_party/aes-js/aes-js.d.ts' />

import arraybuffers = require('../arraybuffers/arraybuffers');
import decompression = require('../fancy-transformers/decompressionShaper');
import encryption = require('../fancy-transformers/encryptionShaper');
import fragmentation = require('../fancy-transformers/fragmentationShaper');
import logging = require('../logging/logging');
import sequence = require('../fancy-transformers/byteSequenceShaper');

const log :logging.Log = new logging.Log('protean');

// Accepted in serialised form by configure().
export interface ProteanConfig {
  decompression ?:decompression.DecompressionConfig;
  encryption ?:encryption.EncryptionConfig;
  fragmentation ?:fragmentation.FragmentationConfig;
  injection ?:sequence.SequenceConfig
}

// Creates a sample (non-random) config, suitable for testing.
export function sampleConfig() :ProteanConfig {
  return {
    decompression: decompression.sampleConfig(),
    encryption: encryption.sampleConfig(),
    fragmentation: fragmentation.sampleConfig(),
    injection: sequence.sampleConfig()
  };
}

function flatMap<T,E>(input :Array<T>, mappedFunction :(element :T) => Array<E>) :Array<E> {
  return input.reduce((accumulator :Array<E>, item :T) :Array<E> => {
    return accumulator.concat(mappedFunction(item));
  }, []);
}

// A packet shaper that composes multiple transformers.
// The following transformers are composed:
// - Fragmentation based on MTU and chunk size
// - AES encryption
// - decompression using arithmetic coding
// - byte sequence injection
export class Protean implements Transformer {
  // Fragmentation transformer
  private fragmenter_ :fragmentation.FragmentationShaper;

  // Encryption transformer
  private encrypter_ :encryption.EncryptionShaper;

  // Decompression transformer
  private decompresser_ :decompression.DecompressionShaper;

  // Byte sequence injecter transformer
  private injecter_ :sequence.ByteSequenceShaper;

  public constructor() {
    this.configure(JSON.stringify(sampleConfig()));
  }

  // This method is required to implement the Transformer API.
  // @param {ArrayBuffer} key Key to set, not used by this class.
  public setKey = (key :ArrayBuffer) :void => {
    throw new Error('setKey unimplemented');
  }

  public configure = (json :string) :void => {
    let config = JSON.parse(json);

    let proteanConfig = <ProteanConfig>config;
    if ('decompression' in config) {
      this.decompresser_ = new decompression.DecompressionShaper();
      this.decompresser_.configure(JSON.stringify(proteanConfig.decompression));
    }
    if ('encryption' in config) {
      this.encrypter_ = new encryption.EncryptionShaper();
      this.encrypter_.configure(JSON.stringify(proteanConfig.encryption));
    }
    if ('fragmentation' in config) {
      this.fragmenter_ = new fragmentation.FragmentationShaper();
      this.fragmenter_.configure(JSON.stringify(proteanConfig.fragmentation));
    }
    if ('injection' in config) {
      this.injecter_ = new sequence.ByteSequenceShaper();
      this.injecter_.configure(JSON.stringify(proteanConfig.injection));
    }
  }

  // Apply the following transformations:
  // - Fragment based on MTU and chunk size
  // - Encrypt using AES
  // - Decompress using arithmetic coding
  // - Inject packets with byte sequences
  public transform = (buffer :ArrayBuffer) :ArrayBuffer[] => {
    let source = [buffer];
    if (this.fragmenter_) {
      source = flatMap(source, this.fragmenter_.transform);
    }
    if (this.encrypter_) {
      source = flatMap(source, this.encrypter_.transform);
    }
    if (this.decompresser_) {
      source = flatMap(source, this.decompresser_.transform);
    }
    if (this.injecter_) {
      source = flatMap(source, this.injecter_.transform);
    }
    return source;
  }

  // Apply the following transformations:
  // - Discard injected packets
  // - Decrypt with AES
  // - Compress with arithmetic coding
  // - Attempt defragmentation
  public restore = (buffer :ArrayBuffer) :ArrayBuffer[] => {
    let source = [buffer];
    if (this.injecter_) {
      source = flatMap(source, this.injecter_.restore);
    }
    if (this.decompresser_) {
      source = flatMap(source, this.decompresser_.restore);
    }
    if (this.encrypter_) {
      source = flatMap(source, this.encrypter_.restore);
    }
    if (this.fragmenter_) {
      source = flatMap(source, this.fragmenter_.restore);
    }
    return source;
  }

  // No-op (we have no state or any resources to dispose).
  public dispose = () :void => {}
}
