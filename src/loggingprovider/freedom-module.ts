/// <reference path='../../build/third_party/freedom-typings/freedom-common.d.ts' />
/// <reference path='../../build/third_party/freedom-typings/freedom-module-env.d.ts' />

import logging_provider = require('./loggingprovider');

freedom().provideSynchronous(logging_provider.Log);
freedom['loggingcontroller']().provideSynchronous(logging_provider.LoggingController);
