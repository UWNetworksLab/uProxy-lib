/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />
/// <reference path='../../../third_party/aes-js/aes-js.d.ts' />

import arraybuffers = require('../arraybuffers/arraybuffers');
import decompression = require('../fancy-transformers/decompressionShaper');
import encryption = require('../fancy-transformers/encryptionShaper');
import fragmentation = require('../fancy-transformers/fragmentationShaper');
import logging = require('../logging/logging');
import sequence = require('../fancy-transformers/byteSequenceShaper');
import header = require('../fancy-transformers/headerShaper');

const log :logging.Log = new logging.Log('protean');

// Accepted in serialised form by configure().
export interface ProteanConfig {
  decompression ?:decompression.DecompressionConfig;
  encryption ?:encryption.EncryptionConfig;
  fragmentation ?:fragmentation.FragmentationConfig;
  injection?: sequence.SequenceConfig;
  headerInjection?: header.HeaderConfig;
}

// Creates a sample (non-random) config, suitable for testing.
export function sampleConfig() :ProteanConfig {
  return {
    decompression: decompression.sampleConfig(),
    encryption: encryption.sampleConfig(),
    fragmentation: fragmentation.sampleConfig(),
    injection: sequence.sampleConfig(),
    headerInjection: header.sampleConfig()
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

  // Byte sequence injecter transformer
  private headerInjecter_ :header.HeaderShaper;

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
    } else {
      this.decompresser_ = undefined;
    }
    if ('encryption' in config) {
      this.encrypter_ = new encryption.EncryptionShaper();
      this.encrypter_.configure(JSON.stringify(proteanConfig.encryption));
    } else {
      this.encrypter_ = undefined;
    }
    if ('fragmentation' in config) {
      this.fragmenter_ = new fragmentation.FragmentationShaper();
      this.fragmenter_.configure(JSON.stringify(proteanConfig.fragmentation));
    } else {
      this.fragmenter_ = undefined;
    }
    if ('injection' in config) {
      this.injecter_ = new sequence.ByteSequenceShaper();
      this.injecter_.configure(JSON.stringify(proteanConfig.injection));
    } else {
      this.injecter_ = undefined;
    }
    if ('headerInjection' in config) {
      this.headerInjecter_ = new header.HeaderShaper();
      this.headerInjecter_.configure(JSON.stringify(proteanConfig.headerInjection));
    } else {
      this.headerInjecter_ = undefined;
    }
  }

  // Apply the following transformations:
  // - Fragment based on MTU and chunk size
  // - Encrypt using AES
  // - Decompress using arithmetic coding
  // - Inject headers into packets
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
    if (this.headerInjecter_) {
      source = flatMap(source, this.headerInjecter_.transform);
    }
    return source;
  }

  // Apply the following transformations:
  // - Discard injected packets
  // - Discard injected headers
  // - Decrypt with AES
  // - Compress with arithmetic coding
  // - Attempt defragmentation
  public restore = (buffer :ArrayBuffer) :ArrayBuffer[] => {
    let source = [buffer];
    if (this.headerInjecter_) {
      source = flatMap(source, this.headerInjecter_.restore);
    }
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
