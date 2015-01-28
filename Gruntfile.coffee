TaskManager = require './tools/taskmanager'

#-------------------------------------------------------------------------
# The top level tasks. These are the highest level grunt-tasks defined in terms
# of specific grunt rules below and given to grunt.initConfig
taskManager = new TaskManager.Manager();

# Setup makes sure the needed typescript definition files are in the right place
# so that typescript compilation can find them using require and defines
# references in the code.
taskManager.add 'setup', [
  'tsd:dev'
]

# This rebuilds the tools directory. It should not often be needed.
taskManager.add 'tools', [
  'ts:dev'
  'copy:tools'
]

# Makes the base development build, excludes sample apps.
taskManager.add 'base-dev', [
  'copy:dev'
  'ts:dev'
  'browserify:loggingProvider'
]

# Makes the development build, includes sample apps.
taskManager.add 'dev', [
  'base-dev'
  'samples'
]

# Makes the distribution build.
taskManager.add 'dist', [
  'dev',
  'copy:dist'
]

# Build the simple freedom chat sample app.
taskManager.add 'simpleFreedomChat', [
  'base-dev'
  'copy:freedomjsForSimpleFreedomChat'
  'copy:loggingLibForSimpleFreedomChat'
  'ts:simpleFreedomChatMain'
  'browserify:simpleFreedomChatMain'
  'ts:simpleFreedomChatFreedomModule'
  'browserify:simpleFreedomChatFreedomModule'
]

# Build the copy/paste freedom chat sample app.
taskManager.add 'copypasteFreedomChat', [
  'base-dev'
  'copy:freedomjsForCopypasteFreedomChat'
  'copy:loggingLibForCopypasteFreedomChat'
  'ts:copypasteFreedomChatMain'
  'browserify:copypasteFreedomChatMain'
  'ts:copypasteFreedomChatFreedomModule'
  'browserify:copypasteFreedomChatFreedomModule'
]

# Build all sample apps.
taskManager.add 'samples', [
  'simpleFreedomChat'
  'copypasteFreedomChat'
]

# Run unit tests
taskManager.add 'unit_tests', [
  'dev'
  'browserify:arraybuffersSpec'
  'jasmine:arraybuffers'
  'browserify:handlerSpec'
  'jasmine:handler'
  'browserify:buildToolsTaskmanagerSpec'
  'jasmine:buildTools'
  'browserify:loggingSpec'
  'jasmine:logging'
  'browserify:loggingProviderSpec'
  'jasmine:loggingProvider'
]

# Default task, build dev, run tests, make the distribution build.
taskManager.add 'default', ['dev', 'unit_tests', 'dist']


#-------------------------------------------------------------------------
Rules = require './tools/common-grunt-rules'
devBuildDir = 'build/dev'
Rule = new Rules.Rule({devBuildDir: devBuildDir});

path = require 'path'

module.exports = (grunt) ->
  config =
    pkg: grunt.file.readJSON 'package.json'

    copy:
      # Copy releveant non-typescript files to dev build.
      dev:
        files: [
          {
              nonull: true,
              expand: true,
              cwd: 'src/',
              src: ['**/*.html', '**/*.css', '**/*.json'],  # , '**/*.js'
              dest: devBuildDir,
              onlyIf: 'modified'
          }
        ]
      # Copy releveant non-typescript files to distribution build.
      dist:
        files: [
          {
              nonull: true,
              expand: true,
              cwd: devBuildDir,
              src: ['**/*.html',
                    '**/*.css',
                    '**/*.js',
                    '**/*.json',
                    '**/*.d.ts',
                    '!**/*.spec.dynamic.js',
                    '!**/*.spec.js',
                    '!**/*.spec.static.js'],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

      # Copy the freedom output file to sample apps
      freedomjsForSimpleFreedomChat:
        Rule.copyFreedomToDest 'freedom', path.join(devBuildDir, 'samples/simple-freedom-chat/')
      loggingLibForSimpleFreedomChat:
        Rule.copySomeFreedomLib 'loggingprovider', path.join(devBuildDir, 'samples/simple-freedom-chat/lib/')

      freedomjsForCopypasteFreedomChat:
        Rule.copyFreedomToDest 'freedom', path.join(devBuildDir, 'samples/copypaste-freedom-chat/')
      loggingLibForCopypasteFreedomChat:
        Rule.copySomeFreedomLib 'loggingprovider',  path.join(devBuildDir, 'samples/copypaste-freedom-chat/lib/')

      # Copies relevant build tools into the tools directory. Should only be run
      # updating our build tools and wanting to commit and update (or when you
      # want to experimentally mess about with our build tools)
      #
      # Assumes that `ts:dev` has happened.
      tools:
        files: [{
          nonull: true,
          expand: true
          cwd: path.join(devBuildDir, 'build-tools')
          src: ['**/*.js'
                '!**/*.map'
                '!**/*.spec.js'
                '!**/*.spec.static.js']
          dest: 'tools/'
          onlyIf: 'modified'
        }]

    tsd:
      # The dev target will install the `.d.ts` files using the version numbers
      # in 'third_party/tsd.json'.
      dev:
        options:
          command: 'reinstall'
          config: 'third_party/tsd.json'
          save: true
          overwrite: true
      # The updateDeps rule will update the 'third_party/tsd.json' with the
      # latest dependencies from DepfinitelyTyped, as well as install them in
      # 'third_party/typings'.
      updateDeps:
        options:
          command: 'reinstall'
          latest: true
          config: 'third_party/tsd.json'

    # Typescript rules
    ts:
      # Compile everything into the development build directory.
      dev:
        src: [
          'src/**/*.ts',
          '!src/**/*.d.ts',
          '!src/samples/**/*.ts',
          '!src/**/*.spec.dynamic.ts',
        ]
        outDir: 'build/dev/'
        baseDir: 'src'
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: false
          declaration: true
          module: 'commonjs'
          fast: 'always'
      copypasteFreedomChatMain:
        src: ['src/samples/copypaste-freedom-chat/main.ts']
        outDir: devBuildDir
        baseDir: 'src'
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: false
          declaration: false
          module: 'commonjs'
          fast: 'always'
      copypasteFreedomChatFreedomModule:
        src: ['src/samples/copypaste-freedom-chat/freedom-module.ts']
        outDir: devBuildDir
        baseDir: 'src'
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: false
          declaration: false
          module: 'commonjs'
          fast: 'always'
      simpleFreedomChatMain:
        src: ['src/samples/simple-freedom-chat/main.ts']
        outDir: devBuildDir
        baseDir: 'src'
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: false
          declaration: false
          module: 'commonjs'
          fast: 'always'
      simpleFreedomChatFreedomModule:
        src: ['src/samples/simple-freedom-chat/freedom-module.ts']
        outDir: devBuildDir
        baseDir: 'src'
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: false
          declaration: false
          module: 'commonjs'
          fast: 'always'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      buildTools: Rule.jasmineSpec 'build-tools'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      logging:
        Rule.jasmineSpec('logging',['third_party/freedom/pre-spec-freedom.js'])
      loggingProvider:
        Rule.jasmineSpec('loggingprovider',['third_party/freedom/pre-spec-freedom.js'])

    browserify:
      # Browserify specs
      arraybuffersSpec: Rule.browserify 'arraybuffers/arraybuffers.spec'
      handlerSpec: Rule.browserify 'handler/queue.spec'
      buildToolsTaskmanagerSpec: Rule.browserify 'build-tools/taskmanager.spec'
      loggingSpec: Rule.browserify 'logging/logging.spec'
      loggingProvider: Rule.browserify 'loggingprovider/loggingprovider'
      loggingProviderSpec: Rule.browserify 'loggingprovider/loggingprovider.spec'
      # Browserify for sample apps
      copypasteFreedomChatMain: Rule.browserify 'samples/copypaste-freedom-chat/main'
      copypasteFreedomChatFreedomModule: Rule.browserify 'samples/copypaste-freedom-chat/freedom-module'
      simpleFreedomChatMain: Rule.browserify 'samples/simple-freedom-chat/main'
      simpleFreedomChatFreedomModule: Rule.browserify 'samples/simple-freedom-chat/freedom-module'

    # Compile everything into the development build directory.
    clean:
      build:
        [ 'build/'
          # Note: 'src/.baseDir.ts' and '.tscache/' are created by grunt-ts.
          '.tscache/'
          'src/.baseDir.ts' ]
      #tsdSetup:
      #  [ 'third_party/typings' ]
      #nodeModules:
      #  [ 'node_modules' ]

  #-------------------------------------------------------------------------
  grunt.initConfig config

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-symlink'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-ts'
  grunt.loadNpmTasks 'grunt-tsd'

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
