
// TODO(bwiley): update uTransformers to be compatible with require
// TODO(ldixon): update to a require-style inclusion.
// e.g.
//  import Transformer = require('uproxy-obfuscators/transformer');
/// <reference path='../../../third_party/uTransformers/utransformers.d.ts' />

import logging = require('../logging/logging');
import Defragmenter = require('./defragmenter');
import Fragment = require('./fragment');
import arraybuffers = require('../arraybuffers/arraybuffers');

var log :logging.Log = new logging.Log('fancy-transformers');

// TODO(bwiley): Convert /* */ to // as specified in the style guide

/**
 * An obfuscator that only modifies packet length.
 * To start out, this is a very simple (and bad) packet length obfuscator.
 * It follows this logic:
 * Case 1 - buffer length + 2 == target: return length(buffer) + buffer
 * Case 2 - buffer length + 2 > target:  return length(target) + randomBytes(target)
 * Case 3 - buffer length + 2 < target:  return length(target) + buffer + randomBytes(target)
 */
class PacketLengthShaper {
  private fragmentation_ : boolean = false;
  private fragmentBuffer_ : Defragmenter = null;

  public constructor() {
    log.info('Constructed packet length shaper');
  }

  /**
   * This method is required to implement the Transformer API.
   * @param {ArrayBuffer} key Key to set, not used by this class.
   */
  public setKey = (key:ArrayBuffer) : void => {
    /* Do nothing. */
  }

  /** Get the target length. */
  public superConfigure = (json:string) : void => {
    var config=JSON.parse(json);
    // Optional parameter
    if('fragmentation' in config) {
      this.fragmentation_=config['fragmentation'];
    } // Otherwise use default value.

    if(this.fragmentation_) {
      this.fragmentBuffer_=new Defragmenter();
    }
  }

  public transform = (buffer:ArrayBuffer) : ArrayBuffer[] => {
//    log.info('Transforming');
    throw new Error('PacketLengthShaper is abstract and should not be instantiated directly. Instead, use a subclass.');
  }

  public shapePacketLength = (buffer:ArrayBuffer, target:number) : ArrayBuffer[] => {
//    log.debug("shapePacketLength %1", this.fragmentation_);
//    log.debug("transform %1 %2", buffer.byteLength, target);
    if(this.fragmentation_) {
      var fragments=this.makeFragments_(buffer, target);
      var results : ArrayBuffer[] = [];
      for(var index=0; index<fragments.length; index++) {
        var result=fragments[index].encodeFragment();
        results.push(result);
      }
      return results;
    } else {
      if (buffer.byteLength + 2 == target) {
        return [this.append_(this.encodeLength_(buffer.byteLength), buffer)];
      } else if (buffer.byteLength + 2 > target) {
        return [this.append_(this.encodeLength_(0), this.randomBytes_(target))];
      } else { // buffer.byteLength + 2 < target
        var result=this.append_(this.encodeLength_(buffer.byteLength), this.append_(buffer, this.randomBytes_(target-buffer.byteLength-2)))
        return [result];
      }
    }
  }

  // TODO(bwiley): Support target lengths below the header length
  private makeFragments_ = (buffer:ArrayBuffer, target:number) : Fragment[] => {
    var headerLength=36;
    if (buffer.byteLength + headerLength == target) { // One fragment with no padding
//      log.debug("One fragment no padding");
      var id=Fragment.randomId();
      var index=0;
      var count=1;
      var fragment=new Fragment(buffer.byteLength, id, index, count, buffer, new ArrayBuffer(0));
      return [fragment];
    } else if (buffer.byteLength + headerLength > target) {
      var firstLength=target-headerLength;
      var restLength=buffer.byteLength-firstLength;
//      log.debug("Fragment %1 %2", firstLength, restLength);
      var parts = this.split_(buffer, firstLength);
  //        log.debug("Parts %1 %2", parts[0].byteLength, parts[1].byteLength);
      var first = this.makeFragments_(parts[0], firstLength+headerLength);
      var rest = this.makeFragments_(parts[1], restLength+headerLength);
  //        log.debug("Fragmented %1 %2 %3", first.length+rest.length, first[0].byteLength, rest[0].byteLength);
      var fragments=first.concat(rest);
      this.fixFragments_(fragments);
      return fragments;
    } else { // buffer.bytelength + headerLength < target, One fragment with padding
//      log.debug("One fragment with padding");
      var id=Fragment.randomId();
      var index=0;
      var count=1;
      var padding=this.randomBytes_(target-(buffer.byteLength+headerLength))
      var fragment=new Fragment(buffer.byteLength, id, index, count, buffer, padding);
      return [fragment];
    }
  }

  public restore = (buffer:ArrayBuffer) : ArrayBuffer[] => {
//    log.debug("restore");
    if(this.fragmentation_) {
      var fragment=Fragment.decodeFragment(buffer);
      this.fragmentBuffer_.addFragment(fragment);
//      log.debug('Added fragment %1 %2 %3', fragment.index, fragment.count, this.fragmentBuffer_.completeCount());
      if(this.fragmentBuffer_.completeCount() > 0) {
        var complete=this.fragmentBuffer_.getComplete();
//        log.debug("restored %1 %2", complete[0].byteLength, arraybuffers.arrayBufferToHexString(complete[0]));
        return complete;
      } else {
        return [];
      }
    } else {
      var parts = this.split_(buffer, 2);
      var lengthBytes = parts[0];
      var length = this.decodeLength_(lengthBytes);
      var rest = parts[1];
      if(rest.byteLength > length) {
        parts=this.split_(rest, length);
  //      log.info('<- %1 %2', length, parts[0].byteLength);
        return [parts[0]];
      } else {
        return [rest];
      }
    }
  }

  // No-op (we have no state or any resources to dispose).
  public dispose = () : void => {}

  /* Takes a number and returns a two byte (network byte order) representation
   * of this number.
   */
   // TODO(bwiley): Byte order may be backward
  private encodeLength_ = (len:number) : ArrayBuffer => {
    var bytes = new Uint8Array(2);
    bytes[0] = Math.floor(len >> 8);
    bytes[1] = Math.floor((len << 8) >> 8);
    return bytes.buffer;
  }

  /* Takes a two byte (network byte order) representation of a number and returns
   * the number.
   */
   // TODO(bwiley): Byte order may be backward
   // TODO(bwiley): Fix type error
  private decodeLength_ = (buffer:ArrayBuffer) : number => {
    var bytes = new Uint8Array(buffer);
    var result = (bytes[0] << 8) | bytes[1];
    return result;
  }

  private split_ = (buffer:ArrayBuffer, firstLen:number) : Array<ArrayBuffer> => {
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

  /* Takes a number representing a length and returns an ArrayBuffer of that
   * length where all bytes in the array are generated by a random number
   * generator with a uniform distribution.
   */
  private randomBytes_ = (len:number) : ArrayBuffer => {
    var bytes = new Uint8Array(len);
    for (var i = 0; i < bytes.byteLength; i++) {
      bytes[i] = Math.floor(Math.random()*255);
    }
    return bytes.buffer;
  }

  /** Concatenates two ArrayBuffers. */
  private append_ = (buffer1:ArrayBuffer, buffer2:ArrayBuffer) : ArrayBuffer => {
    var tmp = new Uint8Array(buffer1.byteLength + buffer2.byteLength);
    tmp.set(new Uint8Array(buffer1), 0);
    tmp.set(new Uint8Array(buffer2), buffer1.byteLength);
    return tmp.buffer;
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

  private fixFragments_ = (fragments:Fragment[]) : void => {
    var id=fragments[0].id;
    var count=fragments.length;
    for(var index=0; index<count; index++) {
      fragments[index].id=id;
      fragments[index].index=index;
      fragments[index].count=count;
    }
  }
}

export = PacketLengthShaper;
