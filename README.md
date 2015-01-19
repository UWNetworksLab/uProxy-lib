# uproxy-lib

[![Build Status](https://travis-ci.org/uProxy/uproxy-lib.svg?branch=master)](https://travis-ci.org/uProxy/uproxy-lib) [![devDependency Status](https://david-dm.org/uProxy/uproxy-lib/dev-status.svg)](https://david-dm.org/uProxy/uproxy-lib#info=devDependencies)

Distributed on NPM as [uproxy-lib](https://www.npmjs.org/package/uproxy-lib).

## What is in this directory?

This currently consists of:

 * `tools`: tools to help write other Gruntfiles (taskmanager and common grunt rules compiled as JS).
 * `src/arraybuffers`: A few handy utilties, e.g. converting ArrayBuffers to strings.
 * `src/handler`: event queue handling tool that is useful for async buffer management, e.g. in networking.
 * `src/freedom`: experimental additions to freedom used by uproxy, e.g. wrapper for `webrtc` and typescript typings
   * `src/freedom/coreproviders`: experimental additional core providers.
   * `src/freedom/interfaces`: experiments with freedom interfaces, e.g. interface for experimental `webrtc`
   * `src/freedom/samples`: freedom-sample apps, e.g. P2P chat between two peerconnections in a single chrome app.
   * `src/freedom/typings`: typescript declarations for freedom, its core-providers, and main APIs.
 * `src/logging`: handy logging library
 * `src/loggingprovider`: freedom logging provider
 * `src/taskmanager`: Smart grunt task management that avoid re-building the same components multiple times. This assumes that if a component was build once, then it never has to be build again in a single build run.
   * Note: We include the compiled `taskmanager.js`, which has source `src/taskmanager/taskmanager.ts`, so that the Gruntfile can use it. There is a special rule to rebuild this version of taskmanager. Got to love circular dependencies right?
 * `src/webrtc`: utility wrapper for WebRtc Peer Connections & Data Channels
 * `third_party`: Some third party code we use. Mostly TypeScript declarations (e.g. jasmine, WebCrypto, WebRtc, Angular, etc), and some some utility code for providing a common interface to new APIs we use (e.g. the WebRtc adaptor).

## How to use logging

* Please include "logging/logging.js" in the html file where freedom library is loaded, please make sure this loading happens before freedom code.
* In the freedom module's manifestition file where log is used, please add dependency "core.log". If your app need to access the log, you also need to include dependency of "core.logmanager"
* In freedom module code, reference the log declaration.
```
/// <reference path="../../../freedom/coreproviders/uproxylogging.d.ts" />
```
* In freedom module code, log instance can be instantiated this way (replace module_name with name of your own choice).
```
  var log :Freedom_UproxyLogging.Log = freedom['core.log']('module_name');
```
* Now following functions are available to record log messages.
```
 log.debug('simple debug message with no further argument');
 log.info('It takes args, like from %1:%2 to %1:%3', ['localhost', 3000, 3002]);
 log.warn('Warning message need some attention.');
 log.error('Error message definitely need attension from %1', [name_var]);
```

For a complete example, see: https://github.com/uProxy/uproxy-lib/tree/dev/src/freedom/samples/freedomchat-chromeapp

# Samples apps for manual testing

There are three sample apps for manual testing, with source code in:
 * `src/samples/copypaste-freedom-chat`
 * `src/samples/simple-freedom-chat`
 * `src/samples/simple-webrtc-chat`

These are run by starting a webserver and viewing the html, e.g.

````
python -m SimpleHTTPServer
```

Then goto the relevant main.html file in the relevant sample directory of: `http://localhost:8000/dist/samples/` in your web-browser. Samples should be self-explanatory. Follow instructions and type stuff in text boxes. :)
