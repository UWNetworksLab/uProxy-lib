// common-grunt-rules
/// <reference path='../../third_party/typings/node/node.d.ts' />
// Assumes that the each spec file is a fully browserified js file.
function jasmineSpec(name) {
    return {
        src: [
            require.resolve('arraybuffer-slice'),
            require.resolve('es6-promise')
        ],
        options: {
            specs: 'build/dev/' + name + '/**/*.spec.js',
            outfile: 'build/dev/' + name + '/SpecRunner.html',
            keepRunner: true
        }
    };
}
exports.jasmineSpec = jasmineSpec;
;
function browserifyTypeScript(filepath) {
    return {
        src: [filepath + '.ts'],
        dest: filepath + '.js',
        browserifyOptions: {
            debug: true,
            transform: ['tsify']
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
