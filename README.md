# uproxy-lib

[![Build Status](https://travis-ci.org/uProxy/uproxy-lib.svg?branch=master)](https://travis-ci.org/uProxy/uproxy-lib) [![devDependency Status](https://david-dm.org/uProxy/uproxy-lib/dev-status.svg)](https://david-dm.org/uProxy/uproxy-lib#info=devDependencies)

Distributed on NPM as [uproxy-lib](https://www.npmjs.org/package/uproxy-lib).

This currently consists of:

 * `arraybuffers`: A few handy utilties, e.g. converting ArrayBuffers to strings.
 * `coreproviders`: experiments with freedom core providers, e.g. wrapper for peerconnection
 * `handler`: event queue handling tool that is useful for async buffer management, e.g. in networking.
 * `freedom-declarations`: typescript declarations for freedom, its core-providers, and main APIs
 * `logger`: handy freedom module logging library
 * `peerconnection`: utility wrapper for WebRtc Peer Connection interface for data channels
 * `samples`: sample test applications (webpages, chrome apps, etc) for the various libraries.
 * `taskmanager`: Smart grunt task management that avoid re-building the same components multiple times. This assumes that if a component was build once, then it never has to be build again in a single build run.
   * Note: We include the compiled `taskmanager.js`, which has source `src/taskmanager/taskmanager.ts`, so that the Gruntfile can use it. There is a special rule to rebuild this version of taskmanager. Got to love circular dependencies right?
 * `third_party`: Some third party TypeScript interfaces (jasmine) for testing, including our version of an (stricter) typescript promise interface.
