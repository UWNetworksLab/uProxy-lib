/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/typings/jasmine/jasmine.d.ts' />

import freedomMocker = require('../freedom/mocks/mock-freedom-in-module-env');
freedom = freedomMocker.makeMockFreedomInModuleEnv();

import arraybuffers = require('../arraybuffers/arraybuffers');
import arithmetic = require('./arithmetic');

/*describe('Sanity check', function() {
  it('true==true', function() {
    expect(true).toBe(true);
  });
});*/

var makeUniformProbabilities = () : number[] => {
  var probs : number[] = [];
  for(var index=0; index<256; index++) {
    probs[index]=1;
  }

  return probs;
}

describe('Arithmetic coding and decoding', function() {
  it('encode("abc")=="\x00\x61"', function() {
    var encoder=new arithmetic.Encoder(makeUniformProbabilities());
    var result=encoder.encode(arraybuffers.stringToArrayBuffer("abc"));
    console.log('result: '+arraybuffers.arrayBufferToHexString(result));
    expect(arraybuffers.byteEquality(result, arraybuffers.stringToArrayBuffer("\x00\x61"))).toBe(true);
  });
  it('encode("0123456789abcdefghijklmnopqrstuvxyz")=="\x00\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x78"', function() {
    var encoder=new arithmetic.Encoder(makeUniformProbabilities());
    var result=encoder.encode(arraybuffers.stringToArrayBuffer("0123456789abcdefghijklmnopqrstuvxyz"));
    console.log('result: '+arraybuffers.arrayBufferToHexString(result));
    expect(arraybuffers.byteEquality(result, arraybuffers.stringToArrayBuffer("\x00\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x78"))).toBe(true);
  });
  it('decode(encode("abc"))=="abc"', function() {
    var probs=makeUniformProbabilities();
    var encoder=new arithmetic.Encoder(probs);
    var decoder=new arithmetic.Decoder(probs);

    var original=arraybuffers.stringToArrayBuffer("abc");
    var encoded=encoder.encode(original);
    var decoded=decoder.decode(encoded);
    console.log('decoded: '+decoded.byteLength.toString());
    console.log('decoded: '+arraybuffers.arrayBufferToHexString(decoded));
    expect(arraybuffers.byteEquality(original, decoded)).toBe(true);
  });
});
