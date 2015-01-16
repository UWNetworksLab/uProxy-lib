// common-grunt-rules
/// <reference path='../../third_party/typings/node/node.d.ts' />
var path = require('path');
// Assumes that the each spec file is a fully browserified js file.
function jasmineSpec(name) {
    return {
        src: [
            require.resolve('arraybuffer-slice'),
            path.join(path.dirname(require.resolve('es6-promise/package.json')), 'dist/promise-1.0.0.js')
        ],
        options: {
            specs: 'build/dev/' + name + '/**/*.spec.static.js',
            outfile: 'build/dev/' + name + '/SpecRunner.html',
            keepRunner: true
        }
    };
}
exports.jasmineSpec = jasmineSpec;
function browserifyTypeScript(filepath) {
    return {
        src: ['build/dev/' + filepath + '.js'],
        dest: 'build/dev/' + filepath + '.static.js',
        options: {
            debug: true,
        }
    };
}
exports.browserifyTypeScript = browserifyTypeScript;
function copyFreedomToDest(destPath) {
    return { files: [{
        src: [require.resolve('freedom')],
        dest: destPath,
        onlyIf: 'modified'
    }] };
}
exports.copyFreedomToDest = copyFreedomToDest;
//# sourceMappingURL=common-grunt-rules.js.map