// TypeScript definitions for aes-js:
//   https://github.com/ricmoo/aes-js

// TODO: the other modes of operation!
// TODO: throughout, Uint8Array is interchangeable with number[]

declare module 'aes-js' {
  module ModeOfOperation {
    class cbc {
      constructor(key:Uint8Array, iv:Uint8Array);
      encrypt(bytes:Uint8Array) : Uint8Array;
      // NOTE: the returned type is a Uint8Array-like object which lacks a buffer field
      // TODO: type definition for the returned type (examine the browserified source)
      decrypt(bytes:Uint8Array) : Uint8Array;
    }
  }

  module util {
    function convertStringToBytes(text:string, encoding?:string) : Uint8Array;
    function convertBytesToString(bytes:Uint8Array, encoding?:string) : string;
  }
}
