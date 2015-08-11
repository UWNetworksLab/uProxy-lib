/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/typings/jasmine/jasmine.d.ts' />

import freedomMocker = require('../freedom/mocks/mock-freedom-in-module-env');
freedom = freedomMocker.makeMockFreedomInModuleEnv();

import arraybuffers = require('../arraybuffers/arraybuffers');
import aes = require('./aes');

describe('AES encryption and decryption', function() {
  it('AES(key: zeros, iv: zeros).encrypt(zeros)=="66.e9.4b.d4.ef.8a.2c.3b.88.4c.fa.59.ca.34.2b.2e"', function() {
    var cbc=new aes.ModeOfOperationCBC(new ArrayBuffer(16), new ArrayBuffer(16));
    var plaintext=new ArrayBuffer(16);
    var ciphertext=cbc.encrypt(plaintext);
    expect(arraybuffers.byteEquality(ciphertext, arraybuffers.hexStringToArrayBuffer("66.e9.4b.d4.ef.8a.2c.3b.88.4c.fa.59.ca.34.2b.2e"))).toBe(true);
  });
  it('AES(key: zeros, iv: zeros).decrypt(66.e9.4b.d4.ef.8a.2c.3b.88.4c.fa.59.ca.34.2b.2e)==zeros', function() {
    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var ciphertext=arraybuffers.hexStringToArrayBuffer("66.e9.4b.d4.ef.8a.2c.3b.88.4c.fa.59.ca.34.2b.2e");
    var plaintext=cbc.decrypt(ciphertext);
    expect(arraybuffers.byteEquality(plaintext, new ArrayBuffer(16))).toBe(true);
  });
  it('AES(key: zeros, iv: zeros).decrypt(encrypt(zeros))==zeros', function() {
    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var encrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=new ArrayBuffer(16);
    var ciphertext=encrypter.encrypt(plaintext);
    var decrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext2=decrypter.decrypt(ciphertext);
    expect(arraybuffers.byteEquality(plaintext, plaintext2)).toBe(true);
  });
});
