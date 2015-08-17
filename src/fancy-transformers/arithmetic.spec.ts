/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/typings/jasmine/jasmine.d.ts' />

import freedomMocker = require('../freedom/mocks/mock-freedom-in-module-env');
freedom = freedomMocker.makeMockFreedomInModuleEnv();

import arraybuffers = require('../arraybuffers/arraybuffers');
import arithmetic = require('./arithmetic');

var makeUniformProbabilities = () : number[] => {
  var probs : number[] = [];
  for(var index=0; index<256; index++) {
    probs[index]=1;
  }

  return probs;
}

describe('Arithmetic coding and decoding - short inputs', function() {
  it('encode("\x00\x01\x02\x03")=="\xCA\x00\x01\x02\x03\x00\x00"', function() {
    var encoder=new arithmetic.Encoder(makeUniformProbabilities());
    var result=encoder.encode(arraybuffers.stringToArrayBuffer("\x00\x01\x02\x03"));
//    console.log('encoded result: '+arraybuffers.arrayBufferToHexString(result));
    expect(arraybuffers.byteEquality(result, arraybuffers.stringToArrayBuffer("\xCA\x00\x01\x02\x03\x00\x00"))).toBe(true);
  });
  it('decode("\xCA\x00\x01\x02\x03\x00\x00")=="\x00\x01\x02\x03"', function() {
    var decoder=new arithmetic.Decoder(makeUniformProbabilities());
    var result=decoder.decode(arraybuffers.stringToArrayBuffer("\xCA\x00\x01\x02\x03\x00\x00"));
//    console.log('decoded result: '+arraybuffers.arrayBufferToHexString(result));
    expect(arraybuffers.byteEquality(result, arraybuffers.stringToArrayBuffer("\x00\x01\x02\x03"))).toBe(true);
  });
  /*it('encode("0123456789abcdefghijklmnopqrstuvxyz")=="\x00\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x78"', function() {
    var encoder=new arithmetic.Encoder(makeUniformProbabilities());
    var result=encoder.encode(arraybuffers.stringToArrayBuffer("0123456789abcdefghijklmnopqrstuvxyz"));
    console.log('result: '+arraybuffers.arrayBufferToHexString(result));
    expect(arraybuffers.byteEquality(result, arraybuffers.stringToArrayBuffer("\x00\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x78"))).toBe(true);
  });*/
  /*it('decode(encode("abc"))=="abc"', function() {
    var probs=makeUniformProbabilities();
    var encoder=new arithmetic.Encoder(probs);
    var decoder=new arithmetic.Decoder(probs);

    var original=arraybuffers.stringToArrayBuffer("abc");
    var encoded=encoder.encode(original);
    var decoded=decoder.decode(encoded);
    console.log('decoded: '+decoded.byteLength.toString());
    console.log('decoded: '+arraybuffers.arrayBufferToHexString(decoded));
    expect(arraybuffers.byteEquality(original, decoded)).toBe(true);
  });*/
});

describe('Arithmetic coding and decoding - long inputs', function() {
  it('encode(0.1.0.5c...43.3)==ca.0.1.0.5c...0.74', function() {
    var plain=arraybuffers.hexStringToArrayBuffer("0.1.0.5c.21.12.a4.42.48.4e.43.6a.4e.47.54.66.37.31.45.42.0.6.0.21.34.47.4a.39.65.49.69.4d.75.59.55.35.43.38.49.6a.3a.69.7a.72.51.34.77.72.57.66.70.31.6b.57.66.44.64.0.0.0.80.29.0.8.9a.85.cd.95.50.c8.ee.a.0.24.0.4.6e.7e.1e.ff.0.8.0.14.3.45.95.42.22.f0.da.66.3e.8e.b8.cc.79.a1.f7.ba.1.f.d5.0.80.28.0.4.e2.28.43.3");
    var target=arraybuffers.hexStringToArrayBuffer("ca.0.1.0.5c.21.12.a4.42.48.4e.43.6a.4e.47.54.66.37.31.45.42.0.6.0.21.34.47.4a.39.65.49.69.4d.75.59.55.35.43.38.49.6a.3a.69.7a.72.51.34.77.72.57.66.70.31.6b.57.66.44.64.0.0.0.80.29.0.8.9a.85.cd.95.50.c8.ee.a.0.24.0.4.6e.7e.ff.f.f8.27.f2.87.e4.ef.3.be.c3.f2.16.de.e2.e0.26.ca.4d.7c.48.1e.9a.ff.cf.d8.9.bf.6e.5d.c2.fd");
    var encoder=new arithmetic.Encoder(makeUniformProbabilities());
    var encoded=encoder.encode(plain);
    console.log('encoded result: '+arraybuffers.arrayBufferToHexString(encoded));
    expect(arraybuffers.byteEquality(encoded, target)).toBe(true);
  });
  it('decode(ca.0.1.0.5c...0.74)==0.1.0.5c...43.3', function() {
    var encoded=arraybuffers.hexStringToArrayBuffer("ca.0.1.0.5c.21.12.a4.42.48.4e.43.6a.4e.47.54.66.37.31.45.42.0.6.0.21.34.47.4a.39.65.49.69.4d.75.59.55.35.43.38.49.6a.3a.69.7a.72.51.34.77.72.57.66.70.31.6b.57.66.44.64.0.0.0.80.29.0.8.9a.85.cd.95.50.c8.ee.a.0.24.0.4.6e.7e.ff.f.f8.27.f2.87.e4.ef.3.be.c3.f2.16.de.e2.e0.26.ca.4d.7c.48.1e.9a.ff.cf.d8.9.bf.6e.5d.c2.fd");
    var target=arraybuffers.hexStringToArrayBuffer("0.1.0.5c.21.12.a4.42.48.4e.43.6a.4e.47.54.66.37.31.45.42.0.6.0.21.34.47.4a.39.65.49.69.4d.75.59.55.35.43.38.49.6a.3a.69.7a.72.51.34.77.72.57.66.70.31.6b.57.66.44.64.0.0.0.80.29.0.8.9a.85.cd.95.50.c8.ee.a.0.24.0.4.6e.7e.1e.ff.0.8.0.14.3.45.95.42.22.f0.da.66.3e.8e.b8.cc.79.a1.f7.ba.1.f.d5.0.80.28.0.4.e2.28.43.3");
    var decoder=new arithmetic.Decoder(makeUniformProbabilities());
    var decoded=decoder.decode(encoded);
    console.log('encoded result: '+arraybuffers.arrayBufferToHexString(decoded));
    expect(arraybuffers.byteEquality(decoded, target)).toBe(true);
  });
  /*it('decode("\xCA\x00\x01\x02\x03\x00\x00")=="\x00\x01\x02\x03"', function() {
    var decoder=new arithmetic.Decoder(makeUniformProbabilities());
    var result=decoder.decode(arraybuffers.stringToArrayBuffer("\xCA\x00\x01\x02\x03\x00\x00"));
//    console.log('decoded result: '+arraybuffers.arrayBufferToHexString(result));
    expect(arraybuffers.byteEquality(result, arraybuffers.stringToArrayBuffer("\x00\x01\x02\x03"))).toBe(true);
  });*/
  /*it('encode("0123456789abcdefghijklmnopqrstuvxyz")=="\x00\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x78"', function() {
    var encoder=new arithmetic.Encoder(makeUniformProbabilities());
    var result=encoder.encode(arraybuffers.stringToArrayBuffer("0123456789abcdefghijklmnopqrstuvxyz"));
    console.log('result: '+arraybuffers.arrayBufferToHexString(result));
    expect(arraybuffers.byteEquality(result, arraybuffers.stringToArrayBuffer("\x00\x30\x31\x32\x33\x34\x35\x36\x37\x38\x39\x61\x62\x63\x64\x65\x66\x67\x68\x69\x6a\x6b\x6c\x6d\x6e\x6f\x70\x71\x72\x73\x74\x75\x76\x78"))).toBe(true);
  });*/
  /*it('decode(encode("abc"))=="abc"', function() {
    var probs=makeUniformProbabilities();
    var encoder=new arithmetic.Encoder(probs);
    var decoder=new arithmetic.Decoder(probs);

    var original=arraybuffers.stringToArrayBuffer("abc");
    var encoded=encoder.encode(original);
    var decoded=decoder.decode(encoded);
    console.log('decoded: '+decoded.byteLength.toString());
    console.log('decoded: '+arraybuffers.arrayBufferToHexString(decoded));
    expect(arraybuffers.byteEquality(original, decoded)).toBe(true);
  });*/
})
