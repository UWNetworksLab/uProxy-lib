import logging = require('../logging/logging');

var log :logging.Log = new logging.Log('fancy-transformers');

// http://www.arturocampos.com/ac_arithmetic.html
// http://www.arturocampos.com/ac_range.html

var max = (items:number[]) : number => {
  var highest : number = 0;
  for(var i=0; i<items.length; i++) {
    if(items[i]>highest) {
      highest=items[i];
    }
  }

  return highest;
}

var sum = (items:number[]) : number => {
  var total : number = 0;
  for(var i=0; i<items.length; i++) {
    total=total+items[i];
  }

  return total;
}

var scale = (items:number[], divisor:number) : number[] => {
  for(var i=0; i<items.length; i++) {
    items[i]=Math.floor(items[i]/divisor);
    if(items[i]==0) {
      items[i]=1;
    }
  }

  return items;
}

var saveProbs = (items:number[]) : ArrayBuffer => {
  var bytes=new Uint8Array(items.length);
  for(var index=0; index<items.length; index++) {
    bytes[index]=items[index];
  }
  return bytes.buffer;
}

export class Coder {
  public probabilities_ : number[];
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
  public intervals_ : {[index: number]: Interval}={};
  public total_ : number;
  public input_ : number[] = [];
  public output_ : number[] = [];

  public constructor(probs:number[]) {
    this.probabilities_=this.adjustProbs_(probs);

    var low=0;
    for(var index=0; index<probs.length; index++) {
      this.intervals_[index]=new Interval(index, low, probs[index]);
      low=low+probs[index];
    }

    this.total_ = sum(this.probabilities_);
  }

  private adjustProbs_ = (probs:number[]) : number[] => {
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
  public encode = (input:ArrayBuffer) : ArrayBuffer => {
    this.init_();

    var bytes=new Uint8Array(input);
    for(var index=0; index<bytes.length; index++) {
      this.encodeSymbol_(bytes[index]);
    }

    var output=new Uint8Array(this.output_.length);
    for(index=0; index<this.output_.length; index++) {
      output[index]=this.output_[index];
    }
    console.log('encoded '+input.byteLength.toString()+' '+output.byteLength.toString());
    return output.buffer;
  }

  private init_ = () : void => {
    this.low_ = 0;
    this.range_ = this.top_value_;
    this.working_ = 0;
    this.underflow_ = 0;
  }

  private encodeSymbol_ = (symbol:number) => {
    var interval = this.intervals_[symbol];

    this.renormalize_();
    var newRange = this.range_ / this.total_;
    var temp = newRange * interval.low;
    if(interval.high < this.total_) {
      this.range_=newRange*interval.length;
    } else {
      this.range_ = this.range_ + temp;
    }

    this.low_ = this.low_ + temp;
  }

  private renormalize_ = () : void => {
    while(this.range_ <= this.bottom_value_) {
      if(this.low_ < (0xFF << this.shift_bits_)) {
        this.output_.push(this.working_);
        for(; this.underflow_!=0; this.underflow_=this.underflow_-1) {
          this.output_.push(0xFF);
        }
        this.working_=this.low_ >>> this.shift_bits_;
      } else {
        if((this.low_ & this.top_value_) != 0) {
          this.output_.push(this.working_+1);
          for(; this.underflow_!=0; this.underflow_=this.underflow_-1) {
            this.output_.push(0x00);
          }
        } else {
          this.working_=this.working_+1;
        }

        this.working_=this.low_ >>> this.shift_bits_;
      }

      this.range_ = (this.range_ << 8) >>> 0;
      this.low_ = ((this.low_ << 8) & (this.top_value_ - 1)) >>> 0;
    }
  }


  private flush = () : void => {
    this.renormalize_();
    var temp = this.low_ >>> 23;
    if(temp > 0xFF) {
      this.output_.push(this.working_+1);
      for(; this.underflow_!=0; this.underflow_=this.underflow_-1) {
        this.output_.push(0x00);
      }
    } else {
      this.output_.push(this.working_);
      for(; this.underflow_!=0; this.underflow_=this.underflow_-1) {
        this.output_.push(0xFF);
      }
    }

    this.output_.push(temp & 0xFF);
    this.output_.push((this.low_ >>> (23-8)) & 0xFF);
  }
}

export class Decoder extends Coder {
  constructor(probs:number[]) {
    super(probs);
  }

  public decode = (input:ArrayBuffer) : ArrayBuffer => {
    this.init_();

    var bytes=new Uint8Array(input);
    for(var index=0; index<bytes.length; index++) {
      this.decodeSymbol_(bytes[index]);
    }

    var output=new Uint8Array(this.output_.length);
    for(index=0; index<this.output_.length; index++) {
      output[index]=this.output_[index];
    }
    return output.buffer;
  }

  private init_ = () : void => {
    this.working_ = this.input_.shift();
    this.low_ = this.working_ >>> (8 - this.extra_bits_);
    this.range_ = 1 << this.extra_bits_;
  }

  private decodeSymbol_ = (symbol:number) : number => {
    this.renormalize_();
    this.underflow_=this.range_/this.total_;
    var temp=this.low_/this.underflow_;
    if(temp > this.total_) {
      return this.total_;
    } else {
      return temp;
    }
  }

  private renormalize_ = () : void => {
    while(this.range_ <= this.bottom_value_) {
      this.low_=(this.low_ << 8) | ((this.working_ << this.extra_bits_) & 0xFF);
      this.working_ = this.input_.shift();
      this.low_ = this.low_ | (this.working_ >>> (8-this.extra_bits_));
      this.range_ = (this.range_ << 8) >>> 0;
    }
  }

  private update_ = (symbol:number) : void => {
    var interval = this.intervals_[symbol];
    var temp = this.underflow_ * interval.low;
    this.low_ = this.low_ - temp;
    if(interval.high < this.total_) {
      this.range_=this.underflow_*interval.length;
    } else {
      this.range_=this.range_-temp;
    }
  }

  private flush_ = () : void => {
    this.renormalize_();
  }
}

export class Interval {
  public symbol : number;
  public high: number;
  public low: number;
  public length: number;

  constructor(symbol:number, low:number, length:number) {
    this.symbol=symbol;
    this.low=low;
    this.length=length;
    this.high=this.low+this.length;
  }
}
