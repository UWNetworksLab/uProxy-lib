// Based on http://www.html5rocks.com/en/tutorials/es6/promises/#toc-api
// Promise Spec: http://promises-aplus.github.io/promises-spec/

// This file is part of the uProxy project, it's in this directory for ease of
// reference and because we plan to move it to DefinitelyTyped.
//
// TODO: Unlike the version in DefinitelyTypes, we would like to represent the
// rejection error explicitly. The definitely Types version is here:
//
//   https://github.com/borisyankov/DefinitelyTyped/blob/master/es6-promises/es6-promises.d.ts
//
// We also provide some convenience functions that admit the type parameters and
// use common defaults (void and Error).

// Generic Errors that may have a stack attribute (as they do in JS).
interface Error {
  stack?:any;  // TODO: fix `any`.
}

// Generic Thenable objects have a `then` type that can be `fulfilled` by an
// object of type T or `rejected` with an error of type E.
interface Thenable<T> {
  then<T2>(fulfill:(t?:T) => Thenable<T2>,
           reject?:(e:Error) => Thenable<T2>) : Thenable<T2>;
  then<T2>(fulfill:(t?:T) => T2,
           reject?:(e:Error) => T2) : Thenable<T2>;
  then(fulfill:(t?:T) => void,
       reject?:(e:Error) => void) : Thenable<void>;
}

// Generic typing for built-in JS Promises. T is the `fullfillment object type`
// type and E is the error type.
declare class Promise<T> implements Thenable<T> {
  constructor(resolverFunction:(fulfill:(t?:T) => void,
                                reject:(e:Error) => void) => void);

  then<T2>(fulfill:(t?:T) => Promise<T2>,
           reject?:(e:Error) => Thenable<T2>) : Promise<T2>;
  then<T2>(fulfill:(t?:T) => T2,
           reject?:(e:Error) => T2) : Promise<T2>;
  then(fulfill:(t?:T) => void,
       reject?:(e:Error) => void) : Promise<void>;

  catch(catchFn:(e:Error) => Promise<T>) : Promise<T>;
  catch(catchFn:(e:Error) => T) : Promise<T>;
  catch(catchFn:(e:Error) => void) : Promise<void>;

  static resolve<T>(p:Thenable<T>) : Promise<T>;
  static resolve<T>(t:T) : Promise<T>;
  static resolve() : Promise<void>;

  static reject<T>(e:Error) : Promise<T>;
  static reject() : Promise<void>;

  static all<T>(ps:Thenable<T>[]) : Promise<T[]>;
  static all(ps:Thenable<void>[]) : Promise<void[]>;
  static race<T>(ps:Thenable<T>[]) : Promise<T>;
  static race(ps:Thenable<void>[]) : Promise<void>;
}
