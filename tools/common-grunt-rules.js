// Naming this `exports` is bit of a hack to allow this file to be compiled
// normally and still used by commonjs-style require.
var exports;
(function (exports) {
    // Compiles a module's source files, excluding tests and declarations.
    // The files must already be available under build/.
    function typescriptSrc(name) {
        return {
            src: [
                'build/' + name + '/**/*.ts',
                '!**/*.spec.ts',
                '!**/*.d.ts'
            ],
            options: {
                sourceRoot: 'build/',
                target: 'es5',
                comments: false,
                noImplicitAny: true,
                sourceMap: true,
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
                'build/' + name + '/**/*.d.ts'
            ],
            options: {
                sourceRoot: 'build/',
                target: 'es5',
                comments: false,
                noImplicitAny: true,
                sourceMap: true,
                declaration: true,
                fast: 'always'
            }
        };
    }
    exports.typescriptSpecDecl = typescriptSpecDecl;

    // Copies a module's directory from build/ to dist/.
    // Test-related files are excluded.
    function copyModule(name) {
        return {
            expand: true,
            cwd: 'build/',
            src: [
                name + '/**',
                '!**/*.spec.*'
            ],
            dest: 'dist/',
            onlyIf: 'modified'
        };
    }
    exports.copyModule = copyModule;

    // Copies dist/* to a sample's directory under dist/.
    // The samples directory itself is excluded.
    function copySampleFiles(name) {
        return {
            files: [
                {
                    expand: true,
                    cwd: 'dist/',
                    src: [
                        '**',
                        '!samples/**'
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
                outfile: 'build/' + name + '/_SpecRunner.html',
                keepRunner: true
            }
        };
    }
    exports.jasmineSpec = jasmineSpec;
})(exports || (exports = {}));
