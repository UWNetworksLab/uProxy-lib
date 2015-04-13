TaskManager = require './build/tools/taskmanager'

#-------------------------------------------------------------------------
# The top level tasks. These are the highest level grunt-tasks defined in terms
# of specific grunt rules below and given to grunt.initConfig
taskManager = new TaskManager.Manager();

# Makes the base development build, excludes sample apps.
taskManager.add 'base', [
  'copy:src'
  'ts:srcInModuleEnv'
  'ts:srcInCoreEnv'
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
  'base'
  'samples'
  'unit_test'
  'coverage'
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

# Create unit test code
taskManager.add 'browserifySpecs', [
  'base'
  'browserify:arraybuffersSpec'
  'browserify:handlerSpec'
  'browserify:buildToolsTaskmanagerSpec'
  'browserify:loggingSpec'
  'browserify:loggingProviderSpec'
  'browserify:peerconnectionSpec'
  'browserify:datachannelSpec'
  'browserify:queueSpec'
]

# Create unit test code
taskManager.add 'browserifyCovSpecs', [
  'base'
  'browserify:arraybuffersCovSpec'
  'browserify:handlerCovSpec'
  'browserify:buildToolsTaskmanagerCovSpec'
  'browserify:loggingCovSpec'
  'browserify:loggingProviderCovSpec'
  'browserify:peerconnectionCovSpec'
  'browserify:datachannelCovSpec'
  'browserify:queueCovSpec'
]

# Run unit tests
taskManager.add 'unit_test', [
  'browserifySpecs',
  'jasmine:arraybuffers'
  'jasmine:handler'
  'jasmine:buildTools'
  'jasmine:logging'
  'jasmine:loggingProvider'
  'jasmine:webrtc'
  'jasmine:queue'
]

# Run unit tests to produce coverage; these are separate from unit_tests because
# they make tests hard to debug and fix.
taskManager.add 'coverage', [
  'browserifyCovSpecs'
  'jasmine:arraybuffersCov'
  'jasmine:handlerCov'
  'jasmine:buildToolsCov'
  'jasmine:loggingCov'
  'jasmine:loggingProviderCov'
  'jasmine:webrtcCov'
  'jasmine:queueCov'
]

# Run unit tests
taskManager.add 'test', ['unit_test']

# Default task, build dev, run tests, make the distribution build.
taskManager.add 'default', ['base']

#-------------------------------------------------------------------------
rules = require './build/tools/common-grunt-rules'
path = require 'path'

#-------------------------------------------------------------------------
devBuildPath = 'build/dev/uproxy-lib'
thirdPartyBuildPath = 'build/third_party'
localLibsDestPath = 'uproxy-lib'
Rule = new rules.Rule({
  # The path where code in this repository should be built in.
  devBuildPath: devBuildPath,
  # The path from where third party libraries should be copied. e.g. as used by
  # sample apps.
  thirdPartyBuildPath: thirdPartyBuildPath,
  # The path to copy modules from this repository into. e.g. as used by sample
  # apps.
  localLibsDestPath: localLibsDestPath
});

module.exports = (grunt) ->
  config =
    pkg: grunt.file.readJSON 'package.json'

    copy:
      # Copy all src files into the directory for compiling and building.
      src:
        files: [
          {
              nonull: true,
              expand: true,
              cwd: 'src/',
              src: ['**/*'],
              dest: devBuildPath,
              onlyIf: 'modified'
          }
        ]
      # Copy releveant files to distribution directory.
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
        Rule.copyLibs
          npmLibNames: ['freedom']
          pathsFromDevBuild: ['loggingprovider']
          localDestPath: 'samples/simple-freedom-chat/'

      libsForCopypasteFreedomChat:
        Rule.copyLibs
          npmLibNames: ['freedom']
          pathsFromDevBuild: ['loggingprovider']
          localDestPath: 'samples/copypaste-freedom-chat/'

    # Typescript rules
    ts:
      # Compile everything that can run in a module env into the development
      # build directory.
      srcInModuleEnv:
        src: [
          devBuildPath + '/**/*.ts'
          '!' + devBuildPath + '/**/*.d.ts'
          '!' + devBuildPath + '/**/*.core-env.ts'
          '!' + devBuildPath + '/**/*.core-env.spec.ts'
        ]
        options:
          comments: true
          declaration: true
          fast: 'always'
          module: 'commonjs'
          noImplicitAny: true
          sourceMap: false
          target: 'es5'
      # Compile everything that must run in the core env into the development
      # build directory.
      srcInCoreEnv:
        src: [
          devBuildPath + '/**/*.core-env.ts'
          devBuildPath + '/**/*.core-env.spec.ts'
          '!' + devBuildPath + '/**/*.d.ts'
        ]
        options:
          comments: true
          declaration: false
          fast: 'always'
          module: 'commonjs'
          noImplicitAny: true
          sourceMap: false
          target: 'es5'

    jasmine:
      arraybuffers: Rule.jasmineSpec 'arraybuffers'
      arraybuffersCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'arraybuffers')
      buildTools: Rule.jasmineSpec 'build-tools'
      buildToolsCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'build-tools')
      handler: Rule.jasmineSpec 'handler'
      handlerCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'handler')
      logging: Rule.jasmineSpec 'logging'
      loggingCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'logging')
      loggingProvider: Rule.jasmineSpec 'loggingprovider'
      loggingProviderCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'loggingprovider')
      webrtc: Rule.jasmineSpec 'webrtc'
      webrtcCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'webrtc')
      queue: Rule.jasmineSpec 'queue'
      queueCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'queue')

    browserify:
      # Browserify freedom-modules in the library
      loggingProvider: Rule.browserify 'loggingprovider/freedom-module'
      # Browserify specs
      arraybuffersSpec: Rule.browserifySpec 'arraybuffers/arraybuffers'
      arraybuffersCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'arraybuffers/arraybuffers')
      buildToolsTaskmanagerSpec: Rule.browserifySpec 'build-tools/taskmanager'
      buildToolsTaskmanagerCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'build-tools/taskmanager')
      handlerSpec: Rule.browserifySpec 'handler/queue'
      handlerCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'handler/queue')
      loggingProviderSpec: Rule.browserifySpec 'loggingprovider/loggingprovider'
      loggingProviderCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'loggingprovider/loggingprovider')
      loggingSpec: Rule.browserifySpec 'logging/logging'
      loggingCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'logging/logging')
      peerconnectionSpec: Rule.browserifySpec 'webrtc/peerconnection'
      peerconnectionCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'webrtc/peerconnection')
      datachannelSpec: Rule.browserifySpec 'webrtc/datachannel'
      datachannelCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'webrtc/datachannel')
      queueSpec: Rule.browserifySpec 'queue/queue'
      queueCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'queue/queue')
      # Browserify sample apps main freedom module and core environments
      copypasteFreedomChatFreedomModule: Rule.browserify 'samples/copypaste-freedom-chat/freedom-module'
      copypasteFreedomChatMain: Rule.browserify 'samples/copypaste-freedom-chat/main.core-env'
      simpleFreedomChatFreedomModule: Rule.browserify 'samples/simple-freedom-chat/freedom-module'
      simpleFreedomChatMain: Rule.browserify 'samples/simple-freedom-chat/main.core-env'

    clean:
      build:
        [ 'build/dev', 'build/dist', '.tscache/']

  #-------------------------------------------------------------------------
  grunt.initConfig config

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-symlink'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-ts'

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
