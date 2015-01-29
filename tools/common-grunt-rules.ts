// Naming this `exports` is a trick to allow this file to be compiled normally
// and still used by commonjs-style require.
module exports {

  declare var require;

  // Compiles a module's source files, excluding tests and declarations.
  // The files must already be available under build/.
  export function typescriptSrc(name:string) {
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
        fast: 'always',
      }
    };
  }

  // Compiles a module's tests and declarations, in order to
  // help test that declarations match their implementation.
  // The files must already be available under build/.
  export function typescriptSpecDecl(name:string) {
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
        fast: 'always',
      }
    };
  }

  // Copies a module's directory from build/ to dist/.
  // Test-related files are excluded.
  // CONSIDER: rename to copyModuleToDest so you can understand it when only
  // reading the Gruntfile.
  export function copyModule(name:string) {
    return {
      expand: true,
      cwd: 'build/',
      src: [
        name + '/**',
        '!' + name + '/**/*.spec.*',
      ],
      dest: 'dist/',
      onlyIf: 'modified',
    };
  }

  // Copies build/* to a sample's directory under dist/.
  // The samples directory itself and TypeScript files are excluded.
  // TODO: copy dist/* instead
  export function copySampleFiles(name:string) {
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
          onlyIf: 'modified',
        }
      ]
    };
  }

  // Function to make jasmine spec assuming expected dir layout.
  // If the user chooses not to follow the expected dir layout,
  // they can pass in source files directly (spec assumption is
  // fixed, however).
  // This rule also expects grunt-template-jasmine-istanbul
  // to be available to calculate code coverage.
  export function jasmineSpec(name:string, srcFiles?:string[]) {

    var jasmine_helpers = [
        // Help Jasmine's PhantomJS understand promises.
        'node_modules/es6-promise/dist/promise-*.js',
        '!node_modules/es6-promise/dist/promise-*amd.js',
        '!node_modules/es6-promise/dist/promise-*.min.js',
        'node_modules/arraybuffer-slice/index.js'
      ];

    // If user did not pass in source files, assume the expected
    // dir layout.
    if (!srcFiles) {
      srcFiles = jasmine_helpers.concat([
        'build/' + name + '/**/*.js',
        '!build/' + name + '/**/*.spec.js'
      ]);
    }

    return {
      src: srcFiles,
      options: {
        specs: 'build/' + name + '/**/*.spec.js',
        template: require('grunt-template-jasmine-istanbul'),
        templateOptions: {
          coverage: 'build/coverage/' + name + '/coverage.json',
          report: {
            type: 'html',
            options: {
              dir: 'build/coverage/' + name
            }
          }
        }
      }
    };
  }

}  // module Rules
