// Logging Client, exposes tagged logging capabilities to modules.
//
// All timestamps are in the core environments runtime.
declare module Logging {
  // Example use for a core-provider or core runtime code that uses it:
  // var logger :Logging.Logger = new Logging.Log('my_tag');
  class Log {
    constructor(tag_:string);
    debug(arg :Object, ...args :Object[]) :void;
    info(arg :Object, ...args :Object[]) :void;
    warn(arg :Object, ...args :Object[]) :void;
    error(arg :Object, ...args :Object[]) :void;
  }
}
