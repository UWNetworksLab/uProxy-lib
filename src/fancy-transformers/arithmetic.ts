import logging = require('../logging/logging');

var log :logging.Log = new logging.Log('fancy-transformers');

import arraybuffers = require('../arraybuffers/arraybuffers');

// http://www.arturocampos.com/ac_arithmetic.html
// http://www.arturocampos.com/ac_range.html

var max = (items:number[]) :number => {
  var highest :number = 0;
  for(var i=0; i<items.length; i++) {
    if(items[i]>highest) {
      highest=items[i];
    }
  }

  return highest;
}

var sum = (items:number[]) :number => {
  var total :number = 0;
  for(var i=0; i<items.length; i++) {
    total=total+items[i];
  }

  return total;
}

var scale = (items:number[], divisor:number) :number[] => {
  for(var i=0; i<items.length; i++) {
    items[i]=Math.floor(items[i]/divisor);
    if(items[i]===0) {
      items[i]=1;
    }
  }

  return items;
}

var saveProbs = (items:number[]) :ArrayBuffer => {
  var bytes=new Uint8Array(items.length);
  for(var index=0; index<items.length; index++) {
    bytes[index]=items[index];
  }
  return bytes.buffer;
}

export class Coder {
  public probabilities_ :number[];
  public code_bits_ = 32;
  public top_value_ = Math.pow(2, this.code_bits_-1);
  public shift_bits_ = (this.code_bits_ - 9);
  public extra_bits_ = ((this.code_bits_-2) % 8 + 1);
  public bottom_value_ = (this.top_value_ >>> 8);
  public max_int_ = Math.pow(2, this.code_bits_) - 1;

  public low_= 0x00000000;
  public high_ = 0xFFFFFFFF;
  public range_ = 0;
  public underflow_ = 0;
  public working_ = 0;
  public intervals_ :{[index:number]:Interval}={};
  public total_ :number;
  public input_ :number[] = [];
  public output_ :number[] = [];

  public constructor(probs:number[]) {
    this.probabilities_=this.adjustProbs_(probs);

    var low=0;
    for(var index=0; index<probs.length; index++) {
      this.intervals_[index]=new Interval(index, low, probs[index]);
      low=low+probs[index];
    }

    this.total_ = sum(this.probabilities_);
  }

  private adjustProbs_ = (probs:number[]) :number[] => {
    var maxProb = max(probs);
    if(maxProb>255) {
      var divisor=maxProb/256;
      probs=scale(probs, divisor);
    }
    while(sum(probs)>=16384) {// 2^14
      probs=scale(probs, 2);
    }

    return probs;
  }
}

export class Encoder extends Coder {
  private target_ :Uint8Array=new Uint8Array(arraybuffers.hexStringToArrayBuffer('ca.0.1.0.5c.21.12.a4.42.48.4e.43.6a.4e.47.54.66.37.31.45.42.0.6.0.21.34.47.4a.39.65.49.69.4d.75.59.55.35.43.38.49.6a.3a.69.7a.72.51.34.77.72.57.66.70.31.6b.57.66.44.64.0.0.0.80.29.0.8.9a.85.cd.95.50.c8.ee.a.0.24.0.4.6e.7e.1e.ff.0.8.0.14.3.45.95.42.22.f0.da.66.3e.8e.b8.cc.79.a1.f7.ba.1.f.d5.0.80.28.0.4.e2.28.43.3.0.0.0.74'));

  public encode = (input:ArrayBuffer) :ArrayBuffer => {
    this.init_();

    var bytes=new Uint8Array(input);
    for(var index=0; index<bytes.length; index++) {
      this.encodeSymbol_(bytes[index]);
    }

    this.flush_();

    var output=new Uint8Array(this.output_.length);
    for(index=0; index<this.output_.length; index++) {
      output[index]=this.output_[index];
    }
//    console.log('encoded '+input.byteLength.toString()+' '+output.byteLength.toString());
    return output.buffer;
  }

  private init_ = () :void => {
    this.low_ = 0;
    this.range_ = this.top_value_;
    this.working_ = 0xCA;
    this.underflow_ = 0;
    this.input_=[];
    this.output_=[];
//    log.debug('old state %1 %2 %3 %4', this.low_, this.range_, this.working_, this.underflow_);
  }

  /*private encodeSymbol_ = (symbol:number) => {
    var interval = this.intervals_[symbol];

    console.log('encoding ', symbol, interval.low, interval.length, this.total_);

    this.renormalize_();
    var newRange = this.range_ / this.total_;
    var temp = newRange * interval.low;
    if(interval.high < this.total_) {
      this.range_=newRange*interval.length;
    } else {
      this.range_ = this.range_ + temp;
    }

    this.low_ = this.low_ + temp;

    console.log('new state ', this.low_, this.range_, this.working_, this.underflow_);
  }*/

  /*private encodeSymbol_ = (symbol:number) => {
    var interval = this.intervals_[symbol];

    console.log('encoding ', symbol, interval.low, interval.length, this.total_);

    this.renormalize_();
    var newRange = (this.range_ / this.total_) >>> 0;
    var temp = newRange * interval.low;

    if(interval.high < this.total_) {
      this.range_=newRange*interval.length;
    } else {
      this.range_ = this.range_ + temp;
    }

    this.low_ = this.low_ + temp;

    console.log('new state ', this.low_, this.range_, this.working_, this.underflow_);
  }*/

  private encodeSymbol_ = (symbol:number) => {
    var interval = this.intervals_[symbol];

//    console.log('encoding ', symbol, interval.low, interval.length, this.total);
//    console.log('encoding ', symbol);

    this.renormalize_();
//    console.log('renormalized ', this.low_, this.range_, this.working_, this.underflow_);
    var newRange = this.range_ >>> 8;
    var temp = newRange * interval.low;

    if((interval.high >>> 8) > 0) {
      this.range_ = this.range_ - temp;
    } else {
      this.range_=newRange*interval.length;
    }

    this.low_ = this.low_ + temp;

//    console.log('new state ', this.low_, this.range_, this.working_, this.underflow_);
  }

  private renormalize_ = () :void => {
//    console.log('->r');
    while(this.range_ <= this.bottom_value_) {
//      console.log('loop');
      if(this.low_ < (0xFF << this.shift_bits_)) {
//        console.log('1');
        this.write_(this.working_);
        for(; this.underflow_!==0; this.underflow_=this.underflow_-1) {
          this.write_(0xFF);
        }
        this.working_=(this.low_ >>> this.shift_bits_) & 0xFF;
      } else if((this.low_ & this.top_value_) !== 0) {
//          console.log('2');
          this.write_(this.working_+1);
          for(; this.underflow_!==0; this.underflow_=this.underflow_-1) {
            this.write_(0x00);
          }

          this.working_=(this.low_ >>> this.shift_bits_) & 0xFF;
      } else {
//          console.log('3');
          this.underflow_=this.underflow_+1;
      }

      this.range_ = (this.range_ << 8) >>> 0;
      this.low_ = ((this.low_ << 8) & (this.top_value_ - 1)) >>> 0;
    }
//    console.log('<-r');
  }


  private flush_ = () :void => {
    this.renormalize_();
    var temp = this.low_ >>> this.shift_bits_;
    if(temp > 0xFF) {
//      log.debug('#2');
      this.write_(this.working_+1);
      for(; this.underflow_!==0; this.underflow_=this.underflow_-1) {
        this.write_(0x00);
      }
    } else {
//      log.debug('#3');
      this.write_(this.working_);
      for(; this.underflow_!==0; this.underflow_=this.underflow_-1) {
        this.write_(0xFF);
      }
    }

    this.write_(temp & 0xFF);
    this.write_((this.low_ >>> (23-8)) & 0xFF);
  }

  private write_ = (byte:number) :void => {
    this.output_.push(byte);
    if(this.target_[this.output_.length-1]!==byte) {
      console.log('SYNC ERROR ', this.output_.length-1, this.target_[this.output_.length-1], byte);
    }
  }
}

export class Decoder extends Coder {
  constructor(probs:number[]) {
    super(probs);
  }

  public decode = (input:ArrayBuffer) :ArrayBuffer => {
    this.input_=[];

    var bytes=new Uint8Array(input);
    for(var index=0; index<bytes.length; index++) {
      this.input_.push(bytes[index]);
    }

    this.init_();
    this.decodeSymbols_();
    this.flush_();

    var output=new Uint8Array(this.output_.length);
    for(index=0; index<this.output_.length; index++) {
      output[index]=this.output_[index];
    }

    return output.buffer;
  }

  private init_ = () :void => {
    var discard=this.input_.shift(); // discard first byte because the encoder is weird
    log.debug('discarding %1', discard);
    this.working_ = this.input_.shift();
    log.debug('read %1', this.working_);
    this.low_ = this.working_ >>> (8 - this.extra_bits_);
    this.range_ = 1 << this.extra_bits_;
    this.underflow_ = 0;
    this.output_=[];
    log.debug('old state %1 %2 %3 %4', this.low_, this.range_, this.working_, this.underflow_);
  }

  private decodeSymbols_ = () :void => {
    while(this.input_.length > 0) {
      this.decodeSymbol_();
    }
  }

  /*private decodeSymbol_ = () :void => {
    this.renormalize_();
    this.underflow_=(this.range_/this.total_) >>> 0;
    var temp=(this.low_/this.underflow_) >>> 0;
    var result :number = null;
    if(temp > this.total_) {
      result=this.total_;
    } else {
      result=temp;
    }

    this.output_.push(result);
    this.update_(result);

    log.debug('new state %1 %2 %3 %4', this.low_, this.range_, this.working_, this.underflow_);
  }*/

  private decodeSymbol_ = () :void => {
    log.debug('<r %1 %2 %3 %4', this.low_, this.range_, this.working_, this.underflow_);
    this.renormalize_();
    log.debug('>r %1 %2 %3 %4', this.low_, this.range_, this.working_, this.underflow_);
    this.underflow_=this.range_ >>> 8;
    var temp=(this.low_/this.underflow_) >>> 0;
    var result :number = null;
    if(temp>>>8===0) {
      result=temp;
    } else {
      result=(1<<8)-1;
    }

    this.output_.push(result);
    this.update_(result);

    log.debug('new state %1 %2 %3 %4', this.low_, this.range_, this.working_, this.underflow_);
  }

  private renormalize_ = () :void => {
    while(this.range_ <= this.bottom_value_) {
      this.low_=(this.low_ << 8) | ((this.working_ << this.extra_bits_) & 0xFF);
      if(this.input_.length>0) {
        this.working_ = this.input_.shift();
      } else {
        this.working_=0;
      }
      log.debug('read byte %1', this.working_);
      this.low_ = (this.low_ | (this.working_ >>> (8-this.extra_bits_)));
      this.low_ = this.low_ >>> 0;
      this.range_ = (this.range_ << 8) >>> 0;
    }
  }

  private update_ = (symbol:number) :void => {
    var interval = this.intervals_[symbol];
    log.debug('decoding %1 %2 %3 %4', symbol, interval.length, interval.low, this.total_);
    var temp = this.underflow_ * interval.low;
    this.low_ = this.low_ - temp;
    if(interval.high < this.total_) {
      this.range_=this.underflow_*interval.length;
    } else {
      this.range_=this.range_-temp;
    }
  }

  private flush_ = () :void => {
    this.decodeSymbol_();
    this.renormalize_();
  }
}

export class Interval {
  public symbol :number;
  public high:number;
  public low:number;
  public length:number;

  constructor(symbol:number, low:number, length:number) {
    this.symbol=symbol;
    this.low=low;
    this.length=length;
    this.high=this.low+this.length;
  }
}
