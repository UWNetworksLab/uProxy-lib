TaskManager = require './tools/taskmanager'
Rule = require './tools/common-grunt-rules'

path = require 'path'

module.exports = (grunt) ->
  #-------------------------------------------------------------------------
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    # TODO: This must be factored out into common-grunt-rules.
    symlink:
      # Symlink each source file under src/ under build/.
      build:
        files: [
          expand: true
          cwd: 'src/'
          src: ['**/*']
          filter: 'isFile'
          dest: 'build/'
        ]
      # Symlink each directory under third_party/ under build/third_party/.
      thirdParty:
        files: [
          expand: true,
          cwd: 'third_party/'
          src: ['*']
          filter: 'isDirectory'
          dest: 'build/third_party/'
        ]
      # Symlink the Chrome and Firefox builds of Freedom under build/freedom/.
      freedom:
        files: [ {
          expand: true
          cwd: path.dirname(require.resolve('freedom/Gruntfile'))
          src: ['freedom.js']
          dest: 'build/freedom/'
        } ]

    copy:
      crypto: Rule.copyModule 'crypto'
      taskmanager: Rule.copyModule 'taskmanager'
      arraybuffers: Rule.copyModule 'arraybuffers'
      handler: Rule.copyModule 'handler'
      logging: Rule.copyModule 'logging'
      loggingprovider: Rule.copyModule 'loggingprovider'
      webrtc: Rule.copyModule 'webrtc'

      freedomTypings: Rule.copyModule 'freedom/typings'

      simpleFreedomChat: Rule.copyModule 'samples/simple-freedom-chat'
      simpleFreedomChatLib: Rule.copySampleFiles 'samples/simple-freedom-chat'

      copypasteFreedomChat: Rule.copyModule 'samples/copypaste-freedom-chat'
      copypasteFreedomChatLib: Rule.copySampleFiles 'samples/copypaste-freedom-chat'

    ts:
      # For bootstrapping of this Gruntfile
      taskmanager: Rule.typescriptSrc 'taskmanager'
      taskmanagerSpecDecl: Rule.typescriptSpecDecl 'taskmanager'

      # The uProxy modules library
      crypto: Rule.typescriptSrc 'crypto'

      arraybuffers: Rule.typescriptSrc 'arraybuffers'
      arraybuffersSpecDecl: Rule.typescriptSpecDecl 'arraybuffers'

      handler: Rule.typescriptSrc 'handler'
      handlerSpecDecl: Rule.typescriptSpecDecl 'handler'

      logging: Rule.typescriptSrc 'logging'
      loggingSpecDecl: Rule.typescriptSpecDecl 'logging'

      loggingProvider: Rule.typescriptSrc 'loggingprovider'
      loggingProviderSpecDecl: Rule.typescriptSpecDecl 'loggingprovider'

      webrtc: Rule.typescriptSrc 'webrtc'

      # freedom/typings only contains specs and declarations.
      freedomTypingsSpecDecl: Rule.typescriptSpecDecl 'freedom/typings'

      simpleFreedomChat: Rule.typescriptSrc 'samples/simple-freedom-chat'
      copypasteFreedomChat: Rule.typescriptSrc 'samples/copypaste-freedom-chat'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      taskmanager: Rule.jasmineSpec 'taskmanager'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      loggingProvider: Rule.jasmineSpec('loggingprovider',
        [
          'build/logging/mocks.js'
          'build/loggingprovider/loggingprovider.js'
        ])
      logging: Rule.jasmineSpec('logging',
        [
          'build/logging/mocks.js'
          'build/logging/logging.js',
          require.resolve('es6-promise/dist/promise-1.0.0')
        ])

    clean: ['build/', 'dist/', '.tscache/']

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

  taskManager.add 'base', [
    'symlink:build'
    'symlink:thirdParty'
    'symlink:freedom'
  ]

  taskManager.add 'taskmanager', [
    'base'
    'ts:taskmanager'
    'ts:taskmanagerSpecDecl'
    'copy:taskmanager'
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

  taskManager.add 'loggingprovider', [
    'base'
    'ts:loggingProvider'
    'ts:loggingProviderSpecDecl'
    'copy:loggingprovider'
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
    'loggingprovider'
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
