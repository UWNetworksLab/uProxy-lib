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
  public id : number;
  public index : number;
  public count : number;
  public payload : ArrayBuffer;

  public constructor(id:number, index:number, count:number, payload:ArrayBuffer) {
    this.id=id;
    this.index=index;
    this.count=count;
    this.payload=payload;
  }

  static randomId = () : number => {
    return Math.floor(Math.random()*255);
  }

  static decodeFragment = (buffer:ArrayBuffer, length:number) : Fragment => {
    var fragmentId=0;

    var fragmentNumber=takeByte_(buffer);
    buffer=dropByte_(buffer);

    var totalNumber=takeByte_(buffer);
    buffer=dropByte_(buffer);

    var payload : ArrayBuffer=null;

    if(buffer.byteLength > length) {
      var parts=split_(buffer, length);
      payload=parts[0];
    } else if (buffer.byteLength == length) {
      payload=buffer;
    } else { // buffer.byteLength < length
      throw new Error("Short buffer");
    }

    var fragment=new Fragment(fragmentId, fragmentNumber, totalNumber, payload);
    return fragment;
  }

  public encodeFragment = () : ArrayBuffer => {
    return this.assemble_([encodeByte_(this.id), encodeByte_(this.index), encodeByte_(this.count), this.payload]);
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
      }
    }

    return result.buffer;
  }
}

export=Fragment;
