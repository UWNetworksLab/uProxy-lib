TaskManager = require './build/tools/taskmanager'

#-------------------------------------------------------------------------
# The top level tasks. These are the highest level grunt-tasks defined in terms
# of specific grunt rules below and given to grunt.initConfig
taskManager = new TaskManager.Manager();

# Makes the base development build, excludes sample apps.
taskManager.add 'base-dev', [
  'copy:third_party'
  'copy:dev'
  'ts:dev'
  'browserify:loggingProvider'
]

# Makes the development build, includes sample apps.
taskManager.add 'dev', [
  'base-dev'
  'simpleFreedomChat'
  'copypasteFreedomChat'
]

# Makes the distribution build.
taskManager.add 'dist', [
  'dev',
  'copy:dist'
]

# Build the simple freedom chat sample app.
taskManager.add 'simpleFreedomChat', [
  'base-dev'
  'copy:freedomLibsForSimpleFreedomChat'
  'ts:simpleFreedomChatMain'
  'browserify:simpleFreedomChatMain'
  'ts:simpleFreedomChatFreedomModule'
  'browserify:simpleFreedomChatFreedomModule'
]

# Build the copy/paste freedom chat sample app.
taskManager.add 'copypasteFreedomChat', [
  'base-dev'
  'copy:freedomLibsForCopypasteFreedomChat'
  'ts:copypasteFreedomChatMain'
  'browserify:copypasteFreedomChatMain'
  'ts:copypasteFreedomChatFreedomModule'
  'browserify:copypasteFreedomChatFreedomModule'
]

# Run unit tests
taskManager.add 'unit_tests', [
  'dev'
  'browserify:arraybuffersSpec'
  'browserify:handlerSpec'
  'browserify:buildToolsTaskmanagerSpec'
  'browserify:loggingSpec'
  'browserify:loggingProviderSpec'
  'browserify:webrtcSpec'
  'jasmine'
]

# Run unit tests
taskManager.add 'test', ['unit_tests']

# Default task, build dev, run tests, make the distribution build.
taskManager.add 'default', ['dev', 'unit_tests', 'dist']


#-------------------------------------------------------------------------
Rules = require './build/tools/common-grunt-rules'
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
              src: ['**/*', '!**/*.ts'],
              dest: devBuildDir,
              onlyIf: 'modified'
          }
        ]
      # Copy |third_party| to dev: this is so that there is a common
      # |build/third_party| location to reference typescript
      # definitions for ambient contexts.
      third_party:
        files: [
          {
              nonull: true,
              expand: true,
              src: ['third_party/**/*'],
              dest: 'build/',
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
              src: ['**/*',
                    '!**/*.spec.js',
                    '!**/*.spec.*.js'],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

      # Copy the freedom output file to sample apps
      freedomLibsForSimpleFreedomChat:
        Rule.copyFreedomLibs 'freedom', ['loggingprovider'],
          'samples/simple-freedom-chat'
      freedomLibsForCopypasteFreedomChat:
        Rule.copyFreedomLibs 'freedom', ['loggingprovider'],
          'samples/copypaste-freedom-chat/'

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
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      buildTools: Rule.jasmineSpec 'build-tools'
      handler: Rule.jasmineSpec 'handler'
      logging: Rule.jasmineSpec 'logging'
      loggingProvider: Rule.jasmineSpec 'loggingprovider'
      webrtc: Rule.jasmineSpec 'webrtc'

    browserify:
      # Browserify specs
      arraybuffersSpec: Rule.browserifySpec 'arraybuffers/arraybuffers'
      buildToolsTaskmanagerSpec: Rule.browserifySpec 'build-tools/taskmanager'
      handlerSpec: Rule.browserifySpec 'handler/queue'
      loggingProvider: Rule.browserify 'loggingprovider/loggingprovider'
      loggingProviderSpec: Rule.browserifySpec 'loggingprovider/loggingprovider'
      loggingSpec: Rule.browserifySpec 'logging/logging'
      webrtcSpec: Rule.browserifySpec 'webrtc/peerconnection'
      # Browserify for sample apps
      copypasteFreedomChatMain: Rule.browserify 'samples/copypaste-freedom-chat/main'
      copypasteFreedomChatFreedomModule: Rule.browserify 'samples/copypaste-freedom-chat/freedom-module'
      simpleFreedomChatMain: Rule.browserify 'samples/simple-freedom-chat/main'
      simpleFreedomChatFreedomModule: Rule.browserify 'samples/simple-freedom-chat/freedom-module'

    clean:
      build:
        [ 'build/dev', 'build/dist'
          # Note: 'src/.baseDir.ts' and '.tscache/' are created by grunt-ts.
          '.tscache/'
          'src/.baseDir.ts' ]

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

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
