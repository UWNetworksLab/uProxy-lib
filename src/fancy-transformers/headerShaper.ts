/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import arraybuffers = require('../arraybuffers/arraybuffers');
import logging = require('../logging/logging');
import random = require('../crypto/random');

const log :logging.Log = new logging.Log('fancy-transformers');

// Accepted in serialised form by configure().
export interface HeaderConfig {
  // Header that should be added to the beginning of each outgoing packet.
  addHeader :SerializedHeaderModel;

  // Header that should be removed from each incoming packet.
  removeHeader :SerializedHeaderModel
}

// Header models where the headers have been encoded as strings.
// This is used by the HeaderConfig argument passed to configure().
export interface SerializedHeaderModel {
  // Header encoded as a string.
  header :string;
}

// Header models where the headers have been decoded as ArrayBuffers.
// This is used internally by the HeaderShaper.
export interface HeaderModel {
  // Header.
  header :ArrayBuffer;
}

// Creates a sample (non-random) config, suitable for testing.
export var sampleConfig = () : HeaderConfig => {
  var buffer = arraybuffers.stringToArrayBuffer("\x41\x02");
  var hex = arraybuffers.arrayBufferToHexString(buffer);
  var header = {
    header: hex
  };

  return {
    addHeader: header,
    removeHeader: header
  };
}

// An obfuscator that injects headers.
export class HeaderShaper implements Transformer {
  // Headers that should be added to the outgoing packet stream.
  private addHeader_ :HeaderModel;

  // Headers that should be removed from the incoming packet stream.
  private removeHeader_ :HeaderModel;

  public constructor() {
    this.configure(JSON.stringify(sampleConfig()));
  }

  // This method is required to implement the Transformer API.
  // @param {ArrayBuffer} key Key to set, not used by this class.
  public setKey = (key:ArrayBuffer) :void => {
    throw new Error('setKey unimplemented');
  }

  // Configure the transformer with the headers to inject and the headers
  // to remove.
  public configure = (json:string) :void => {
    let config = JSON.parse(json);

    // Required parameters 'addHeader' and 'removeHeader'
    if ('addHeader' in config && 'removeHeader' in config) {
      // Deserialize the headers from strings
      [this.addHeader_, this.removeHeader_] =
        HeaderShaper.deserializeConfig(<HeaderConfig>config);
    } else {
      throw new Error("Header shaper requires addHeader and removeHeader parameters");
    }
  }

  // Inject header.
  public transform = (buffer :ArrayBuffer) :ArrayBuffer[] => {
//    log.debug('->', arraybuffers.arrayBufferToHexString(buffer));
//    log.debug('>>', arraybuffers.arrayBufferToHexString(
//      arraybuffers.concat([this.addHeader_.header, buffer])
//    ));
    return [
      // Inject a header into the packet.
      arraybuffers.concat([this.addHeader_.header, buffer])
    ];
  }

  // Remove injected header.
  public restore = (buffer :ArrayBuffer) :ArrayBuffer[] => {
//    log.debug('<-', arraybuffers.arrayBufferToHexString(buffer));
    let headerLength = this.removeHeader_.header.byteLength;
    let parts = arraybuffers.split(buffer, headerLength);
    let header = parts[0];
    let payload = parts[1];

    if (arraybuffers.byteEquality(header, this.removeHeader_.header)) {
      // Remove the injected header.
//      log.debug('<<', arraybuffers.arrayBufferToHexString(payload));
      return [payload];
    } else {
      // Injected header not found, so return the unmodified packet.
//      log.debug('Header not found');
      return [buffer];
    }
  }

  // No-op (we have no state or any resources to dispose).
  public dispose = () :void => {}

  // Decode the headers from strings in the config information
  static deserializeConfig(config :HeaderConfig) :[HeaderModel, HeaderModel] {
    return [
      HeaderShaper.deserializeModel(config.addHeader),
      HeaderShaper.deserializeModel(config.removeHeader)
    ];
  }

  // Decode the header from a string in the header model
  static deserializeModel(model :SerializedHeaderModel) :HeaderModel {
    return {
      header: arraybuffers.hexStringToArrayBuffer(model.header)
    };
  }
}
