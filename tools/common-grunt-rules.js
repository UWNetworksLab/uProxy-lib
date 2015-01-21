// common-grunt-rules
/// <reference path='../../third_party/typings/node/node.d.ts' />
var path = require('path');
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
function copyFreedomToDest(destPath) {
    return { files: [{
        src: [require.resolve('freedom')],
        dest: destPath,
        onlyIf: 'modified'
    }] };
}
exports.copyFreedomToDest = copyFreedomToDest;
//# sourceMappingURL=common-grunt-rules.js.map