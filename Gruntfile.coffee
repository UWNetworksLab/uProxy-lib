TaskManager = require './taskmanager'

FILES =
  jasmine_helpers: [
    # Help Jasmine's PhantomJS understand promises.
    'node_modules/es6-promise/dist/promise-*.js'
    '!node_modules/es6-promise/dist/promise-*amd.js'
    '!node_modules/es6-promise/dist/promise-*.min.js'
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

module.exports = (grunt) ->

  path = require 'path';

  #-------------------------------------------------------------------------
  # By and large, we build freedom the same way freedom-for-chrome
  # and freedom-for-firefox do. The exception is that we don't include
  # FILES.lib -- since that's currently just es6-promises and because
  # that really doesn't need to be re-included, that's okay.
  #
  # require.resolve returns the path to Freedom's Gruntfile.
  # We want to get the dirName, i.e. convert
  #   /SOME/ABSOLUTE/PATH/uproxy-lib/node_modules/freedom/Gruntfile.js
  # to
  #   /SOME/ABSOLUTE/PATH/uproxy-lib/node_modules/freedom/
  freedomPrefix = require.resolve('freedom').substr(0,
    require.resolve('freedom').lastIndexOf('/') + 1)
  freedom = require 'freedom'
  freedomSrc = [].concat(
    freedom.FILES.srcCore
    freedom.FILES.srcPlatform
  ).map (path) -> if grunt.file.isPathAbsolute(path) then path else freedomPrefix + path

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

      freedomTypeScriptApi: { files: [ {
        expand: true, cwd: 'node_modules/freedom-typescript-api'
        src: ['interfaces/**/*.ts']
        dest: 'build/typescript-src/freedom-typescript-api/' } ] }

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
      scratch: {
        files: [ {
          expand: true, cwd: 'src/samples/scratch/'
          src: ['**/*']
          dest: 'build/samples/scratch/'
        }, {
          expand: true, cwd: 'build/'
          src: ['freedom-for-uproxy.js']
          dest: 'build/samples/scratch/chrome/lib/'
        } ]
      }

    typescript:
      taskmanager: Rule.typeScriptSrc 'taskmanager'
      taskmanagerSpecDecl: Rule.typeScriptSpecDecl 'taskmanager'
      arraybuffers: Rule.typeScriptSrc 'arraybuffers'
      arraybuffersSpecDecl: Rule.typeScriptSpecDecl 'arraybuffers'
      handler: Rule.typeScriptSrc 'handler'
      handlerSpecDecl: Rule.typeScriptSpecDecl 'handler'
      freedomTypescriptApiTest: Rule.typeScriptSrc 'freedom-typescript-api_d_test'
      logger: Rule.typeScriptSrc 'logger'
      peerconnection: Rule.typeScriptSrc 'peerconnection'
      chat: Rule.typeScriptSrc 'samples/chat'
      chat2: Rule.typeScriptSrc 'samples/chat2'
      coreproviders: Rule.typeScriptSrc 'coreproviders'
      scratch: Rule.typeScriptSrc 'samples/scratch'

    jasmine:
      handler: Rule.jasmineSpec 'handler'
      taskmanager: Rule.jasmineSpec 'taskmanager'
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      logger: Rule.jasmineSpec 'logger'
    clean: ['build/**']

    uglify:
      freedom:
        options:
          sourceMap: true
          # sourceMapName must be the same as that defined in the final comment
          # of freedom/src/util/postamble.js.
          sourceMapName: 'build/freedom.js.map'
          sourceMapIncludeSources: true
          mangle: false
          # compress: false, wrap: false, // uncomment to get a clean out file.
          beautify: true
          preserveComments: (node, comment) -> comment.value.indexOf('jslint') != 0
          banner: require('fs').readFileSync(freedomPrefix + 'src/util/preamble.js', 'utf8')
          footer: require('fs').readFileSync(freedomPrefix + 'src/util/postamble.js', 'utf8')
        files:
          'build/freedom-for-uproxy.js': freedomSrc.concat(
            'build/coreproviders/interfaces/*.js'
            'build/coreproviders/providers/*.js')

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

  taskManager.add 'typeScriptBase', [
    'copy:freedomTypeScriptApi'
    'copy:thirdPartyTypeScript'
    'copy:typeScriptSrc'
    'typescript:freedomTypescriptApiTest'
  ]

  taskManager.add 'taskmanager', [
    'typeScriptBase'
    'typescript:taskmanagerSpecDecl'
    'typescript:taskmanager'
  ]

  taskManager.add 'arraybuffers', [
    'typeScriptBase'
    'typescript:arraybuffersSpecDecl'
    'typescript:arraybuffers'
  ]

  taskManager.add 'handler', [
    'typeScriptBase'
    'typescript:handlerSpecDecl'
    'typescript:handler'
  ]

  taskManager.add 'logger', [
    'copy:logger'
    'typeScriptBase'
    'typescript:logger'
  ]

  taskManager.add 'peerconnection', [
    'copy:peerconnection'
    'typeScriptBase'
    'typescript:peerconnection'
  ]

  taskManager.add 'chat', [
    'copy:chat'
    'typeScriptBase'
    'typescript:chat'
  ]

  taskManager.add 'chat2', [
    'copy:chat2'
    'typeScriptBase'
    'typescript:chat2'
  ]

  taskManager.add 'coreproviders', [
    'typeScriptBase'
    'typescript:coreproviders'
  ]

  taskManager.add 'freedomforuproxy', [
    'coreproviders'
    'uglify'
  ]

  taskManager.add 'scratch', [
    'freedomforuproxy'
    'typeScriptBase'
    'typescript:scratch'
    'copy:scratch'
  ]

  taskManager.add 'build', [
    'typeScriptBase'
    'arraybuffers'
    'taskmanager'
    'handler'
    'logger'
    'peerconnection'
    'chat'
    'chat2'
    'scratch'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  taskManager.add 'test', [
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
