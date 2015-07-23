import logging = require('../logging/logging');

var log :logging.Log = new logging.Log('fancy-transformers');

var takeByte_ = (buffer:ArrayBuffer) : number => {
  var bytes=new Uint8Array(buffer);
  return bytes[0];
}

var dropByte_ = (buffer:ArrayBuffer) : ArrayBuffer => {
  var bytes=new Uint8Array(buffer)
  var result = new Uint8Array(buffer.byteLength-1);
  var fromIndex : number = 1;
  var toIndex : number = 0;
  while(toIndex < result.length) {
    result[toIndex] = bytes[fromIndex];
    toIndex=toIndex+1;
    fromIndex=fromIndex+1;
  }

  return result.buffer;
}

var encodeByte_ = (num:number) : ArrayBuffer => {
  var bytes = new Uint8Array(1);
  bytes[0]=num;
  return bytes.buffer;
}

var split_ = (buffer:ArrayBuffer, firstLen:number) : Array<ArrayBuffer> => {
  var bytes=new Uint8Array(buffer)
  var lastLen : number = buffer.byteLength-firstLen;
  var first = new Uint8Array(firstLen);
  var last = new Uint8Array(lastLen);
  var fromIndex : number = 0;
  var toIndex : number = 0;
  while(toIndex < first.length) {
    first[toIndex] = bytes[fromIndex];
    toIndex=toIndex+1;
    fromIndex=fromIndex+1;
  }

  toIndex=0;
  while(toIndex < last.length) {
    last[toIndex] = bytes[fromIndex];
    toIndex=toIndex+1;
    fromIndex=fromIndex+1;
  }

  return [first.buffer, last.buffer];
}

class Fragment {
  public id : ArrayBuffer;
  public index : number;
  public count : number;
  public payload : ArrayBuffer;

  public constructor(id:ArrayBuffer, index:number, count:number, payload:ArrayBuffer) {
    this.id=id;
    this.index=index;
    this.count=count;
    this.payload=payload;
  }

  static randomId = () : ArrayBuffer => {
    var bytes = new Uint8Array(32);
    for (var i = 0; i < bytes.byteLength; i++) {
      bytes[i] = Math.floor(Math.random()*255);
    }
    return bytes.buffer;
  }

  static decodeFragment = (buffer:ArrayBuffer, length:number) : Fragment => {
//    log.debug('Decode fragment %1 %2', buffer.byteLength, length);
    var parts=split_(buffer, 32);
    var fragmentId=parts[0];
    buffer=parts[1];

    var fragmentNumber=takeByte_(buffer);
    buffer=dropByte_(buffer);

    var totalNumber=takeByte_(buffer);
    buffer=dropByte_(buffer);

//    log.debug('Decoded fragment %1 %2 %3', fragmentId, fragmentNumber, totalNumber);

    var payload : ArrayBuffer=null;

    if(buffer.byteLength > length) {
      parts=split_(buffer, length);
      payload=parts[0];
//      log.debug('shortened payoad %1 %2 %3', buffer.byteLength, length, payload.byteLength);
    } else if (buffer.byteLength == length) {
      payload=buffer;
//      log.debug('perect payoad %1 %2 %3', buffer.byteLength, length, payload.byteLength);
    } else { // buffer.byteLength < length
      throw new Error("Short buffer");
    }

    var fragment=new Fragment(fragmentId, fragmentNumber, totalNumber, payload);
//    log.info("Decoding %1 %2 %3", fragment.id, fragment.index, fragment.count);
    return fragment;
  }

  public encodeFragment = () : ArrayBuffer => {
//    log.info("Encoding %1 %2 %3", this.id, this.index, this.count);
    return this.assemble_([this.id, encodeByte_(this.index), encodeByte_(this.count), this.payload]);
  }

  private assemble_ = (buffers:ArrayBuffer[]) : ArrayBuffer => {
    var total=0;
    for(var i=0; i<buffers.length; i++) {
      total=total+buffers[i].byteLength;
    }

    var result = new Uint8Array(total);
    var toIndex=0;
    for(var i=0; i<buffers.length; i++) {
      var bytes=new Uint8Array(buffers[i]);
      for(var fromIndex=0; fromIndex<buffers[i].byteLength; fromIndex++) {
        result[toIndex]=bytes[fromIndex];
        toIndex=toIndex+1;
      }
    }

    return result.buffer;
  }
}

export=Fragment;
