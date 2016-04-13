// Monkey patch for browserify's process shim, for ssh2-streams.

const process = require('process');

// Node.js 4.2 is an LTS release and, very roughly, is what the
// browserify shims, e.g. Buffer, provide.
process.version = '4.2.0';

process.binding = function() {
 return {};
};
