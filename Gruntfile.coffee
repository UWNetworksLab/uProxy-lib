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
]

# Makes the development build, includes sample apps.
taskManager.add 'dev', [
  'base-dev'
  'samples'
]

# Makes the distribution build.
taskManager.add 'dist', [
  'copy:dist'
]

# Build the simple freedom chat sample app.
# taskManager.add 'simpleFreedomChat', [
#   'base-dev'
#   'copy:freedomjsForSimpleFreedomChat'
#   'browserify:simpleFreedomChatMain'
#   'browserify:simpleFreedomChatFreedomModule'
# ]

# Build the copy/paste freedom chat sample app.
taskManager.add 'copypasteFreedomChat', [
  'base-dev'
  'copy:freedomjsForCopypasteFreedomChatMain'
  'copy:loggingLibForCopypasteFreedomChatMainModule'
  'ts:copypasteFreedomChatMain'
  'browserify:copypasteFreedomChatMain'
  'ts:copypasteFreedomChatFreedomModule'
  'browserify:copypasteFreedomChatFreedomModule'
]

# Build all sample apps.
taskManager.add 'samples', [
#  'simpleFreedomChat'
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
#
#-------------------------------------------------------------------------
Rule = require './tools/common-grunt-rules'
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
              dest: 'build/src/',
              onlyIf: 'modified'
          }
        ]
      # Copy releveant non-typescript files to distribution build.
      dist:
        files: [
          {
              nonull: true,
              expand: true,
              cwd: 'build/src/',
              src: ['**/*.html', '**/*.css',  '**/*.js',
                    '!**/*.spec.js', '!**/*.spec.static.js'],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

      # Copy the freedom output file to sample apps
      #freedomjsForSimpleFreedomChat:
      #  Rule.copyFreedomToDest 'freedom', 'build/src/samples/simple-freedom-chat/'
      freedomjsForCopypasteFreedomChatMain:
        Rule.copyFreedomToDest 'freedom', 'build/src/samples/copypaste-freedom-chat/'
      loggingLibForCopypasteFreedomChatMainModule:
        Rule.copyFreedomLib 'loggingprovider', 'build/src/samples/copypaste-freedom-chat/lib/'

      # Copies relevant build tools into the tools directory. Should only be run
      # updating our build tools and wanting to commit and update (or when you
      # want to experimentally mess about with our build tools)
      #
      # Assumes that `ts:dev` has happened.
      tools:
        files: [{
          nonull: true,
          expand: true
          cwd: 'build/src/build-tools/'
          src: ['**/*.js'
                '!**/*.map'
                '!**/*.spec.js'
                '!**/*.spec.static.js']
          dest: 'tools/'
          onlyIf: 'modified'
        }]

    tsd:
      dev:
        options:
          # execute a command
          command: 'reinstall'
          # optional: always get from HEAD
          latest: true
          # optional: specify config file
          config: 'third_party/tsd.json'

    # Typescript rules
    ts:
      # Compile everything into the development build directory.
      dev:
        src: ['src/**/*.ts', '!src/**/*.d.ts', '!src/samples/**']
        outDir: 'build/'
        baseDir: 'src'
        options:
          #sourceRoot: 'build/'
          mapRoot: 'src/'
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: true
          declaration: true
          module: 'commonjs'
          fast: 'always'
      copypasteFreedomChatMain:
        src: ['src/samples/copypaste-freedom-chat/main.ts']
        outDir: 'build/src/'
        baseDir: 'src'
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: true
          declaration: false
          module: 'commonjs'
          fast: 'always'
      copypasteFreedomChatFreedomModule:
        src: ['src/samples/copypaste-freedom-chat/freedom-module.ts']
        outDir: 'build/src/'
        baseDir: 'src'
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: true
          declaration: false
          module: 'commonjs'
          fast: 'always'
      #simpleFreedomChatMain:
      #simpleFreedomChatFreedomModule:

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
      loggingProviderSpec: Rule.browserify 'loggingprovider/loggingprovider.spec'
      # Browserify for sample apps
      copypasteFreedomChatMain: Rule.browserify 'samples/copypaste-freedom-chat/main'
      copypasteFreedomChatFreedomModule: Rule.browserify 'samples/copypaste-freedom-chat/freedom-module'
      simpleFreedomChatMain: Rule.browserify 'samples/simple-freedom-chat/main'
      simpleFreedomChatFreedomModule: Rule.browserify 'samples/simple-freedom-chat/freedom-module'

    # Compile everything into the development build directory.
    clean: ['build/'
            # 'src/.baseDir.ts' and '.tscache/' are created by grunt-ts.
            '.tscache/'
            'src/.baseDir.ts']

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
