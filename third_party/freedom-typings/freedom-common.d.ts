/// <reference path="../../../build/third_party/typings/es6-promise/es6-promise.d.ts" />

declare module freedom {
  // Common on/emit for message passing interfaces.
  interface EventDispatchFn<T> { (eventType:string, value?:T) : void; }
  interface EventHandlerFn<T> {
    (eventType:string, handler:(eventData:T) => void) : void;
  }

  interface Error {
    errcode :string;
    message :string;
  }

  // TODO: replace OnAndEmit with EventHandler and EventEmitter;
  interface OnAndEmit<T,T2> {
    on   :EventHandlerFn<T>;
    emit :EventDispatchFn<T2>;
  }

  interface EventHandler {
    // Adds |f| as an event handler for all subsiquent events of type |t|.
    on(t:string,f:Function) : void;
    // Adds |f| as an event handler for only the next event of type |t|.
    once(t:string,f:Function) : void;
    // The |off| function removes the event event handling function |f| from
    // both |on| and the |once| event handling.
    off(t:string,f:Function) : void;
  }

  interface PortModule<T,T2> extends OnAndEmit<T,T2> {
    controlChannel :string;
  }

  interface ModuleSelfConstructor {
    // Identifies a named API's provider class.
    provideSynchronous :(classFn?:Function) => void;
    provideAsynchronous :(classFn?:Function) => void;
    providePromises :(classFn?:Function) => void;
  }

  // TODO(ldixon): find out what freedom calls this and make a better name.
  // https://github.com/uProxy/uproxy/issues/853
  interface ParentModuleThing extends ModuleSelfConstructor, OnAndEmit<any,any>
    {}

  interface Logger {
    debug(...args:any[]) : void;
    info(...args:any[]) : void;
    log(...args:any[]) : void;
    warn(...args:any[]) : void;
    error(...args:any[]) : void;
  }

  // See |Core_unprivileged| in |core.unprivileged.js|
  interface Core {
    // Create a new channel which which to communicate between modules.
    createChannel() : Promise<ChannelSpecifier>;
    // Given an ChannelEndpointIdentifier for a channel, create a proxy event
    // interface for it.
    bindChannel(channelIdentifier:string) : Promise<Channel>;
    // Returns the list of identifiers describing the dependency path.
    getId() : Promise<string[]>;
    getLogger(tag:string) : Promise<Logger>;
  }

  // Channels are ways that freedom modules can send each other messages.
  interface Channel extends OnAndEmit<any,any> {
    close() : void;
  }

  // Specification for a channel.
  interface ChannelSpecifier {
    channel     :Channel;  // How to communicate over this channel.
    // A freedom channel endpoint identifier. Can be passed over a freedom
    // message-passing boundary.  It is used to create a channel to the freedom
    // module that called createChannel and created this ChannelSpecifier.
    identifier  :string;
  }

  // This is the first argument given to a core provider's constructor. It is an
  // object that describes the parent module the core provider instance has been
  // created for.
  interface CoreProviderParentApp {
    manifestId :string;
    config :{
      views :{ [viewName:string] : Object };
    };
    global :{
      removeEventListener :(s:string, f:Function, b:boolean) => void;
    };
  }

  // A Freedom module sub is both a function and an object with members. The
  // type |T| is the type of the module's stub interface.
  interface FreedomModuleFactoryManager<T> {
    // This is the factory constructor for a new instance of a stub/channel to a
    // module.
    (...args:any[]) : T;
    // This is the call to close a particular stub's channel and resources. It
    // is assumed that the argument is a result of the factory constructor. If
    // no argument is supplied, all stubs are closed.
    close :(freedomModuleStubInstance?:T) => Promise<void>;
    api   :string;
  }

  interface FreedomInCoreEnvOptions {
    debug  ?:string;  // debug level
    logger ?:string;  // string to json for logging provider.
  }

  interface FreedomInCoreEnv extends OnAndEmit<any,any> {
    // Represents the call to freedom when you create a root module. Returns a
    // promise to a factory constructor for the freedom module. The
    // |manifestPath| should be a path to a json string that specifies the
    // freedom module.
    (manifestPath:string, options?:FreedomInCoreEnvOptions)
      : Promise<FreedomModuleFactoryManager<any>>;
  }

  interface FreedomInModuleEnv {
    // Represents the call to freedom(), which returns the parent module's
    // freedom stub interface in an on/emit style. This is a getter.
    (): ParentModuleThing;

    // Creates an interface to the freedom core provider which can be used to
    // create loggers and channels.
    // Note: unlike other providers, core is a getter.
    core : FreedomModuleFactoryManager<Core>;

    // We use this specification so that you can reference freedom sub-modules by
    // an array-lookup of it's name. One day, maybe we'll have a nicer way to do
    // this.
    // TODO: explore how to use FreedomModuleFactoryManager.
    [moduleName:string] : FreedomModuleFactoryManager<any>;
  }
}

// By having both the freedom module declared above, and this quoted
// declaration, it allows a typescript <reference ...> header to be used and
// then for types to then be found by `freedom.TypeName` (e.g. in the other
// freedom typing files), as well as a using the require style inclusion of the
// importing the freedom types using a statement of the form |import
// freedomTypes = require('freedom.types');| within normal typescript code, e.g.
// see the jasmine freedom mock in mocks subdirectory of freedom.
declare module "freedom.types" {
    export = freedom;
}
