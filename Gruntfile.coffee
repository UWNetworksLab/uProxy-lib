TaskManager = require './tools/taskmanager'
Rule = require './tools/common-grunt-rules'

fs = require 'fs'
path = require 'path'

# Our custom core provider dependencies. These files are included with our
# custom builds of Freedom. Note: they assume that the JS environment has
# includes the necessary dependencies (see samples/freedomchat-chromeapp)
customFreedomCoreProviders = [
  'build/freedom/coreproviders/*.js'
  'build/freedom/interfaces/*.js'
]

module.exports = (grunt) ->
  freedom = require 'freedom/Gruntfile'
  freedomForChrome = require 'freedom-for-chrome/Gruntfile'
  freedomForFirefox = require 'freedom-for-firefox/Gruntfile'

  # Files comprising "core Freedom".
  freedomSrc = [].concat(
    freedom.FILES.srcCore
    freedom.FILES.srcPlatform
  )

  # Like Unix's dirname, e.g. 'a/b/c.js' -> 'a/b'
  dirname = (path) -> path.substr(0, path.lastIndexOf('/'))

  # Chrome and Firefox-specific Freedom providers.
  # TODO: Figure out why this doesn't contain the full path.
  freedomForChromeSrc = [].concat(
    freedomForChrome.FILES.platform
  ).map (fileName) -> path.join(dirname(require.resolve('freedom-for-chrome/Gruntfile')), fileName)
  freedomForFirefoxSrc = [].concat(
    'src/backgroundframe-link.js'
    'providers/*.js'
  ).map (fileName) -> path.join(dirname(require.resolve('freedom-for-firefox/Gruntfile')), fileName)

  # Builds Freedom, with optional extras.
  # By and large, we build Freedom the same way freedom-for-chrome
  # and freedom-for-firefox do. The exception is that we don't include
  # FILES.lib -- since that's currently just es6-promises and because
  # that really doesn't need to be re-included, that's okay.
  uglifyFreedomForUproxy = (name, files, banners, footers) ->
    options:
      sourceMap: true
      sourceMapName: 'build/freedom/' + name + '.map'
      sourceMapIncludeSources: true
      mangle: false
      beautify: true
      preserveComments: 'all'
      banner: banners.map((fileName) -> fs.readFileSync(fileName)).join('\n')
      footer: footers.map((fileName) -> fs.readFileSync(fileName)).join('\n') + '//# sourceMappingURL=' + name + '.map'
    files: [{
      src: freedomSrc.concat(customFreedomCoreProviders).concat(files)
      dest: path.join('build/freedom/', name)
    }]

  # Builds the env that uproxy for * for freedom needs. e.g. stuff for peer
  # connection etc.
  uglifyUproxyCoreEnv =
    options:
      sourceMap: true
      sourceMapName: 'build/freedom/uproxy-core-env.map'
      sourceMapIncludeSources: true
      mangle: false
      beautify: true
      preserveComments: 'all'
    files: [{
      src: ['build/arraybuffers/arraybuffers.js'
            'build/handler/queue.js'
            'build/crypto/random.js'
            'build/logging/logging.js'
            'build/webrtc/third_party/adapter.js'
            'build/webrtc/datachannel.js'
            'build/webrtc/peerconnection.js']
      dest: path.join('build/freedom/uproxy-core-env.js')
    }]

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

    copy:
      crypto: Rule.copyModule 'crypto'

      arraybuffers: Rule.copyModule 'arraybuffers'
      handler: Rule.copyModule 'handler'
      logging: Rule.copyModule 'logging'
      webrtc: Rule.copyModule 'webrtc'

      uproxyCoreEnv:
        files: [
          expand: true
          cwd: 'build/freedom/'
          src: [
            'uproxy-core-env.*'
          ]
          dest: 'dist/freedom/'
        ]

      freedomTypings: Rule.copyModule 'freedom/typings'
      freedomCustomCoreProvidersTypings: Rule.copyModule 'freedom/coreproviders'
      freedomBuilds:
        files: [
          expand: true
          cwd: 'build/freedom/'
          src: [
            'freedom-for-*.*'
          ]
          dest: 'dist/freedom/'
        ]

      simpleWebrtcChat: Rule.copyModule 'samples/simple-webrtc-chat'
      simpleWebrtcChatLib: Rule.copySampleFiles 'samples/simple-webrtc-chat'

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

      webrtc: Rule.typescriptSrc 'webrtc'

      # freedom/typings only contains specs and declarations.
      freedomTypingsSpecDecl: Rule.typescriptSpecDecl 'freedom/typings'
      freedomCoreProviders: Rule.typescriptSrc 'freedom/coreproviders'
      freedomInterfaces: Rule.typescriptSrc 'freedom/interfaces'

      simpleWebrtcChat: Rule.typescriptSrc 'samples/simple-webrtc-chat'
      simpleFreedomChat: Rule.typescriptSrc 'samples/simple-freedom-chat'
      copypasteFreedomChat: Rule.typescriptSrc 'samples/copypaste-freedom-chat'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      taskmanager: Rule.jasmineSpec 'taskmanager'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      logging: Rule.jasmineSpec 'logging'

    clean: ['build/', 'dist/', '.tscache/']

    uglify:
      freedomForWebpagesForUproxy: uglifyFreedomForUproxy(
        'freedom-for-webpages-for-uproxy.js'
        []
        [ './node_modules/freedom/src/util/preamble.js']
        [ 'src/freedom/uproxy-freedom-postamble.js',
          './node_modules/freedom/src/util/postamble.js'])
      freedomForChromeForUproxy: uglifyFreedomForUproxy(
        'freedom-for-chrome-for-uproxy.js'
        freedomForChromeSrc
        [ './node_modules/freedom/src/util/preamble.js']
        [ 'src/freedom/uproxy-freedom-postamble.js',
          './node_modules/freedom/src/util/postamble.js'])
      freedomForFirefoxForUproxy: uglifyFreedomForUproxy(
        'freedom-for-firefox-for-uproxy.jsm'
        freedomForFirefoxSrc
        [ './node_modules/freedom-for-firefox/src/firefox-preamble.js',
          './node_modules/freedom/src/util/preamble.js']
        [ 'src/freedom/uproxy-freedom-postamble.js',
          './node_modules/freedom-for-firefox/src/firefox-postamble.js'])
      uglifyUproxyCoreEnv: uglifyUproxyCoreEnv

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
  ]

  taskManager.add 'uproxyCoreEnv', [
    'crypto'
    'arraybuffers'
    'handler'
    'logging'
    'webrtc'
    'uglify:uglifyUproxyCoreEnv'
    'copy:uproxyCoreEnv'
  ]

  taskManager.add 'taskmanager', [
    'base'
    'ts:taskmanager'
    'ts:taskmanagerSpecDecl'
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
    'uproxyCoreEnv'
    'ts:freedomCoreProviders'
    'ts:freedomInterfaces'
    'ts:freedomTypingsSpecDecl'
    'uglify:freedomForWebpagesForUproxy'
    'uglify:freedomForChromeForUproxy'
    'uglify:freedomForFirefoxForUproxy'
    'copy:freedomTypings'
    'copy:freedomCustomCoreProvidersTypings'
    'copy:freedomBuilds'
  ]

  taskManager.add 'simpleWebrtcChat', [
    'base'
    'uproxyCoreEnv'
    'webrtc'
    'ts:simpleWebrtcChat'
    'copy:simpleWebrtcChat'
    'copy:simpleWebrtcChatLib'
  ]

  taskManager.add 'simpleFreedomChat', [
    'base'
    'freedom'
    'ts:simpleFreedomChat'
    'copy:simpleFreedomChat'
    'copy:simpleFreedomChatLib'
  ]

  taskManager.add 'copypasteFreedomChat', [
    'base'
    'freedom'
    'ts:copypasteFreedomChat'
    'copy:copypasteFreedomChat'
    'copy:copypasteFreedomChatLib'
  ]

  taskManager.add 'samples', [
    'simpleWebrtcChat'
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
    'uproxyCoreEnv'
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
