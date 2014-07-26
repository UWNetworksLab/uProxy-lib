TaskManager = require './taskmanager'

fs = require 'fs'
path = require 'path'

FILES =
  jasmine_helpers: [
    # Help Jasmine's PhantomJS understand promises.
    'node_modules/es6-promise/dist/promise-*.js'
    '!node_modules/es6-promise/dist/promise-*amd.js'
    '!node_modules/es6-promise/dist/promise-*.min.js'
  ]

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

# Chrome app-specific Freedom providers.
# TODO: Figure out why this doesn't contain the full path.
freedomForChromeSrc = [].concat(
  freedomForChrome.FILES.platform
).map (fileName) -> path.join(dirname(require.resolve('freedom-for-chrome/Gruntfile')), fileName)

# Firefox addon-specific files and Freedom providers.
# TODO: Figure out why this doesn't contain the full path.
freedomForFirefoxSrc = [].concat(
  'src/backgroundframe-link.js'
  'providers/*.js'
).map (fileName) -> path.join(dirname(require.resolve('freedom-for-firefox/Gruntfile')), fileName)

# Our custom core providers, plus dependencies.
# These files are included with our custom builds of Freedom.
customFreedomCoreProviders = [
  'build/arraybuffers/arraybuffers.js'
  'build/handler/queue.js'
  'build/peerconnection/*.js'
  'build/coreproviders/interfaces/*.js'
  'build/coreproviders/providers/*.js'
]

#------------------------------------------------------------------------------
Rule =
  # Function to make a typescript rule based on expected directory layout.
  typescriptSrc: (name) ->
    src: ['build/typescript-src/' + name + '/**/*.ts',
          '!build/typescript-src/' + name + '/samples/**/*.ts'
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
  typescriptSpecDecl: (name) ->
    src: ['build/typescript-src/' + name + '/**/*.spec.ts',
          'build/typescript-src/' + name + '/**/*.d.ts']
    dest: 'build/'
    options:
      basePath: 'build/typescript-src/'
      ignoreError: false
      noImplicitAny: true
      sourceMap: true
  # Copy all source that is not typescript to the module's build directory.
  copySrcModule: (name) ->
    expand: true, cwd: 'src/'
    src: [name + '/**', '!**/*.ts', '!**/*.sass']
    dest: 'build'
    onlyIf: 'modified'
  # Samples get all compiled code (exlcuding code from sample dir itself - no
  # recursive copying please!) in a 'lib' subdirectory.
  copySampleFiles: (samplePath, libDir) -> { files: [
    { # Copy the sample source to the build sample directory
      expand: true, cwd: 'src/'
      src: [samplePath + '/**/*'
            '!' + samplePath + '/**/*.ts'
            '!' + samplePath + '/**/*.sass']
      dest: 'build/'
      onlyIf: 'modified'
    }, {  # Copy all modules in the build directory to the sample
      expand: true, cwd: 'build'
      src: ['**/*'
            '!**/samples/**'
            '!**/typescript-src/**']
      dest: 'build/' + samplePath + '/' + libDir
      onlyIf: 'modified'
    } ] }
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
  uglifyFreedomForUproxy: (name, files, banners, footers) ->
    options:
      sourceMap: true
      sourceMapName: 'build/freedom/' + name + '.map'
      sourceMapIncludeSources: true
      mangle: false
      beautify: true
      preserveComments: (node, comment) -> comment.value.indexOf('jslint') != 0
      banner: banners.map((fileName) -> fs.readFileSync(fileName)).join('\n')
      footer: footers.map((fileName) -> fs.readFileSync(fileName)).join('\n')
    files: [{
      src: freedomSrc.concat(customFreedomCoreProviders, files)
      dest: path.join('build/freedom/', name)
    }]

module.exports = (grunt) ->

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
      logger: Rule.copySrcModule 'logger'
      # Sample apps to demonstrate and run end-to-end tests.
      sampleChat: Rule.copySampleFiles 'peerconnection/samples/chat-webpage', 'lib'
      sampleChat2: Rule.copySampleFiles 'peerconnection/samples/chat2-webpage', 'lib'
      sampleFreedomchat: Rule.copySampleFiles 'coreproviders/samples/freedomchat-chromeapp', 'lib'

    typescript:
      # For bootstrapping of this Gruntfile
      taskmanager: Rule.typescriptSrc 'taskmanager'
      taskmanagerSpecDecl: Rule.typescriptSpecDecl 'taskmanager'
      # Freedom interfaces (no real spec, only for typescript checking)
      freedomDeclarations: Rule.typescriptSrc 'freedom-declarations'
      freedomDeclarationsSpecDecl: Rule.typescriptSpecDecl 'freedom-declarations'
      # The uProxy modules library
      arraybuffers: Rule.typescriptSrc 'arraybuffers'
      arraybuffersSpecDecl: Rule.typescriptSpecDecl 'arraybuffers'

      handler: Rule.typescriptSrc 'handler'
      handlerSpecDecl: Rule.typescriptSpecDecl 'handler'

      logger: Rule.typescriptSrc 'logger'
      loggerDecl: Rule.typescriptSpecDecl 'logger'

      peerconnection: Rule.typescriptSrc 'peerconnection'
      chat: Rule.typescriptSrc 'peerconnection/samples/chat-webpage'
      chat2: Rule.typescriptSrc 'peerconnection/samples/chat2-webpage'

      coreproviders: Rule.typescriptSrc 'coreproviders'
      freedomchat: Rule.typescriptSrc 'coreproviders/samples/freedomchat-chromeapp'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      taskmanager: Rule.jasmineSpec 'taskmanager'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      logger: Rule.jasmineSpec 'logger'
    clean: ['build/**']

    uglify:
      freedomForUproxy: Rule.uglifyFreedomForUproxy(
        'freedom-for-uproxy.js'
        []
        ['./node_modules/freedom/src/util/preamble.js']
        ['./node_modules/freedom/src/util/postamble.js'])
      freedomForChromeForUproxy: Rule.uglifyFreedomForUproxy(
        'freedom-for-chrome-for-uproxy.js'
        freedomForChromeSrc
        ['./node_modules/freedom/src/util/preamble.js']
        ['./node_modules/freedom/src/util/postamble.js'])
      freedomForFirefoxForUproxy: Rule.uglifyFreedomForUproxy(
        'freedom-for-firefox-for-uproxy.jsm'
        freedomForFirefoxSrc
        ['./node_modules/freedom-for-firefox/src/firefox-preamble.js', './node_modules/freedom/src/util/preamble.js']
        ['./node_modules/freedom-for-firefox/src/firefox-postamble.js'])
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

  taskManager.add 'taskmanager', [
    'base'
    'typescript:taskmanagerSpecDecl'
    'typescript:taskmanager'
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

  taskManager.add 'logger', [
    'copy:logger'
    'base'
    'typescript:logger'
  ]

  taskManager.add 'peerconnection', [
    'base'
    'typescript:peerconnection'
  ]

  taskManager.add 'chat', [
    'base'
    'peerconnection'
    'typescript:chat'
    'copy:sampleChat'
  ]

  taskManager.add 'chat2', [
    'base'
    'peerconnection'
    'typescript:chat2'
    'copy:sampleChat2'
  ]

  taskManager.add 'coreproviders', [
    'base'
    'peerconnection'
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

  taskManager.add 'freedomForFirefoxForUproxy', [
    'coreproviders'
    'uglify:freedomForFirefoxForUproxy'
  ]

  taskManager.add 'freedomchat', [
    'base'
    'freedomForChromeForUproxy'
    'typescript:freedomchat'
    'copy:sampleFreedomchat'
  ]

  taskManager.add 'build', [
    'base'
    'arraybuffers'
    'taskmanager'
    'handler'
    'logger'
    'peerconnection'
    'chat'
    'chat2'
    'freedomchat'
    'freedomForUproxy'
    'freedomForChromeForUproxy'
    'freedomForFirefoxForUproxy'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  taskManager.add 'test', [
<<<<<<< HEAD
    'base'
=======
    'copyTypeScriptBase'
>>>>>>> renamed freedom-interfaces to freedom-declarations
    'typescript:freedomDeclarations'
    'typescript:freedomDeclarationsSpecDecl'
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
