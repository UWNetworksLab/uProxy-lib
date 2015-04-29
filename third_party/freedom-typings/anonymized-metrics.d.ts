// Typescript file for:
// https://github.com/willscott/freedomjs-anonymized-metrics/blob/master/anonmetrics.json

/// <reference path="../../../build/third_party/typings/es6-promise/es6-promise.d.ts" />

interface freedom_AnonymizedMetrics {
  report(key :string, value :any) : Promise<void>;
  retrieve() : Promise<Object>;
  retrieveUnsafe() : Promise<Object>;
}
