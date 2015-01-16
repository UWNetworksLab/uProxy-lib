TaskManager = require './tools/taskmanager'
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
                '!**/*.spec.js']
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
      crypto: Rule.jasmineSpec 'taskmanager'
      logging: Rule.jasmineSpec 'logging'

    browserify:
      handlerQueueSpec:
        Rule.browserifyTypeScript 'handler/queue.spec'
      taskmanagerSpec:
        Rule.browserifyTypeScript 'taskmanager/taskamanager.spec'
      copypasteFreedomChatMain:
        Rule.browserifyTypeScript 'samples/copypaste-freedom-chat/main'
      copypasteFreedomChatFreedomModule:
        Rule.browserifyTypeScript 'samples/copypaste-freedom-chat/freedom-module.ts'
      simpleFreedomChatMain:
        Rule.browserifyTypeScript 'samples/simple-freedom-chat/main'
      simpleFreedomChatFreedomModule:
        Rule.browserifyTypeScript 'samples/simple-freedom-chat/freedom-module.ts'

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
  # Define the tasks
  taskManager = new TaskManager.Manager();

  taskManager.add 'setup', [
    'tsd:dev'
  ]

  taskManager.add 'tools', [
    'ts:dev'
    'copy:tools'
  ]

  taskManager.add 'simpleFreedomChat', [
    'copy:dev'
    'browserify:simpleFreedomChatMain'
    'browserify:simpleFreedomChatFreedomModule'
  ]

  taskManager.add 'copypasteFreedomChat', [
    'copy:dev'
    'browserify:copypasteFreedomChatMain'
    'browserify:copypasteFreedomChatFreedomModule'
  ]

  taskManager.add 'samples', [
    'simpleFreedomChat'
    'copypasteFreedomChat'
  ]

  taskManager.add 'dev', [
    'copy:dev'
    'ts:dev'
    'browserify:handlerQueueSpec'
    'jasmine:handler'
    #'samples'
  ]

  taskManager.add 'dist', [
    'copy:dist'
    'ts:dist'
  ]

  taskManager.add 'test', [
    'dev'
    'jasmine'
  ]

  grunt.registerTask 'default', [
    'dev', 'dist', 'test'
  ]

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
