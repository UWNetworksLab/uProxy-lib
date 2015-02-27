TaskManager = require './build/tools/taskmanager'

#-------------------------------------------------------------------------
# The top level tasks. These are the highest level grunt-tasks defined in terms
# of specific grunt rules below and given to grunt.initConfig
taskManager = new TaskManager.Manager();

# Makes the base development build, excludes sample apps.
taskManager.add 'base', [
  'symlink:typescriptSrc'
  'copy:third_party'
  'copy:dev'
  'ts:devInModuleEnv'
  'ts:devInCoreEnv'
  'browserify:loggingProvider'
]

# Makes all sample apps.
taskManager.add 'samples', [
  'base'
  'simpleFreedomChat'
  'copypasteFreedomChat'
]

# Makes the distribution build.
taskManager.add 'dist', [
  'base',
  'samples',
  'copy:dist'
]

# Build the simple freedom chat sample app.
taskManager.add 'simpleFreedomChat', [
  'base'
  'copy:libsForSimpleFreedomChat'
  'browserify:simpleFreedomChatMain'
  'browserify:simpleFreedomChatFreedomModule'
]

# Build the copy/paste freedom chat sample app.
taskManager.add 'copypasteFreedomChat', [
  'base'
  'copy:libsForCopypasteFreedomChat'
  'browserify:copypasteFreedomChatMain'
  'browserify:copypasteFreedomChatFreedomModule'
]

# Run unit tests
taskManager.add 'unit_tests', [
  'base'
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
taskManager.add 'default', ['base', 'unit_tests', 'dist']

#-------------------------------------------------------------------------
rules = require './build/tools/common-grunt-rules'
path = require 'path'

#-------------------------------------------------------------------------
devBuildPath = 'build/dev/uproxy-lib'
thirdPartyBuildPath = 'build/third_party'
localLibsDestPath = 'uproxy-lib'
Rule = new rules.Rule({
  devBuildPath: devBuildPath,
  thirdPartyBuildPath: thirdPartyBuildPath,
  localLibsDestPath: localLibsDestPath
});

module.exports = (grunt) ->
  config =
    pkg: grunt.file.readJSON 'package.json'

    symlink:
      # Sym-link typeScript sources from src/ to build/dev/uproxy-lib/
      typescriptSrc:
        files: [{
          expand: true
          overwrite: false
          cwd: 'src'
          src: ['**/*.ts']
          dest: devBuildPath
        }]

    # Sym-links are prefered, but chrome apps require real files. So we copy all
    # non-compiled files.
    copy:
      # Copy releveant non-typescript files to dev build.
      dev:
        files: [
          {
              nonull: true,
              expand: true,
              cwd: 'src/',
              src: ['**/*', '!**/*.ts'],
              dest: devBuildPath,
              onlyIf: 'modified'
          }
        ]
      # Copy |third_party| to build folder: this is so that there is a common
      # |thirdPartyBuildPath| location to reference typescript definitions for
      # ambient contexts.
      third_party:
        files: [
          {
              nonull: true,
              expand: true,
              cwd: 'third_party'
              src: ['**/*'],
              dest: thirdPartyBuildPath,
              onlyIf: 'modified'
          }
        ]
      # Copy releveant non-typescript files to distribution build.
      dist:
        files: [
          {
              nonull: true,
              expand: true,
              cwd: devBuildPath,
              src: ['**/*',
                    '!**/*.spec.js',
                    '!**/*.ts',
                    '**/*.d.ts'],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

      # Copy the freedom output file to sample apps
      # Rule.copyLibs [npmModules], [localDirectories], [thirdPartyDirectories]
      libsForSimpleFreedomChat:
        Rule.copyLibs ['freedom'], ['loggingprovider'], [],
          'samples/simple-freedom-chat/'
      libsForCopypasteFreedomChat:
        Rule.copyLibs ['freedom'], ['loggingprovider'], [],
          'samples/copypaste-freedom-chat/'

    # Typescript rules
    ts:
      # Compile everything that can run in a module env into the development
      # build directory.
      devInModuleEnv:
        src: [
          devBuildPath + '/**/*.ts'
          '!' + devBuildPath + '/**/*.core-env.ts'
          '!' + devBuildPath + '/**/*.core-env.spec.ts'
        ]
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: false
          declaration: true
          module: 'commonjs'
          fast: 'always'
      # Compile everything that must run in the core env into the development
      # build directory.
      devInCoreEnv:
        src: [
          devBuildPath + '/**/*.core-env.ts'
          devBuildPath + '/**/*.core-env.spec.ts'
        ]
        options:
          target: 'es5'
          comments: true
          noImplicitAny: true
          sourceMap: false
          declaration: true
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
      # Browserify freedom-modules in the library
      loggingProvider: Rule.browserify 'loggingprovider/freedom-module'
      # Browserify specs
      arraybuffersSpec: Rule.browserifySpec 'arraybuffers/arraybuffers'
      buildToolsTaskmanagerSpec: Rule.browserifySpec 'build-tools/taskmanager'
      handlerSpec: Rule.browserifySpec 'handler/queue'
      loggingProviderSpec: Rule.browserifySpec 'loggingprovider/loggingprovider'
      loggingSpec: Rule.browserifySpec 'logging/logging'
      webrtcSpec: Rule.browserifySpec 'webrtc/peerconnection'
      # Browserify sample apps main freedom module and core environments
      copypasteFreedomChatMain: Rule.browserify 'samples/copypaste-freedom-chat/main.core-env'
      copypasteFreedomChatFreedomModule: Rule.browserify 'samples/copypaste-freedom-chat/freedom-module'
      simpleFreedomChatMain: Rule.browserify 'samples/simple-freedom-chat/main.core-env'
      simpleFreedomChatFreedomModule: Rule.browserify 'samples/simple-freedom-chat/freedom-module'

    clean:
      build:
        [ 'build/dev', 'build/dist'
          '.tscache/']

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
