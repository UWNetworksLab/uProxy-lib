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
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'

    symlink:
      # Symlink all module directories in `src` into typescript-src
      typescriptSrc: { files: [ {
        expand: true,
        overwrite: true,
        cwd: 'src',
        src: ['*'],
        dest: 'build/typescript-src/' } ] }
      # Symlink third_party into typescript-src
      thirdPartyTypescriptSrc: { files: [ {
        expand: true,
        overwrite: true,
        cwd: '.',
        src: ['third_party'],
        dest: 'build/typescript-src/' } ] }

    copy:
      # This rule is used to build the root level task-manager that is checked
      # in.
      localTaskmanager: { files: [ {
        expand: true, cwd: 'build/taskmanager/'
        src: ['taskmanager.js']
        dest: '.' } ] }
      # Copy any JavaScript from the third_party directory
      thirdPartyJavaScript: { files: [ {
          expand: true,
          src: ['third_party/**/*.js']
          dest: 'build/'
          onlyIf: 'modified'
        } ] }
      webrtc: Rule.copyModule 'webrtc'
      # Sample apps to demonstrate and run end-to-end tests.
      sampleChat: Rule.copySampleFiles 'webrtc/samples/chat-webpage', 'lib'
      sampleChat2: Rule.copySampleFiles 'webrtc/samples/chat2-webpage', 'lib'
      sampleFreedomChat: Rule.copySampleFiles 'freedom/samples/freedomchat-chromeapp', 'lib'

    typescript:
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
      chat: Rule.typescriptSrc 'webrtc/samples/chat-webpage'
      chat2: Rule.typescriptSrc 'webrtc/samples/chat2-webpage'

      # Freedom interfaces (no real spec, only for typescript checking)
      freedomTypings: Rule.typescriptSrc 'freedom/typings'
      freedomTypingsSpecDecl: Rule.typescriptSpecDecl 'freedom/typings'
      freedomInterfaces: Rule.typescriptSrc 'freedom/interfaces'
      freedomCoreproviders: Rule.typescriptSrc 'freedom/coreproviders'

      freedomChat: Rule.typescriptSrc 'freedom/samples/freedomchat-chromeapp'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      taskmanager: Rule.jasmineSpec 'taskmanager'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      logging: Rule.jasmineSpec 'logging'

    clean: ['build/**']

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
  }  # grunt.initConfig

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-symlink'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-typescript'

  #-------------------------------------------------------------------------
  # Define the tasks
  taskManager = new TaskManager.Manager();

  taskManager.add 'base', [
    'copy:thirdPartyJavaScript'
    'symlink:thirdPartyTypescriptSrc'
    'symlink:typescriptSrc'
  ]

  taskManager.add 'uproxyCoreEnv', [
    'crypto'
    'arraybuffers'
    'handler'
    'logging'
    'webrtc'
    'uglify:uglifyUproxyCoreEnv'
  ]

  taskManager.add 'taskmanager', [
    'base'
    'typescript:taskmanagerSpecDecl'
    'typescript:taskmanager'
  ]

  taskManager.add 'crypto', [
    'base'
    'typescript:crypto'
  ]

  taskManager.add 'arraybuffers', [
    'base'
    'typescript:arraybuffersSpecDecl'
    'typescript:arraybuffers'
  ]

  taskManager.add 'handler', [
    'base'
    'typescript:handlerSpecDecl'
    'typescript:handler'
  ]

  taskManager.add 'logging', [
    'base'
    'typescript:loggingSpecDecl'
    'typescript:logging'
    'jasmine:logging'
  ]

  taskManager.add 'webrtc', [
    'base'
    'logging'
    'crypto'
    'typescript:webrtc'
    'copy:webrtc'
  ]

  taskManager.add 'chat', [
    'base'
    'uproxyCoreEnv'
    'typescript:chat'
    'copy:sampleChat'
  ]

  taskManager.add 'chat2', [
    'base'
    'uproxyCoreEnv'
    'typescript:chat2'
    'copy:sampleChat2'
  ]

  taskManager.add 'freedomCoreproviders', [
    'base'
    'arraybuffers'
    'handler'
    'logging'
    'webrtc'
    'typescript:freedomCoreproviders'
    'typescript:freedomInterfaces'
  ]

  taskManager.add 'freedomForWebpagesForUproxy', [
    'freedomCoreproviders'
    'uglify:freedomForWebpagesForUproxy'
  ]

  taskManager.add 'freedomForChromeForUproxy', [
    'freedomCoreproviders'
    'uglify:freedomForChromeForUproxy'
  ]

  taskManager.add 'freedomForFirefoxForUproxy', [
    'freedomCoreproviders'
    'uglify:freedomForFirefoxForUproxy'
  ]

  taskManager.add 'freedomChat', [
    'base'
    'freedomForWebpagesForUproxy'
    'uproxyCoreEnv'
    'typescript:freedomChat'
    'copy:sampleFreedomChat'
  ]

  taskManager.add 'build', [
    'base'
    'arraybuffers'
    'taskmanager'
    'handler'
    'logging'
    'crypto'
    'webrtc'
    'uproxyCoreEnv'
    'chat'
    'chat2'
    'freedomForWebpagesForUproxy'
    'freedomForChromeForUproxy'
    'freedomForFirefoxForUproxy'
    'freedomChat'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  taskManager.add 'test', [
    'base'
    'typescript:freedomTypings'
    'typescript:freedomTypingsSpecDecl'
    'build'
    'jasmine:handler'
    'jasmine:taskmanager'
    'jasmine:arraybuffers'
    'jasmine:logging'
  ]

  taskManager.add 'default', [
    'build', 'test'
  ]

  taskManager.add 'distr', [
    'build', 'test', 'copy:localTaskmanager'
  ]

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
