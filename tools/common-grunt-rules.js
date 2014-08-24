//-----------------------------------------------------------------------------
// Naming this `exports` is bit of a hack to allow this file to be compiled
// normally and still used by commonjs-style require.
var exports;
(function (exports) {
    // Function to make a typescript rule based on expected directory layout.
    function typescriptSrc(name) {
        return {
            src: [
                'build/typescript-src/' + name + '/**/*.ts',
                '!build/typescript-src/' + name + '/samples/**/*.ts',
                '!build/typescript-src/' + name + '/**/*.d.ts'],
            dest: 'build/',
            options: {
                basePath: 'build/typescript-src/',
                ignoreError: false,
                noImplicitAny: true,
                sourceMap: true
            }
        };
    }
    exports.typescriptSrc = typescriptSrc;

    // This is a typescript compilation rule that makes sure unit tests can
    // typecheck with the declaration files only. This is a quick way to check
    // declaration files are approximately valid/match the implementation file.
    function typescriptSpecDecl(name) {
        return {
            src: [
                'build/typescript-src/' + name + '/**/*.spec.ts',
                'build/typescript-src/' + name + '/**/*.d.ts'],
            dest: 'build/',
            options: {
                basePath: 'build/typescript-src/',
                ignoreError: false,
                noImplicitAny: true,
                sourceMap: true
            }
        };
    }
    exports.typescriptSpecDecl = typescriptSpecDecl;

    // Copy all source that is not typescript to the module's build directory.
    function copyModule(name) {
        return {
            expand: true, cwd: 'src/',
            src: [name + '/**', '!**/*.ts', '!**/*.sass'],
            dest: 'build',
            onlyIf: 'modified'
        };
    }
    exports.copyModule = copyModule;

    // Samples get all compiled code (exlcuding code from sample dir itself - no
    // recursive copying please!) in a 'lib' subdirectory.
    function copySampleFiles(samplePath, libDir) {
        return {
            files: [
                {
                    expand: true, cwd: 'src/' + samplePath,
                    src: [
                        '**/*',
                        '!**/*.ts',
                        '!**/*.sass'],
                    dest: 'build/' + samplePath,
                    onlyIf: 'modified'
                }, {
                    expand: true, cwd: 'build',
                    src: [
                        '**/*',
                        '!**/samples/**',
                        '!**/typescript-src/**'],
                    dest: 'build/' + samplePath + '/' + libDir,
                    onlyIf: 'modified'
                }, {
                    expand: true, cwd: 'build',
                    src: [
                        'typescript-src/**/*.ts',
                        '!**/*.d.ts',
                        '!**/*.spec.ts'],
                    dest: 'build/' + samplePath + '/' + libDir,
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
