# uProxy Build Tools

[![Build Status](https://travis-ci.org/uProxy/build-tools.svg?branch=master)](https://travis-ci.org/uProxy/build-tools) [![devDependency Status](https://david-dm.org/uProxy/build-tools/dev-status.svg)](https://david-dm.org/uProxy/build-tools#info=devDependencies)


Distributed on NPM as [uproxy-build-tools](https://www.npmjs.org/package/uproxy-build-tools).

This currently consists of:

 * Smart grunt task management that avoid re-building the same components multiple times. This assumes that if a component was build once, then it never has to be build again in a single build run.
 * Some third party TypeScript interfaces (jasmine) for testing.
 * A few handy utilties, e.g. converting ArrayBuffers to strings.
 