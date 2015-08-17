
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

// An obfuscator that only modifies packet length.
// This is an abstract class. The specific behavior is defined by subclasses.
class PacketLengthShaper {
  private fragmentation_ :boolean = false;
  private fragmentBuffer_ :Defragmenter = null;

  public constructor() {
    log.info('Constructed packet length shaper');
  }

  // This method is required to implement the Transformer API.
  // @param {ArrayBuffer} key Key to set, not used by this class.
  public setKey = (key:ArrayBuffer) :void => {
    // Do nothing.
  }

  // Get the target length.
  public superConfigure = (json:string) :void => {
    var config=JSON.parse(json);
    // Optional parameter
    if('fragmentation' in config) {
      this.fragmentation_=config['fragmentation'];
    } // Otherwise use default value.

    if(this.fragmentation_) {
      this.fragmentBuffer_=new Defragmenter();
    }
  }

  public transform = (buffer:ArrayBuffer) :ArrayBuffer[] => {
//    log.info('Transforming');
    throw new Error('PacketLengthShaper is abstract and should not be instantiated directly. Instead, use a subclass.');
  }

  public shapePacketLength = (buffer:ArrayBuffer, target:number) :ArrayBuffer[] => {
//    log.debug("shapePacketLength %1", this.fragmentation_);
//    log.debug("transform %1 %2", buffer.byteLength, target);
    if(this.fragmentation_) {
      var fragments=this.makeFragments_(buffer, target);
      var results :ArrayBuffer[] = [];
      for(var index=0; index<fragments.length; index++) {
        var result=fragments[index].encodeFragment();
        results.push(result);
      }
      return results;
    } else {
      if (buffer.byteLength + 2 === target) {
        return [
          arraybuffers.append(arraybuffers.encodeShort(buffer.byteLength),
          buffer)
        ];
      } else if (buffer.byteLength + 2 > target) {
        return [
          arraybuffers.append(arraybuffers.encodeShort(0),
          this.randomBytes_(target))
        ];
      } else { // buffer.byteLength + 2 < target
        var result=arraybuffers.assemble([
          arraybuffers.encodeShort(buffer.byteLength),
          buffer,
          this.randomBytes_(target-buffer.byteLength-2)
        ]);
        return [result];
      }
    }
  }

  // TODO(bwiley): Support target lengths below the header length
  private makeFragments_ = (buffer:ArrayBuffer, target:number) :Fragment[] => {
    var headerLength=36;
    if (buffer.byteLength + headerLength === target) { // One fragment with no padding
//      log.debug("One fragment no padding");
      var id=Fragment.randomId();
      var index=0;
      var count=1;
      var fragment=new Fragment(
        buffer.byteLength,
        id,
        index,
        count,
        buffer,
        new ArrayBuffer(0)
      );
      return [fragment];
    } else if (buffer.byteLength + headerLength > target) {
      var firstLength=target-headerLength;
      var restLength=buffer.byteLength-firstLength;
//      log.debug("Fragment %1 %2", firstLength, restLength);
      var parts = arraybuffers.split(buffer, firstLength);
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
      var fragment=new Fragment(
        buffer.byteLength,
        id,
        index,
        count,
        buffer,
        padding
      );
      return [fragment];
    }
  }

  public restore = (buffer:ArrayBuffer) :ArrayBuffer[] => {
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
      var parts = arraybuffers.split(buffer, 2);
      var lengthBytes = parts[0];
      var length = arraybuffers.decodeShort(lengthBytes);
      var rest = parts[1];
      if(rest.byteLength > length) {
        parts=arraybuffers.split(rest, length);
  //      log.info('<- %1 %2', length, parts[0].byteLength);
        return [parts[0]];
      } else {
        return [rest];
      }
    }
  }

  // No-op (we have no state or any resources to dispose).
  public dispose = () :void => {}

  private fixFragments_ = (fragments:Fragment[]) :void => {
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
