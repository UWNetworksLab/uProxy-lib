# uproxy-lib

[![Build Status](https://travis-ci.org/uProxy/uproxy-lib.svg?branch=master)](https://travis-ci.org/uProxy/uproxy-lib) [![devDependency Status](https://david-dm.org/uProxy/uproxy-lib/dev-status.svg)](https://david-dm.org/uProxy/uproxy-lib#info=devDependencies)

Distributed on NPM as [uproxy-lib](https://www.npmjs.org/package/uproxy-lib).

## What is in this directory?

This currently consists of:

 * `tools`: tools to help write other Gruntfiles (taskmanager and common grunt rules compiled as JS).
 * `src/arraybuffers`: A few handy utilties, e.g. converting ArrayBuffers to strings.
 * `src/crypto`: Misc crypto/random/hash related helper functions
 * `src/handler`: event queue handling tool that is useful for async buffer management, e.g. in networking.
 * `src/freedom`: experimental additions to freedom used by uproxy, e.g. wrapper for `webrtc` and typescript typings
   * `src/freedom/mocks`: mocks for freedom
   * `src/freedom/sample-code`: some small examples to test that the typescript typings files work.
   * `src/freedom/typings`: typescript declarations for freedom, its core-providers, and main APIs.
 * `src/logging`: handy logging library
 * `src/loggingprovider`: freedom logging provider
 * `src/build-tools`: Helpers for the Gruntfule. Including smart grunt task management that avoid re-building the same components multiple times. This assumes that if a component was build once, then it never has to be build again in a single build run.
   * Note: We include the compiled files in the `tools/` directory, which has source `src/build-tools/*.ts`, so that the Gruntfile can use it. There is a special target (tools) to rebuild the tools. Got to love circular dependencies right?
 * `src/webrtc`: utility wrapper for WebRtc Peer Connections & Data Channels
 * `third_party`: contains third party code, mostly references to external typescript declaration files for things like jasmine, node, etc.

## Logging

The combination of `src/logging` and `src/loggingprovider` provide support for logging within freeom modules. For a complete example, see: https://github.com/uProxy/uproxy-lib/tree/dev/src/samples/simple-freedom-chat

# Samples apps for manual testing

There are three sample apps for manual testing, with source code in:
 * `src/samples/copypaste-freedom-chat`
 * `src/samples/simple-freedom-chat`

These are run by starting a webserver and viewing the html, e.g.

````
python -m SimpleHTTPServer
```

Then goto the relevant main.html file in the relevant sample directory of: `http://localhost:8000/build/dev/samples/` in your web-browser. Samples should be self-explanatory. Follow instructions and type stuff in text boxes. :)
