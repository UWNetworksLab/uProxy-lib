// common-grunt-rules
/// <reference path='../../third_party/typings/node/node.d.ts' />
var path = require('path');
// Grunt Jasmine target creator
// Assumes that the each spec file is a fully browserified js file.
function jasmineSpec(name, morefiles) {
    if (!morefiles) {
        morefiles = [];
    }
    return {
        src: [
            require.resolve('arraybuffer-slice'),
            path.join(path.dirname(require.resolve('es6-promise/package.json')), 'dist/promise-1.0.0.js')
        ].concat(morefiles),
        options: {
            specs: 'build/src/' + name + '/**/*.spec.static.js',
            outfile: 'build/src/' + name + '/SpecRunner.html',
            keepRunner: true
        }
    };
}
exports.jasmineSpec = jasmineSpec;
// Grunt browserify target creator
function browserify(filepath) {
    return {
        src: ['build/src/' + filepath + '.js'],
        dest: 'build/src/' + filepath + '.static.js',
        options: {
            debug: true,
        }
    };
}
exports.browserify = browserify;
// Grunt copy target creator: for copying freedom.js to
function copyFreedomToDest(freedomRuntimeName, destPath) {
    var freedomjsPath = require.resolve(freedomRuntimeName);
    var fileTarget = { files: [{
        nonull: true,
        src: [freedomjsPath],
        dest: path.join(destPath, path.basename(freedomjsPath)),
        onlyIf: 'modified'
    }] };
    return fileTarget;
}
exports.copyFreedomToDest = copyFreedomToDest;
// Grunt copy target creator: for copy a freedom library directory
function copyFreedomLib(libPath, destPath) {
    return { files: [{
        expand: true,
        cwd: 'build/src/',
        src: [
            libPath + '/*.json',
            libPath + '/*.js',
            libPath + '/*.html',
            libPath + '/*.css',
            '!' + libPath + '/*.spec.js',
            '!' + libPath + '/SpecRunner.html'
        ],
        dest: destPath,
        onlyIf: 'modified'
    }] };
}
exports.copyFreedomLib = copyFreedomLib;
//# sourceMappingURL=common-grunt-rules.js.map