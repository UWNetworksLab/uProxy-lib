TaskManager = require './tools/taskmanager'
Rule = require './tools/common-grunt-rules'

path = require 'path'

module.exports = (grunt) ->
  #-------------------------------------------------------------------------
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    # TODO: This must be factored out into common-grunt-rules.
    symlink:
      # Symlink the Chrome and Firefox builds of Freedom under build/freedom/.
      freedom:
        files: [ {
          expand: true
          cwd: path.dirname(require.resolve('freedom/Gruntfile'))
          src: ['freedom.js']
          dest: 'build/freedom/'
        } ]

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

      # Copies relevant build tools into the tools directory. Should only be run
      # updating our build tools and wanting to commit and update (or when you
      # want to experimentally mess about with our build tools)
      #
      # Assumes that `ts:dev` has happened.
      tools:
        files: [
          {
              expand: true,
              cwd: 'build/dev/',
              src: ['taskmanager',
                    '!**/*.map',
                    '!**/*.spec.js',
              ],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

    # Typescript rules
    ts:
      # Compile everything into the development build directory.
      dev:
        src: ['src/**/*.ts']
        #sourceRoot: 'build/'
        #mapRoot: 'build/'
        outDir: 'build/dev/'
        target: 'es5'
        comments: true
        noImplicitAny: true
        sourceMap: true
        declaration: true
        module: 'commonjs'
        fast: 'always'
      # Compile everything into the distribution build directory.
      distr:
        src: ['src/**/*.ts']
        #sourceRoot: 'build/'
        #mapRoot: 'build/'
        outDir: 'build/dist/'
        target: 'es5'
        comments: false
        noImplicitAny: true
        sourceMap: false
        declaration: true
        module: 'commonjs'
        fast: 'always'

    jamine:
      handler:
        src: [
          'build/logging/mocks.js'
          'build/logging/logging.js'
        ]
        options:
          specs: 'build/logging/*.spec.js'

      logging:
        src: [
          'build/logging/mocks.js'
          'build/logging/logging.js'
        ]
        options:
          specs: 'build/logging/*.spec.js'

    # Compile everything into the development build directory.
    clean: ['build/'
            # 'src/.baseDir.ts' and '.tscache/' are created by grunt-ts.
            '.tscache/'
            'src/.baseDir.ts']

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-symlink'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-ts'

  #-------------------------------------------------------------------------
  # Define the tasks
  taskManager = new TaskManager.Manager();

  taskManager.add 'tools', [
    'ts:all'
    'copy:tools'
  ]

  taskManager.add 'crypto', [
    'base'
    'ts:crypto'
    'copy:crypto'
  ]

  taskManager.add 'arraybuffers', [
    'base'
    'ts:arraybuffers'
    'ts:arraybuffersSpecDecl'
    'copy:arraybuffers'
  ]

  taskManager.add 'handler', [
    'base'
    'ts:handler'
    'ts:handlerSpecDecl'
    'copy:handler'
  ]

  taskManager.add 'logging', [
    'base'
    'ts:logging'
    'ts:loggingSpecDecl'
    'copy:logging'
  ]

  taskManager.add 'webrtc', [
    'logging'
    'crypto'
    'handler'
    'base'
    'ts:webrtc'
    'copy:webrtc'
  ]

  taskManager.add 'freedom', [
    'base'
    'ts:freedomTypingsSpecDecl'
    'copy:freedomTypings'
  ]

  taskManager.add 'simpleFreedomChat', [
    'base'
    'logging'
    'freedom'
    'webrtc'
    'ts:simpleFreedomChat'
    'copy:simpleFreedomChat'
    'copy:simpleFreedomChatLib'
  ]

  taskManager.add 'copypasteFreedomChat', [
    'base'
    'logging'
    'freedom'
    'webrtc'
    'ts:copypasteFreedomChat'
    'copy:copypasteFreedomChat'
    'copy:copypasteFreedomChatLib'
  ]

  taskManager.add 'samples', [
    'simpleFreedomChat'
    'copypasteFreedomChat'
  ]

  taskManager.add 'build', [
    'arraybuffers'
    'taskmanager'
    'handler'
    'logging'
    'crypto'
    'webrtc'
    'freedom'
    'samples'
  ]

  taskManager.add 'test', [
    'build', 'jasmine'
  ]

  grunt.registerTask 'default', [
    'build'
  ]

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
