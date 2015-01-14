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
      distr:
        files: [
          {
              expand: true,
              cwd: 'build/dev/',
              src: ['**',
                    '!**/*.map',
                    '!**/*.spec.js',
              ],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]
      tools:
        files: [
          {
              expand: true,
              cwd: 'build/dev/',
              src: ['**',
                    '!**/*.map',
                    '!**/*.spec.js',
              ],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

    ts:
      all:
        src: [
          'src/**/*.ts'
        ]
        sourceRoot: 'build/',
        mapRoot: 'build/',
        outDir: 'build/'
        target: 'es5',
        comments: true,
        noImplicitAny: true,
        sourceMap: true,
        declaration: true,
        module: 'commonjs'
        fast: 'always',

    clean: ['build/', '.tscache/']

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
