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
                '!**/*.spec.*'
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
