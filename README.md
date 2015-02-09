# uproxy-lib

[![Build Status](https://travis-ci.org/uProxy/uproxy-lib.svg?branch=master)](https://travis-ci.org/uProxy/uproxy-lib) [![devDependency Status](https://david-dm.org/uProxy/uproxy-lib/dev-status.svg)](https://david-dm.org/uProxy/uproxy-lib#info=devDependencies)

Distributed on NPM as [uproxy-lib](https://www.npmjs.org/package/uproxy-lib).

## Using uProxy-lib

When distributed as an NPM module, uproxy-lib uses semantic versioning and considers all files in `build/tools`, `build/dist` and `build/third_party` to be part of the uproxy-lib API. That means paths to these will only change on a major version increase (and will be stable w.r.t. minor and patch version increases).

Other paths in `build` such as `build/dev` are ignored when published via NPM (using the `.npmignore` file).

## Setup

Just run the install script:

```
./setup.sh install
```

This will install npm modules (in `node_modules`), install typescript definitions (in `build/third_party/typings`), and build the build-tools (into `build/tools`) (It also prints out the commands it runs so you can understand what it is doing if you need/want to).

After this script runs successfully, it should print out: `Successfully completed install of dev dependencies.`

If you just want to cleanup from a partial or broken build, you can run:
```
rm -r build/dev build/dist .tscache src/.baseDir
```
or
```
grunt clean
```

If you need to also start with just fresh development depndencies, you can run:
```
./setup.sh clean
```
That will remove all build directories and installed dependencies, including NPM modules.

## What is in this directory?

This currently consists of:

 * `tools`: contains helper shell scripts (currently to support integration testing using docker).
 * `src/arraybuffers`: A few handy utilties, e.g. converting ArrayBuffers to strings.
 * `src/crypto`: Misc crypto/random/hash related helper functions
 * `src/handler`: event queue handling tool that is useful for async buffer management, e.g. in networking.
 * `src/freedom`: experimental additions to freedom used by uproxy, e.g. wrapper for `webrtc` and typescript typings
   * `src/freedom/mocks`: mocks for freedom
   * `src/freedom/sample-code`: some small examples to test that the typescript typings files work.
   * `src/freedom/typings`: typescript declarations for freedom, its core-providers, and main APIs.
 * `src/logging`: handy logging library
 * `src/loggingprovider`: freedom logging provider
 * `src/tools`: Helpers for the Gruntfule. Including smart grunt task management that avoid re-building the same components multiple times. This assumes that if a component was build once, then it never has to be build again in a single build run.
 * `src/webrtc`: utility wrapper for WebRtc Peer Connections & Data Channels
 * `third_party`: contains third party code, mostly references to external typescript declaration files for things like jasmine, node, etc.

## Logging

The combination of `src/logging` and `src/loggingprovider` provide support for logging within freedom modules. For a complete example, see: https://github.com/uProxy/uproxy-lib/tree/dev/src/samples/simple-freedom-chat

# Samples apps for manual testing

There are sample apps for manual testing, with source code in:
 * `src/samples/copypaste-freedom-chat`
 * `src/samples/simple-freedom-chat`

These are run by starting a webserver and viewing the html files, e.g.

````
python -m SimpleHTTPServer
```

Then, in your web browser, goto the relevant `main.html` file in the relevant sample directory of at `http://localhost:8000/build/dev/samples/`. Samples should be self-explanatory. Follow instructions and type stuff in text boxes. :)

## Development conventions

We use `build/third_party` as a common location for references to all ambient JS definitions. This means that all typescript reference inclusions should be to files in `build/third_party/`. This provides a single location so that auto-generated `.d.ts` files for modules pulled in by require correctly reference other `.d.ts` files even when pulled in from a different repository. Basically, we assume a common directory structure for finding other typings.
