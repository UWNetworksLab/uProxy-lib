/// <reference path='../../jasmine/jasmine.d.ts' />
/// <reference path="../../es6-promise/es6-promise.d.ts" />
/// <reference path="../freedom-common.d.ts" />

export function makeFakeFreedomInModuleEnv() : freedom.FreedomInModuleEnv {
  var freedom = <any>jasmine.createSpy('freedom');
  freedom.and.returnValue(jasmine.createSpyObj('freedom', ['on','emit']));
  freedom['core'] = jasmine.createSpy('core');
  freedom['core'].and.returnValue(jasmine.createSpyObj(
      'core', ['getLogger', 'createChannel', 'bindChannel']));
  freedom['core.console'] = jasmine.createSpy('core.console');
  freedom['core.console'].and.returnValue(jasmine.createSpyObj(
      'core.console', ['debug', 'log', 'info', 'warn', 'error']));
  freedom['provideSynchronous'] = jasmine.createSpy('provideSynchronous');

  return freedom;
}
