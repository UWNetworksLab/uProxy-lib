TaskManager = require './taskmanager'
path = require 'path'
freedom = require 'freedom'
freedomForChrome = require 'freedom-for-chrome/Gruntfile'

FILES =
  jasmine_helpers: [
    # Help Jasmine's PhantomJS understand promises.
    'node_modules/es6-promise/dist/promise-*.js'
    '!node_modules/es6-promise/dist/promise-*amd.js'
    '!node_modules/es6-promise/dist/promise-*.min.js'
  ]

# Like Unix's dirname, e.g. 'a/b/c.js' -> 'a/b'
dirname = (path) -> path.substr(0, path.lastIndexOf('/'))

# Compute absolute paths to the files comprising "core Freedom".
freedomPrefix = dirname(require.resolve('freedom'))
freedomSrc = [].concat(
  freedom.FILES.srcCore
  freedom.FILES.srcPlatform
).map (fileName) -> path.join(freedomPrefix, fileName)

# Compute absolute paths to the Chrome app-specific Freedom providers.
freedomForChromePrefix = dirname(require.resolve('freedom-for-chrome/Gruntfile'))
freedomForChromeSrc = [].concat(
  freedomForChrome.FILES.platform
).map (fileName) -> path.join(freedomForChromePrefix, fileName)

# Our custom core providers, plus dependencies.
# These files are included with our custom builds of Freedom.
customFreedomCoreProviders = [
  'build/arraybuffers/arraybuffers.js'
  'build/handler/queue.js'
  'build/peerconnection/*.js'
  'build/coreproviders/interfaces/*.js'
  'build/coreproviders/providers/*.js'
]

Rule =
  #-------------------------------------------------------------------------
  # Function to make a typescript rule based on expected directory layout.
  typeScriptSrc: (name) ->
    src: ['build/typescript-src/' + name + '/**/*.ts',
          '!build/typescript-src/' + name + '/**/*.d.ts']
    dest: 'build/'
    options:
      basePath: 'build/typescript-src/'
      ignoreError: false
      noImplicitAny: true
      sourceMap: true
  # This is a typescript compilation rule that makes sure unit tests can
  # typecheck with the declaration files only. This is a quick way to check
  # declaration files are approximately valid/match the implementation file.
  typeScriptSpecDecl: (name) ->
    src: ['build/typescript-src/' + name + '/**/*.spec.ts',
          'build/typescript-src/' + name + '/**/*.d.ts']
    dest: 'build/'
    options:
      basePath: 'build/typescript-src/'
      ignoreError: false
      noImplicitAny: true
      sourceMap: true
  # Function to make jasmine spec assuming expected dir layout.
  jasmineSpec: (name) ->
    src: FILES.jasmine_helpers.concat([
      'build/' + name + '/**/*.js',
      '!build/' + name + '/**/*.spec.js'
    ])
    options:
      specs: 'build/' + name + '/**/*.spec.js'
      outfile: 'build/' + name + '/_SpecRunner.html'
      keepRunner: true
  # By and large, we build Freedom the same way freedom-for-chrome
  # and freedom-for-firefox do. The exception is that we don't include
  # FILES.lib -- since that's currently just es6-promises and because
  # that really doesn't need to be re-included, that's okay.
  freedomForUproxy: (name, files) ->
    options:
      sourceMap: true
      # TODO: This should match the final comment in postamble.js.
      sourceMapName: 'build/freedom.js.map'
      sourceMapIncludeSources: true
      mangle: false
      beautify: true
      preserveComments: (node, comment) -> comment.value.indexOf('jslint') != 0
      banner: require('fs').readFileSync(path.join(freedomPrefix, 'src/util/preamble.js'), 'utf8')
      footer: require('fs').readFileSync(path.join(freedomPrefix, 'src/util/postamble.js'), 'utf8')
    files: [{
      src: freedomSrc.concat(customFreedomCoreProviders, files)
      dest: path.join('build', [name, 'for-uproxy.js'].join('-'))
    }]

module.exports = (grunt) ->

  #-------------------------------------------------------------------------
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'

    copy:
      # Copt all third party typescript, including node_modules,
      # into build/typescript-src
      thirdPartyTypeScript: { files: [
        {
          expand: true
          src: ['third_party/**/*.ts']
          dest: 'build/typescript-src/'
        }
      ]}
      # Copy all typescript into the 'build/typescript-src/' dir.
      typeScriptSrc: { files: [ {
        expand: true, cwd: 'src/'
        src: ['**/*.ts']
        dest: 'build/typescript-src/' } ] }

      # This rule is used to
      localTaskmanager: { files: [ {
        expand: true, cwd: 'build/taskmanager/'
        src: ['taskmanager.js']
        dest: '.' } ] }

      logger: { files: [ {
        expand: true, cwd: 'src/logger'
        src: ['*.json']
        dest: 'build/logger/' } ] }

      peerconnection: { files: [ {
        expand: true, cwd: 'src/peerconnection'
        src: ['*.json']
        dest: 'build/peerconnection/' } ] }

      chat: {
        files: [ {
          expand: true, cwd: 'src/samples/chat/'
          src: ['*.html']
          dest: 'build/samples/chat/'
        }, {
          expand: true, cwd: 'build/peerconnection/'
          src: ['**/*']
          dest: 'build/samples/chat/peerconnection/'
        }, {
          expand: true, cwd: 'build/handler/'
          src: ['**/*']
          dest: 'build/samples/chat/handler/'
        }, {
          expand: true, cwd: 'third_party/webrtc-adapter/'
          src: ['**/*']
          dest: 'build/samples/chat/webrtc-adapter/'
        } ]
      }

      chat2: {
        files: [ {
          expand: true, cwd: 'src/samples/chat2/'
          src: ['*.html']
          dest: 'build/samples/chat2/'
        }, {
          expand: true, cwd: 'build/peerconnection/'
          src: ['**/*']
          dest: 'build/samples/chat2/peerconnection/'
        }, {
          expand: true, cwd: 'build/handler/'
          src: ['**/*']
          dest: 'build/samples/chat2/handler/'
        }, {
          expand: true, cwd: 'third_party/angular/'
          src: ['**/*']
          dest: 'build/samples/chat2/angular/'
        }, {
          expand: true, cwd: 'third_party/webrtc-adapter/'
          src: ['**/*']
          dest: 'build/samples/chat2/webrtc-adapter/'
        } ]
      }

      # Throwaway app to verify freedom-for-uproxy works.
      freedomchat: {
        files: [ {
          expand: true, cwd: 'src/samples/freedomchat/'
          src: ['**/*']
          dest: 'build/samples/freedomchat/'
        }, {
          expand: true, cwd: 'build/'
          src: ['freedom-for-chrome-for-uproxy.js']
          dest: 'build/samples/freedomchat/chrome/lib/'
        }, {
          expand: true, cwd: 'third_party/webrtc-adapter/'
          src: ['**/*']
          dest: 'build/samples/freedomchat/chrome/webrtc-adapter/'
        } ]
      }

    typescript:
      # For bootstrapping of this Gruntfile
      taskmanager: Rule.typeScriptSrc 'taskmanager'
      taskmanagerSpecDecl: Rule.typeScriptSpecDecl 'taskmanager'
      # Freedom interfaces (no real spec, only for typescript checking)
      freedomInterfaces: Rule.typeScriptSrc 'freedom-interfaces'
      freedomInterfacesDecl: Rule.typeScriptSpecDecl 'freedom-interfaces'
      # The uProxy modules library
      arraybuffers: Rule.typeScriptSrc 'arraybuffers'
      arraybuffersSpecDecl: Rule.typeScriptSpecDecl 'arraybuffers'
      handler: Rule.typeScriptSrc 'handler'
      handlerSpecDecl: Rule.typeScriptSpecDecl 'handler'
      logger: Rule.typeScriptSrc 'logger'
      loggerDecl: Rule.typeScriptSpecDecl 'logger'
      peerconnection: Rule.typeScriptSrc 'peerconnection'
      chat: Rule.typeScriptSrc 'samples/chat'
      chat2: Rule.typeScriptSrc 'samples/chat2'
      coreproviders: Rule.typeScriptSrc 'coreproviders'
      freedomchat: Rule.typeScriptSrc 'samples/freedomchat'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      taskmanager: Rule.jasmineSpec 'taskmanager'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      logger: Rule.jasmineSpec 'logger'
    clean: ['build/**']

    uglify:
      freedomForUproxy: Rule.freedomForUproxy('freedom', [])
      freedomForChromeForUproxy: Rule.freedomForUproxy('freedom-for-chrome', freedomForChromeSrc)

  }  # grunt.initConfig

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-typescript'
  grunt.loadNpmTasks 'grunt-contrib-uglify'

  #-------------------------------------------------------------------------
  # Define the tasks
  taskManager = new TaskManager.Manager();

  taskManager.add 'copyTypeScriptBase', [
    'copy:thirdPartyTypeScript'
    'copy:typeScriptSrc'
  ]

  taskManager.add 'taskmanager', [
    'copyTypeScriptBase'
    'typescript:taskmanagerSpecDecl'
    'typescript:taskmanager'
  ]

  taskManager.add 'arraybuffers', [
    'copyTypeScriptBase'
    'typescript:arraybuffersSpecDecl'
    'typescript:arraybuffers'
  ]

  taskManager.add 'handler', [
    'copyTypeScriptBase'
    'typescript:handlerSpecDecl'
    'typescript:handler'
  ]

  taskManager.add 'logger', [
    'copyTypeScriptBase'
    'typescript:logger'
  ]

  taskManager.add 'peerconnection', [
    'copy:peerconnection'
    'copyTypeScriptBase'
    'typescript:peerconnection'
  ]

  taskManager.add 'chat', [
    'copy:chat'
    'copyTypeScriptBase'
    'typescript:chat'
  ]

  taskManager.add 'chat2', [
    'copy:chat2'
    'copyTypeScriptBase'
    'typescript:chat2'
  ]

  taskManager.add 'coreproviders', [
    'peerconnection'
    'copyTypeScriptBase'
    'typescript:coreproviders'
  ]

  taskManager.add 'freedomForUproxy', [
    'coreproviders'
    'uglify:freedomForUproxy'
  ]

  taskManager.add 'freedomForChromeForUproxy', [
    'coreproviders'
    'uglify:freedomForChromeForUproxy'
  ]

  taskManager.add 'freedomchat', [
    'freedomForChromeForUproxy'
    'copyTypeScriptBase'
    'typescript:freedomchat'
    'copy:freedomchat'
  ]

  taskManager.add 'build', [
    'copyTypeScriptBase'
    'arraybuffers'
    'taskmanager'
    'handler'
    'logger'
    'peerconnection'
    'chat'
    'chat2'
    'freedomchat'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  taskManager.add 'test', [
    'copyTypeScriptBase'
    'typescript:freedomInterfaces'
    'typescript:freedomInterfacesDecl'
    'build'
    'jasmine:handler'
    'jasmine:taskmanager'
    'jasmine:arraybuffers'
    'jasmine:logger'
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

module.exports.FILES = FILES;
module.exports.Rule = Rule;
