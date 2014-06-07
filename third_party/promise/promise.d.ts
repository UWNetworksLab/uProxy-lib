// Based on http://www.html5rocks.com/en/tutorials/es6/promises/#toc-api
// Promise Spec: http://promises-aplus.github.io/promises-spec/

/**
 * Generic Errors that may have a stack attribute (as they do in JS).
 **/
interface Error {
  stack?:any;  // TODO: fix `any` and
}

/**
 * Generic Thenable objects have a `then` type that can be `fulfilled` or
 * `rejected`.
 **/
interface Thenable<T> {
  then:(fulfill:(t?:T) => void,
        reject?:(e:Error) => void) => Thenable<T>;
}

/**
 * Generic Promise for built-in js Promises. T is the `fullfillment object type`
 * type. The rejection object should always be javascript Error.
 */
declare class Promise<T> {
  constructor(resolverFunction:(fulfill:(t?:T) => void,
                                reject:(e:Error) => void) => void);

  // then either returns subsiquent promise<T2> ...
  then<T2>(fulfill:(t?:T) => Promise<T2>, reject?:(e:Error) => Promise<T2>)
      : Promise<T2>;
  // ... or the next fulfillment object directly ...
  then<T2>(fulfill:(t?:T) => T2, reject?:(e:Error) => T2) : Promise<T2>;
  // ... or full and error handlers return void.
  then(fulfill:(t?:T) => void, reject?:(e:Error) => void) : Promise<void>;

  catch(catchFn:(e:Error) => Promise<T>) : Promise<T>;
  catch(catchFn:(e:Error) => T) : Promise<T>;
  catch(catchFn:(e:Error) => void) : Promise<void>;

  static resolve<T>(thenable:Thenable<T>) : Promise<T>;
  static resolve<T>(t:T) : Promise<T>;
  static resolve() : Promise<void>;

  static reject<T>(e:Error) : Promise<T>;
  // Allow casting of Promise.reject to Promise<void>.
  static reject() : Promise<void>;

  static all<T>(promiseArray:Thenable<T>[]) : Promise<T>;
  static race<T>(...args:Thenable<T>[]) : Promise<T>;
}
