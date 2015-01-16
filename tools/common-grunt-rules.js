<<<<<<< HEAD
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
function browserify(filepath) {
    return {
        src: ['build/dev/' + filepath + '.js'],
        dest: 'build/dev/' + filepath + '.static.js',
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
=======
// Naming this `exports` is a trick to allow this file to be compiled normally
// and still used by commonjs-style require.
var exports;
(function (exports) {
    // Compiles a module's source files, excluding tests and declarations.
    // The files must already be available under build/.
    function typescriptSrc(name) {
        return {
            src: [
                'build/' + name + '/**/*.ts',
                '!build/' + name + '/**/*.spec.ts',
                '!build/' + name + '/**/*.d.ts',
            ],
            options: {
                sourceRoot: 'build/',
                target: 'es5',
                comments: false,
                noImplicitAny: true,
                sourceMap: true,
                declaration: false,
                fast: 'always'
            }
        };
    }
    exports.typescriptSrc = typescriptSrc;
    // Compiles a module's tests and declarations, in order to
    // help test that declarations match their implementation.
    // The files must already be available under build/.
    function typescriptSpecDecl(name) {
        return {
            src: [
                'build/' + name + '/**/*.spec.ts',
                'build/' + name + '/**/*.d.ts',
            ],
            options: {
                sourceRoot: 'build/',
                target: 'es5',
                comments: false,
                noImplicitAny: true,
                sourceMap: true,
                declaration: false,
                fast: 'always'
            }
        };
    }
    exports.typescriptSpecDecl = typescriptSpecDecl;
    // Copies a module's directory from build/ to dist/.
    // Test-related files are excluded.
    // CONSIDER: rename to copyModuleToDest so you can understand it when only
    // reading the Gruntfile.
    function copyModule(name) {
        return {
            expand: true,
            cwd: 'build/',
            src: [
                name + '/**',
                '!' + name + '/**/*.spec.*',
            ],
            dest: 'dist/',
            onlyIf: 'modified'
        };
    }
    exports.copyModule = copyModule;
    // Copies build/* to a sample's directory under dist/.
    // The samples directory itself and TypeScript files are excluded.
    // TODO: copy dist/* instead
    function copySampleFiles(name) {
        return {
            files: [
                {
                    expand: true,
                    cwd: 'build/',
                    src: [
                        '**',
                        '!samples/**',
                        '!**/*.ts',
                    ],
                    dest: 'dist/' + name + '/lib/',
                    onlyIf: 'modified'
                }
            ]
        };
    }
    exports.copySampleFiles = copySampleFiles;
    // Function to make jasmine spec assuming expected dir layout.
    function jasmineSpec(name) {
        var jasmine_helpers = [
            'node_modules/es6-promise/dist/promise-*.js',
            '!node_modules/es6-promise/dist/promise-*amd.js',
            '!node_modules/es6-promise/dist/promise-*.min.js',
            'node_modules/arraybuffer-slice/index.js'
        ];
        return {
            src: jasmine_helpers.concat([
                'build/' + name + '/**/*.js',
                '!build/' + name + '/**/*.spec.js'
            ]),
            options: {
                specs: 'build/' + name + '/**/*.spec.js',
                outfile: 'build/' + name + '/SpecRunner.html',
                keepRunner: true
            }
        };
    }
    exports.jasmineSpec = jasmineSpec;
})(exports || (exports = {})); // module Rules
>>>>>>> dev
