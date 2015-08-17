import logging = require('../logging/logging');
import arraybuffers = require('../arraybuffers/arraybuffers');
import Fragment = require('./fragment');

var log :logging.Log = new logging.Log('fancy-transformers');

// The Defragmenter collects fragmented packets in a buffer and defragments them.
// Currently no cache expiration has been implemented, so fragments are stored
// forever, leaking memory.
// TODO(bwiley): Add cache expiration
class Defragmenter {
  private tracker_ :{[index:string]:ArrayBuffer[]}={};
  private counter_ :{[index:string]:number}={};
  private complete_:string[]=[];

  public constructor() {}

  public addFragment(fragment:Fragment) {
    var hexid=arraybuffers.arrayBufferToHexString(fragment.id);
     // A fragment for an existing packet
    if(hexid in this.tracker_) {
      var fragments :ArrayBuffer[]=this.tracker_[hexid];
      // Duplicate fragment
      if(fragments[fragment.index]!==null) {
        log.info('Duplicate fragment %1: %2 / %3', hexid, fragment.index, fragment.count);
      } else {
        // New fragment
        fragments[fragment.index]=fragment.payload;
        this.tracker_[hexid]=fragments;
        this.counter_[hexid]=this.counter_[hexid]-1;
        if(this.counter_[hexid]===0) {
          this.complete_.push(hexid);
        }
      }
    } else {
      // A fragment for a new packet
      var fragments :ArrayBuffer[]=[];
      for(var i=0; i<fragment.count; i++) {
        fragments.push(null);
      }

      fragments[fragment.index]=fragment.payload;
      this.tracker_[hexid]=fragments;
      this.counter_[hexid]=fragment.count-1;
      if(this.counter_[hexid]===0) {
        this.complete_.push(hexid);
      }
    }
  }

  public completeCount = () :number => {
    return this.complete_.length;
  }

  public getComplete = () :ArrayBuffer[] => {
    var packets :ArrayBuffer[] = [];

    for(var i=0; i<this.complete_.length; i++) {
      var hexid=this.complete_.pop();
      var fragments=this.tracker_[hexid];
      if(fragments !== null && fragments.length > 0) {
        var packet = arraybuffers.assemble(fragments);
//        log.debug('pushing packet %1', packet.byteLength);
        packets.push(packet);
      }
    }

    return packets;
  }
}

export = Defragmenter;
