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
  'ts:dist'
]

# Build the simple freedom chat sample app.
taskManager.add 'simpleFreedomChat', [
  'base-dev'
  'browserify:simpleFreedomChatMain'
  'browserify:simpleFreedomChatFreedomModule'
]

# Build the copy/paste freedom chat sample app.
taskManager.add 'copypasteFreedomChat', [
  'base-dev'
  'browserify:copypasteFreedomChatMain'
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
  'browserify:taskmanagerSpec'
  'jasmine:taskmanager'
  'browserify:loggingSpec'
  'jasmine:logging'
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
              expand: true,
              cwd: 'src/',
              src: ['**/*.html', '**/*.css',  '**/*.js'],
              dest: 'build/dev/',
              onlyIf: 'modified'
          }
        ]
      # Copy releveant non-typescript files to distribution build.
      dist:
        files: [
          {
              expand: true,
              cwd: 'src/',
              src: ['**/*.html', '**/*.css',  '**/*.js'],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

      # Copy the freedom output file to sample apps
      freedomForSimpleFreedomChat:
        Rule.copyFreedomToDest 'build/dev/samples/simple-freedom-chat/'
      freedomForCopyPasteFreedomChat:
        Rule.copyFreedomToDest 'build/dev/samples/copypaste-freedom-chat/'

      # Copies relevant build tools into the tools directory. Should only be run
      # updating our build tools and wanting to commit and update (or when you
      # want to experimentally mess about with our build tools)
      #
      # Assumes that `ts:dev` has happened.
      tools:
        files: [{
          expand: true
          cwd: 'build/dev/taskmanager/'
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
        src: ['src/**/*.ts']
        outDir: 'build/dev/'
        options:
          #sourceRoot: 'build/'
          #mapRoot: 'build/'
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: true
          declaration: true
          module: 'commonjs'
          fast: 'always'
      # Compile everything into the distribution build directory.
      dist:
        src: ['src/**/*.ts']
        outDir: 'build/dist/'
        options:
          #sourceRoot: 'build/'
          #mapRoot: 'build/'
          target: 'es5'
          comments: false
          noImplicitAny: true
          sourceMap: false
          declaration: true
          module: 'commonjs'
          fast: 'always'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      taskmanager: Rule.jasmineSpec 'taskmanager'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      logging: Rule.jasmineSpec 'logging'

    browserify:
      # Browserify specs
      arraybuffersSpec:
        Rule.browserify 'arraybuffers/arraybuffers.spec'
      handlerSpec:
        Rule.browserify 'handler/queue.spec'
      taskmanagerSpec:
        Rule.browserify 'taskmanager/taskmanager.spec'
      loggingSpec:
        Rule.browserify 'logging/logging.spec'
      # Browserify for sample apps
      copypasteFreedomChatMain:
        Rule.browserify 'samples/copypaste-freedom-chat/main'
      copypasteFreedomChatFreedomModule:
        Rule.browserify 'samples/copypaste-freedom-chat/freedom-module.ts'
      simpleFreedomChatMain:
        Rule.browserify 'samples/simple-freedom-chat/main'
      simpleFreedomChatFreedomModule:
        Rule.browserify 'samples/simple-freedom-chat/freedom-module.ts'

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
