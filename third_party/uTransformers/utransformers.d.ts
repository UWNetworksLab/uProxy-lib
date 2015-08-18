// This file provides the declarations for the Rabbit and Fte uTransformers
// modules.

interface Transformer {
  /**
   * Sets the key for this transformer session.
   *
   * @param {ArrayBuffer} key session key.
   * @return {boolean} true if successful.
   */
  setKey(key:ArrayBuffer) :void;

  /**
   * Configures this transformer.
   *
   * @param {String} serialized Json string.
   */
  configure(json:string) :void;

  /**
   * Transforms a piece of data to obfuscated form.
   *
   * @param {ArrayBuffer} plaintext data that needs to be obfuscated.
   * @return {ArrayBuffer[]} list of ArrayBuffers of obfuscated data.
   * The list can contain zero, one, or more than one items.
   * In the case of fragmentation:
   *   When fragmention occurs, the list will have more than one item.
   *   When there is no fragmentation, the list will have one item.
   */
  transform(buffer:ArrayBuffer) :ArrayBuffer[];

  /**
   * Restores data from obfuscated form to original form.
   *
   * @param {ArrayBuffer} ciphertext obfuscated data.
   * @return {ArrayBuffer} list of ArrayBuffers of original data.
   * The list can contain zero, one, or more than one items.
   * In the case of fragmentation:
   *   When receiving a fragment, the list will have zero items,
   *   unless it was the last fragment, then the list will have one item.
   */
  restore(buffer:ArrayBuffer) :ArrayBuffer[];

  /**
   * Dispose the transformer.
   *
   * This should be the last method called on a transformer instance.
   */
  dispose() :void;
}

declare module "utransformers/src/transformers/uTransformers.fte" {
  export function Transformer() :Transformer;
}

declare module "utransformers/src/transformers/uTransformers.rabbit" {
  export function Transformer() :Transformer;
}
