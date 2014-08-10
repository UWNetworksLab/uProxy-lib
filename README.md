# uproxy-lib

[![Build Status](https://travis-ci.org/uProxy/uproxy-lib.svg?branch=master)](https://travis-ci.org/uProxy/uproxy-lib) [![devDependency Status](https://david-dm.org/uProxy/uproxy-lib/dev-status.svg)](https://david-dm.org/uProxy/uproxy-lib#info=devDependencies)

Distributed on NPM as [uproxy-lib](https://www.npmjs.org/package/uproxy-lib).

This currently consists of:

 * `tools`: tools to help write other Gruntfiles (taskmanager and common grunt rules compiled as JS).
 * `src/arraybuffers`: A few handy utilties, e.g. converting ArrayBuffers to strings.
 * `src/freedom/coreproviders`: experiments with freedom core providers, e.g. wrapper for `webrtc`
 * `src/handler`: event queue handling tool that is useful for async buffer management, e.g. in networking.
 * `src/freedom/typings`: typescript declarations for freedom, its core-providers, and main APIs
 * `src/logging`: handy logging library
 * `src/webrtc`: utility wrapper for WebRtc Peer Connections & Data Channels
 * `src/taskmanager`: Smart grunt task management that avoid re-building the same components multiple times. This assumes that if a component was build once, then it never has to be build again in a single build run.
   * Note: We include the compiled `taskmanager.js`, which has source `src/taskmanager/taskmanager.ts`, so that the Gruntfile can use it. There is a special rule to rebuild this version of taskmanager. Got to love circular dependencies right?
 * `third_party`: Some third party code we use. Mostly TypeScript declarations (e.g. jasmine, WebCrypto, WebRtc, Angular, etc), and some some utility code for providing a common interface to new APIs we use (e.g. the WebRtc adaptor).
