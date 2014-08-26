//-----------------------------------------------------------------------------
// Naming this `exports` is bit of a hack to allow this file to be compiled
// normally and still used by commonjs-style require.
module exports {
  // Function to make a typescript rule based on expected directory layout.
  export function typescriptSrc(name:string) {
    return {
      src: ['build/typescript-src/' + name + '/**/*.ts',
            '!**/*.d.ts',
            '!build/typescript-src/' + name + '/**/samples/**'],
      dest: 'build/',
      options: {
        basePath: 'build/typescript-src/',
        ignoreError: false,
        noImplicitAny: true,
        sourceMap: true
      }
    };
  }

  // This is a typescript compilation rule that makes sure unit tests can
  // typecheck with the declaration files only. This is a quick way to check
  // declaration files are approximately valid/match the implementation file.
  export function typescriptSpecDecl(name:string) {
    return {
      src: ['build/typescript-src/' + name + '/**/*.spec.ts',
            'build/typescript-src/' + name + '/**/*.d.ts',
            '!build/typescript-src/' + name + '/**/samples/**'],
      dest: 'build/',
      options: {
        basePath: 'build/typescript-src/',
        ignoreError: false,
        noImplicitAny: true,
        sourceMap: true
      }
    };
  }

  // Copy all source that is not typescript to the module's build directory.
  export function copyModule(name:string) {
    return {
      expand: true, cwd: 'src/',
      src: [name + '/**', '!**/*.ts', '!**/*.sass'],
      dest: 'build',
      onlyIf: 'modified'
    };
  }

  // Samples get all compiled code (exlcuding code from sample dir itself - no
  // recursive copying please!) in a 'lib' subdirectory.
  export function copySampleFiles(samplePath:string, libDir:string) {
    return {
      files: [
        { // Copy the sample source to the build sample directory
          expand: true, cwd: 'src/' + samplePath,
          src: ['**/*',
                '!**/*.ts',
                '!**/*.sass'],
          dest: 'build/' + samplePath,
          onlyIf: 'modified',
        }, {  // Copy all modules in the build directory to the sample
          expand: true, cwd: 'build',
          src: ['**/*',
                '!**/samples/**',
                '!**/typescript-src/**'],
          dest: 'build/' + samplePath + '/' + libDir,
          onlyIf: 'modified'
        }, {  // Copy all modules typescript for sourcemaps to work
          expand: true, cwd: 'build',
          src: ['typescript-src/**/*.ts',
                '!**/*.d.ts',
                '!**/*.spec.ts'],
          dest: 'build/' + samplePath + '/' + libDir,
          onlyIf: 'modified'
        }
      ]
    };
  }

  // Function to make jasmine spec assuming expected dir layout.
  export function jasmineSpec(name:string) {
    var jasmine_helpers = [
        // Help Jasmine's PhantomJS understand promises.
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

}  // module Rules
