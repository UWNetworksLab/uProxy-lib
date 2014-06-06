/// <reference path='arraybuffers.ts' />
/// <reference path='../../third_party/DefinitelyTyped/jasmine/jasmine.d.ts' />

module ArrayBuffers {

  var array1 = new Uint8Array([12,118,101,114,105,115]);
  var string1 = '\x0C\x76\x65\x72\x69\x73';
  var hexString1 = 'c.76.65.72.69.73';

  var array2 = new Uint8Array([0,2,129,128,0,1,0,5,0]);
  var string2 = '\x00\x02\x81\x80\x00\x01\x00\x05\x00';
  var hexString2 = '0.2.81.80.0.1.0.5.0';

  var emptyArray = new Uint8Array([]);
  var emptyString = '';
  var emptyHexString = '';

  describe("ArrayBuffers <-> Hex Strings", function() {
    it("arrayBufferEquality: emptyArray == emptyArray", function() {
      expect(ArrayBuffers.byteEquality(emptyArray, emptyArray)).toBe(true);
    });
    it("arrayBufferEquality: array1 == array1", function() {
      expect(ArrayBuffers.byteEquality(array1, array1)).toBe(true);
    });
    it("arrayBufferEquality: array1 != emptyArray", function() {
      expect(ArrayBuffers.byteEquality(array1, emptyArray)).toBe(false);
    });
    it("arrayBufferEquality: array1 != array2", function() {
      expect(ArrayBuffers.byteEquality(array1, array2)).toBe(false);
    });

    it("Empty Buffer -> Empty Hex", function() {
      expect(arrayBufferToHexString(emptyArray)).toEqual(emptyHexString);
    });
    it("Empty Hex -> Empty Buffer", function() {
      expect(ArrayBuffers.byteEquality(hexStringToArrayBuffer(emptyHexString),
                                       emptyArray)).toBe(true);
    });

    it("Buffer -> Hex", function() {
      expect(arrayBufferToHexString(emptyArray)).toEqual(emptyString);
      expect(arrayBufferToHexString(array1)).toEqual(hexString1);
      expect(arrayBufferToHexString(array2)).toEqual(hexString2);
    });

    it("Hex -> Buffer -> Hex = identity", function() {
      expect(arrayBufferToHexString(hexStringToArrayBuffer(emptyString)))
          .toEqual(emptyString);
      expect(arrayBufferToHexString(hexStringToArrayBuffer(emptyString)))
          .not.toEqual(hexString1);
      expect(arrayBufferToHexString(hexStringToArrayBuffer(hexString1)))
          .toEqual(hexString1);
      expect(arrayBufferToHexString(hexStringToArrayBuffer(hexString2)))
          .toEqual(hexString2);
      expect(arrayBufferToHexString(hexStringToArrayBuffer(hexString1)))
          .not.toEqual(hexString2);
    });
  });


  describe("ArrayBuffers <-> strings", function() {
    it("Empty Buffer -> Empty Hex", function() {
      expect(arrayBufferToHexString(emptyArray)).toEqual(emptyString);
    });
    it("Empty Hex -> Empty Buffer", function() {
      expect(ArrayBuffers.byteEquality(hexStringToArrayBuffer(emptyString),
                                       emptyArray)).toBe(true);
    });

    it("Buffer -> String", function() {
      expect(arrayBufferToHexString(emptyArray)).toEqual(emptyString);
      expect(arrayBufferToHexString(array1)).toEqual(hexString1);
      expect(arrayBufferToHexString(array1)).not.toEqual(hexString2);
      expect(arrayBufferToHexString(array2)).toEqual(hexString2);
    });

    it("String -> Buffer -> String = identity", function() {
      expect(arrayBufferToString(stringToArrayBuffer(emptyString)))
          .toEqual(emptyString);
      expect(arrayBufferToString(stringToArrayBuffer(emptyString)))
          .not.toEqual(hexString1);
      expect(arrayBufferToString(stringToArrayBuffer(string1)))
          .toEqual(string1);
      expect(arrayBufferToString(stringToArrayBuffer(string2)))
          .toEqual(string2);
      expect(arrayBufferToString(stringToArrayBuffer(string1)))
          .not.toEqual(string2);
    });
  });


}  // module ArrayBuffers
