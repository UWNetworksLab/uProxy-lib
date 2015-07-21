import logging = require('../logging/logging');
import Fragment = require('./fragment');

var log :logging.Log = new logging.Log('fancy-transformers');

class Defragmenter {
  private tracker_ : {[index: number]: ArrayBuffer[]}={};
  private counter_ : {[index: number]: number}={};
  private complete_: number[]=[];

  public constructor() {}

  public addFragment(fragment:Fragment) {
    if(fragment.id in this.tracker_) { // A fragment for an existing packet
      var fragments : ArrayBuffer[]=this.tracker_[fragment.id];
      if(fragments[fragment.index]!=null) { // Duplicate fragment
        log.info('Duplicate fragment %1: %2 / %3', fragment.id, fragment.index, fragment.count);
      } else { // New fragment
        fragments[fragment.index]=fragment.payload;
        this.tracker_[fragment.id]=fragments;
        this.counter_[fragment.id]=this.counter_[fragment.id]-1;
        if(this.counter_[fragment.id]==0) {
          this.complete_.push(fragment.id);
        }
      }
    } else { // A fragment for a new packet
      var fragments : ArrayBuffer[]=[];
      for(var i=0; i<fragment.count; i++) {
        fragments.push(null);
      }

      fragments[fragment.index]=fragment.payload;
      this.tracker_[fragment.id]=fragments;
      this.counter_[fragment.id]=fragment.count-1;
      if(this.counter_[fragment.id]==0) {
        this.complete_.push(fragment.id);
      }
    }
  }

  public completeCount = () : number => {
    return this.complete_.length;
  }

  public getComplete = () : ArrayBuffer[] => {
    if(this.complete_.length > 0) {
      var packets : ArrayBuffer[] = [];
      for(var i=0; i<this.complete_.length; i++) {
        var id=this.complete_.pop();
        var fragments=this.tracker_[id];
        if(fragments != null && fragments.length > 0) {
          var packet = this.assemble_(fragments);
          packets.push(packet);
        }
      }

      return packets;
    }

    return null;
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
        bytes[toIndex]=bytes[fromIndex];
      }
    }

    return bytes.buffer;
  }
}

export = Defragmenter;
