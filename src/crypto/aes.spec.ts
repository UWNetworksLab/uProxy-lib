/// <reference path='../../../third_party/typings/es6-promise/es6-promise.d.ts' />
/// <reference path='../../../third_party/typings/jasmine/jasmine.d.ts' />

import freedomMocker = require('../freedom/mocks/mock-freedom-in-module-env');
freedom = freedomMocker.makeMockFreedomInModuleEnv();

import arraybuffers = require('../arraybuffers/arraybuffers');
import aes = require('./aes');

describe('AES encryption and decryption - zero key, zero iv, zero data', function() {
  it('AES(key: zeros, iv: zeros).encrypt(zeros)=="66.e9...2b.2e"', function() {
    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=new ArrayBuffer(16);
    var ciphertext=cbc.encrypt(plaintext);
    expect(arraybuffers.byteEquality(
      ciphertext,
      arraybuffers.hexStringToArrayBuffer("66.e9.4b.d4.ef.8a.2c.3b.88.4c.fa.59.ca.34.2b.2e")
    )).toBe(true);
  });
  it('AES(key: zeros, iv: zeros).decrypt(66.e9...2b.2e)==zeros', function() {
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

describe('AES encryption and decryption - zero key, zero iv, zero data - two rounds', function() {
  it('Two Rounds: AES(key: zeros, iv: zeros).encrypt(zeros)==f7.95...8d.bc', function() {
    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=new ArrayBuffer(16);
    var ciphertext=cbc.encrypt(plaintext);
    expect(arraybuffers.byteEquality(
      ciphertext,
      arraybuffers.hexStringToArrayBuffer("66.e9.4b.d4.ef.8a.2c.3b.88.4c.fa.59.ca.34.2b.2e")
    )).toBe(true);
    var ciphertext2=cbc.encrypt(plaintext);
    expect(arraybuffers.byteEquality(
      ciphertext2,
      arraybuffers.hexStringToArrayBuffer("f7.95.bd.4a.52.e2.9e.d7.13.d3.13.fa.20.e9.8d.bc")
    )).toBe(true);
  });
  it('Two rounds: AES(key: zeros, iv: zeros).decrypt(f7.95...8d.bc)==zeros', function() {
    var target=new ArrayBuffer(16);

    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var ciphertext=arraybuffers.hexStringToArrayBuffer("66.e9.4b.d4.ef.8a.2c.3b.88.4c.fa.59.ca.34.2b.2e");
    var plaintext=cbc.decrypt(ciphertext);
    expect(arraybuffers.byteEquality(plaintext, target)).toBe(true);
    var ciphertext2=arraybuffers.hexStringToArrayBuffer("f7.95.bd.4a.52.e2.9e.d7.13.d3.13.fa.20.e9.8d.bc");
    var plaintext2=cbc.decrypt(ciphertext2);
    expect(arraybuffers.byteEquality(plaintext, target)).toBe(true);
  });
  it('Two rounds: AES(key: zeros, iv: zeros).decrypt(encrypt(zeros))==zeros', function() {
    var target=new ArrayBuffer(16);

    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var encrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=new ArrayBuffer(16);
    var ciphertext=encrypter.encrypt(plaintext);
    var ciphertext2=encrypter.encrypt(plaintext);
    var decrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext2=decrypter.decrypt(ciphertext);
    var plaintext3=decrypter.decrypt(ciphertext2);

    expect(arraybuffers.byteEquality(target, plaintext2)).toBe(true);
    expect(arraybuffers.byteEquality(target, plaintext3)).toBe(true);
  });
});

describe('AES encryption and decryption - zero key, zero iv, real data', function() {
  it('AES(key: zeros, iv: zeros).encrypt(0.74...35.68)==21.86...dd.d2', function() {
    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=arraybuffers.hexStringToArrayBuffer("0.74.0.1.0.60.21.12.a4.42.30.67.62.4c.66.53.55.39.67.46.62.38.0.6.0.21.6a.6d.67.7a.78.5a.6e.77.72.61.53.69.65.73.53.74.3a.75.4b.6b.55.32.51.4a.79.72.53.76.51.68.54.34.4b.0.0.0.80.2a.0.8.22.de.fe.e5.3a.7c.10.b4.0.25.0.0.0.24.0.4.6e.7e.1e.ff.0.8.0.14.f7.21.4f.8e.7.40.5c.2.fe.f9.6e.3b.b.3.f5.b.cc.ea.b4.cb.80.28.0.4.86.67.7f.83.9.75.cf.cf.52.2f.c3.5d.35.68");
    var ciphertext=cbc.encrypt(plaintext);
    var ciphertext2=arraybuffers.hexStringToArrayBuffer("21.86.8b.3.18.56.a8.54.a3.14.2e.2.22.68.57.43.14.ac.60.42.19.2b.9f.f1.50.98.42.af.b6.86.5b.39.6a.5.f.b7.fc.e9.41.70.a2.4f.d.3f.dc.dd.86.e8.e.8a.8f.25.b1.96.4f.1b.fe.7c.4d.6f.26.f6.e9.95.d9.3.89.62.f0.d2.d.df.ec.bd.91.e6.75.d0.f6.de.3f.cb.4f.c8.a6.e5.e.f8.ca.ac.ae.de.39.70.32.27.b8.48.9e.41.2a.24.69.64.29.60.c9.a8.e4.91.8e.8c.8d.2e.a6.e7.f2.9f.4a.ae.82.3.99.1e.8a.8d.dd.d2");
    expect(arraybuffers.byteEquality(ciphertext, ciphertext2)).toBe(true);
  });
  it('AES(key: zeros, iv: zeros).decrypt(21.86...dd.d2)==0.74...35.68', function() {
    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=arraybuffers.hexStringToArrayBuffer("0.74.0.1.0.60.21.12.a4.42.30.67.62.4c.66.53.55.39.67.46.62.38.0.6.0.21.6a.6d.67.7a.78.5a.6e.77.72.61.53.69.65.73.53.74.3a.75.4b.6b.55.32.51.4a.79.72.53.76.51.68.54.34.4b.0.0.0.80.2a.0.8.22.de.fe.e5.3a.7c.10.b4.0.25.0.0.0.24.0.4.6e.7e.1e.ff.0.8.0.14.f7.21.4f.8e.7.40.5c.2.fe.f9.6e.3b.b.3.f5.b.cc.ea.b4.cb.80.28.0.4.86.67.7f.83.9.75.cf.cf.52.2f.c3.5d.35.68");
    var ciphertext=arraybuffers.hexStringToArrayBuffer("21.86.8b.3.18.56.a8.54.a3.14.2e.2.22.68.57.43.14.ac.60.42.19.2b.9f.f1.50.98.42.af.b6.86.5b.39.6a.5.f.b7.fc.e9.41.70.a2.4f.d.3f.dc.dd.86.e8.e.8a.8f.25.b1.96.4f.1b.fe.7c.4d.6f.26.f6.e9.95.d9.3.89.62.f0.d2.d.df.ec.bd.91.e6.75.d0.f6.de.3f.cb.4f.c8.a6.e5.e.f8.ca.ac.ae.de.39.70.32.27.b8.48.9e.41.2a.24.69.64.29.60.c9.a8.e4.91.8e.8c.8d.2e.a6.e7.f2.9f.4a.ae.82.3.99.1e.8a.8d.dd.d2");
    var plaintext2=cbc.decrypt(ciphertext);
    expect(arraybuffers.byteEquality(plaintext, plaintext2)).toBe(true);
  });
  it('AES(key: zeros, iv: zeros).decrypt(encrypt(0.74...35.68))==0.74...35.68', function() {
    var key=new ArrayBuffer(16);
    var iv=new ArrayBuffer(16);
    var encrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=arraybuffers.hexStringToArrayBuffer("0.74.0.1.0.60.21.12.a4.42.30.67.62.4c.66.53.55.39.67.46.62.38.0.6.0.21.6a.6d.67.7a.78.5a.6e.77.72.61.53.69.65.73.53.74.3a.75.4b.6b.55.32.51.4a.79.72.53.76.51.68.54.34.4b.0.0.0.80.2a.0.8.22.de.fe.e5.3a.7c.10.b4.0.25.0.0.0.24.0.4.6e.7e.1e.ff.0.8.0.14.f7.21.4f.8e.7.40.5c.2.fe.f9.6e.3b.b.3.f5.b.cc.ea.b4.cb.80.28.0.4.86.67.7f.83.9.75.cf.cf.52.2f.c3.5d.35.68");
    var ciphertext=encrypter.encrypt(plaintext);
    var decrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext2=decrypter.decrypt(ciphertext);
    expect(arraybuffers.byteEquality(plaintext, plaintext2)).toBe(true);
  });
});

describe('AES encryption and decryption - zero key, zero iv, real data', function() {
  it('AES(key: zeros, iv: f0.61...b5.d1).encrypt(0.74...35.68)==5d.8f...d.8b', function() {
    var key=new ArrayBuffer(16);
    var iv=arraybuffers.hexStringToArrayBuffer("f0.61.2f.5c.60.92.bc.60.79.e5.6e.e7.a.53.b5.d1");
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=arraybuffers.hexStringToArrayBuffer("0.74.0.1.0.60.21.12.a4.42.30.67.62.4c.66.53.55.39.67.46.62.38.0.6.0.21.6a.6d.67.7a.78.5a.6e.77.72.61.53.69.65.73.53.74.3a.75.4b.6b.55.32.51.4a.79.72.53.76.51.68.54.34.4b.0.0.0.80.2a.0.8.22.de.fe.e5.3a.7c.10.b4.0.25.0.0.0.24.0.4.6e.7e.1e.ff.0.8.0.14.f7.21.4f.8e.7.40.5c.2.fe.f9.6e.3b.b.3.f5.b.cc.ea.b4.cb.80.28.0.4.86.67.7f.83.9.75.cf.cf.52.2f.c3.5d.35.68");
    var ciphertext=cbc.encrypt(plaintext);
    var ciphertext2=arraybuffers.hexStringToArrayBuffer("5d.8f.6a.8.dd.27.63.15.1.23.84.72.73.41.8e.5.90.fd.70.45.63.4b.60.7.a4.73.0.32.cb.c2.df.58.70.fe.40.86.bc.ce.4.cd.a2.60.d8.d1.e2.e3.f4.ff.bd.c8.20.b.c4.8.aa.a9.dd.1f.60.ad.97.91.bc.22.ed.72.0.1e.bc.22.90.56.96.f4.f9.f0.31.4a.db.a.9a.60.6d.b3.24.c3.8d.9e.f5.6c.87.f6.b4.55.e0.7c.31.1a.4f.47.16.a1.dc.3a.e7.1.3a.b3.45.86.d2.38.5a.df.10.3d.fc.33.c9.d2.e.d8.5.57.ef.49.d.8b");
    expect(arraybuffers.byteEquality(ciphertext, ciphertext2)).toBe(true);
  });
  it('AES(key: zeros, iv: f0.61...b5.d1).decrypt(5d.8f...d.8b)==0.74...35.68', function() {
    var key=new ArrayBuffer(16);
    var iv=arraybuffers.hexStringToArrayBuffer("f0.61.2f.5c.60.92.bc.60.79.e5.6e.e7.a.53.b5.d1");
    var cbc=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=arraybuffers.hexStringToArrayBuffer("0.74.0.1.0.60.21.12.a4.42.30.67.62.4c.66.53.55.39.67.46.62.38.0.6.0.21.6a.6d.67.7a.78.5a.6e.77.72.61.53.69.65.73.53.74.3a.75.4b.6b.55.32.51.4a.79.72.53.76.51.68.54.34.4b.0.0.0.80.2a.0.8.22.de.fe.e5.3a.7c.10.b4.0.25.0.0.0.24.0.4.6e.7e.1e.ff.0.8.0.14.f7.21.4f.8e.7.40.5c.2.fe.f9.6e.3b.b.3.f5.b.cc.ea.b4.cb.80.28.0.4.86.67.7f.83.9.75.cf.cf.52.2f.c3.5d.35.68");
    var ciphertext=arraybuffers.hexStringToArrayBuffer("5d.8f.6a.8.dd.27.63.15.1.23.84.72.73.41.8e.5.90.fd.70.45.63.4b.60.7.a4.73.0.32.cb.c2.df.58.70.fe.40.86.bc.ce.4.cd.a2.60.d8.d1.e2.e3.f4.ff.bd.c8.20.b.c4.8.aa.a9.dd.1f.60.ad.97.91.bc.22.ed.72.0.1e.bc.22.90.56.96.f4.f9.f0.31.4a.db.a.9a.60.6d.b3.24.c3.8d.9e.f5.6c.87.f6.b4.55.e0.7c.31.1a.4f.47.16.a1.dc.3a.e7.1.3a.b3.45.86.d2.38.5a.df.10.3d.fc.33.c9.d2.e.d8.5.57.ef.49.d.8b");
    var plaintext2=cbc.decrypt(ciphertext);
    expect(arraybuffers.byteEquality(plaintext, plaintext2)).toBe(true);
  });
  it('AES(key: zeros, iv: f0.61...b5.d1).decrypt(encrypt(0...68))==0...68', function() {
    var key=new ArrayBuffer(16);
    var iv=arraybuffers.hexStringToArrayBuffer("f0.61.2f.5c.60.92.bc.60.79.e5.6e.e7.a.53.b5.d1");
    var encrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext=arraybuffers.hexStringToArrayBuffer("0.74.0.1.0.60.21.12.a4.42.30.67.62.4c.66.53.55.39.67.46.62.38.0.6.0.21.6a.6d.67.7a.78.5a.6e.77.72.61.53.69.65.73.53.74.3a.75.4b.6b.55.32.51.4a.79.72.53.76.51.68.54.34.4b.0.0.0.80.2a.0.8.22.de.fe.e5.3a.7c.10.b4.0.25.0.0.0.24.0.4.6e.7e.1e.ff.0.8.0.14.f7.21.4f.8e.7.40.5c.2.fe.f9.6e.3b.b.3.f5.b.cc.ea.b4.cb.80.28.0.4.86.67.7f.83.9.75.cf.cf.52.2f.c3.5d.35.68");
    var ciphertext=encrypter.encrypt(plaintext);
    var decrypter=new aes.ModeOfOperationCBC(key, iv);
    var plaintext2=decrypter.decrypt(ciphertext);
    expect(arraybuffers.byteEquality(plaintext, plaintext2)).toBe(true);
  });
});
