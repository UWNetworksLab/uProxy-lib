# uProxy Build Tools

[![Build Status](https://travis-ci.org/uProxy/build-tools.png?branch=master)](https://travis-ci.org/uProxy/build-tools)

Distributed on NPM as [uproxy-build-tools](https://www.npmjs.org/package/uproxy-build-tools).

This currently consists of:

 * Smart grunt task management that avoid re-building the same components multiple times. This assumes that if a component was build once, then it never has to be build again in a single build run.
 * Some third party TypeScript interfaces (jasmine) for testing.
