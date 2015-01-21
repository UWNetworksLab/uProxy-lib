/// <reference path='../../jasmine/jasmine.d.ts' />
/// <reference path="../../es6-promise/es6-promise.d.ts" />
/// <reference path="../freedom-common.d.ts" />

import freedomTypes = require('freedom.i');

export class MockParentModuleThing implements freedomTypes.ParentModuleThing {
  public on(t:string, f:Function) : void {
    throw new Error('not implemented in mock');
  }
  public emit(t:string, x:any) : void {
    throw new Error('not implemented in mock');
  }
  public provideSynchronous(classFn:Function) : void {
    throw new Error('not implemented in mock');
  }
  public provideAsynchronous(classFn:Function) : void {
    throw new Error('not implemented in mock');
  }
  public providePromises(classFn:Function) : void {
    throw new Error('not implemented in mock');
  }
}

export class MockFreedomCore implements freedomTypes.Core {
  public getLogger(loggerName:string) : Promise<freedomTypes.Logger> {
    throw new Error('not implemented in mock');
  }
  public createChannel() : Promise<freedomTypes.ChannelSpecifier>{
    throw new Error('not implemented in mock');
  }
  public bindChannel(channelIdentifier:string) : Promise<freedomTypes.Channel> {
    throw new Error('not implemented in mock');
  }
  public getId() : Promise<string[]> {
    throw new Error('not implemented in mock');
  }
}

export function makeMockFreedomInModuleEnv() : freedomTypes.FreedomInModuleEnv {
  // Each freedom() call in a module env gives a new on/emit interface.
  var freedom : any = () => {
    return new MockParentModuleThing();
  }

  // Note: unlike other freedom
  var core_ = new MockFreedomCore();
  freedom['core'] = () => { return core_; }

  freedom['provideSynchronous'] = () => {
    throw new Error('not implemented in mock');
  };
  freedom['provideAsynchronous'] = () => {
    throw new Error('not implemented in mock');
  };
  freedom['providePromise'] = () => {
    throw new Error('not implemented in mock');
  };

  return freedom;
}
