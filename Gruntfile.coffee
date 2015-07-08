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
  'browserify:echoFreedomModule'
  'browserify:simpleSocksFreedomModule'
  'browserify:churnPipeFreedomModule'
  'browserify:portControlFreedomModule'
]

# Makes all sample apps.
taskManager.add 'samples', [
  'base'
  'simpleFreedomChat'
  'copypasteFreedomChat'
  'echoServerChromeApp'
  'echoServerFirefoxApp'
  'simpleSocksChromeApp'
  'simpleSocksFirefoxApp'
  'copyPasteSocks'
  'simpleTurn'
  'simpleChurnChatChromeApp'
  'copyPasteChurnChatChromeApp'
]

# Makes the distribution build.
taskManager.add 'dist', [
  'base'
  'samples'
  'test'
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

taskManager.add 'echoServerChromeApp', [
  'base'
  'copy:libsForEchoServerChromeApp'
  'browserify:echoServerChromeApp'
]

taskManager.add 'echoServerFirefoxApp', [
  'base'
  'copy:libsForEchoServerFirefoxApp'
]

taskManager.add 'simpleSocksChromeApp', [
  'base'
  'copy:libsForSimpleSocksChromeApp'
  'browserify:simpleSocksChromeApp'
]

taskManager.add 'simpleSocksFirefoxApp', [
  'base'
  'copy:libsForSimpleSocksFirefoxApp'
]

taskManager.add 'copyPasteSocks', [
  'base'
  'browserify:copyPasteSocksFreedomModule'
  'browserify:copyPasteSocksMain'
  'vulcanize:copyPasteSocks'
  'copy:libsForCopyPasteSocksChromeApp'
  'copy:libsForCopyPasteSocksFirefoxApp'
]

taskManager.add 'simpleTurn', [
  'base'
  'browserify:simpleTurnFreedomModule'
  'browserify:turnBackendFreedomModule'
  'browserify:turnFrontendFreedomModule'
  'browserify:simpleTurnChromeApp'
  'copy:libsForSimpleTurnChromeApp'
  'copy:libsForSimpleTurnFirefoxApp'
]

taskManager.add 'simpleChurnChatChromeApp', [
  'base'
  'browserify:simpleChurnChatFreedomModule'
  'browserify:simpleChurnChatChromeApp'
  'copy:libsForSimpleChurnChatChromeApp'
]

taskManager.add 'copyPasteChurnChatChromeApp', [
  'base'
  'browserify:copyPasteChurnChatFreedomModule'
  'browserify:copyPasteChurnChatChromeApp'
  'copy:libsForCopyPasteChurnChatChromeApp'
]

# Create unit test code
taskManager.add 'browserifySpecs', [
  'base'
  'browserify:arraybuffersSpec'
  'browserify:bridgeSpec'
  'browserify:handlerSpec'
  'browserify:buildToolsTaskmanagerSpec'
  'browserify:loggingSpec'
  'browserify:loggingProviderSpec'
  'browserify:peerconnectionSpec'
  'browserify:datachannelSpec'
  'browserify:queueSpec'
  'browserify:turnFrontEndMessagesSpec'
  'browserify:turnFrontEndSpec'
]

# Create unit test code
taskManager.add 'browserifyCovSpecs', [
  'base'
  'browserify:arraybuffersCovSpec'
  'browserify:bridgeCovSpec'
  'browserify:handlerCovSpec'
  'browserify:buildToolsTaskmanagerCovSpec'
  'browserify:loggingCovSpec'
  'browserify:loggingProviderCovSpec'
  'browserify:peerconnectionCovSpec'
  'browserify:datachannelCovSpec'
  'browserify:queueCovSpec'
  'browserify:turnFrontEndMessagesCovSpec'
  'browserify:turnFrontEndCovSpec'
]

# Run unit tests
taskManager.add 'unit_test', [
  'browserifySpecs',
  'jasmine:arraybuffers'
  'jasmine:bridge'
  'jasmine:handler'
  'jasmine:buildTools'
  'jasmine:logging'
  'jasmine:loggingProvider'
  'jasmine:webrtc'
  'jasmine:queue'
]

taskManager.add 'tcpIntegrationTestModule', [
  'base'
  'copy:libsForIntegrationTcp'
  'browserify:integrationTcpFreedomModule'
  'browserify:integrationTcpSpec'
]

taskManager.add 'tcpIntegrationTest', [
  'tcpIntegrationTestModule'
  'jasmine_chromeapp:tcp'
]

taskManager.add 'socksEchoIntegrationTestModule', [
  'base'
  'copy:libsForIntegrationSocksEcho'
  'browserify:integrationSocksEchoFreedomModule'
  'browserify:integrationSocksEchoChurnSpec'
  'browserify:integrationSocksEchoNochurnSpec'
  'browserify:integrationSocksEchoSlowSpec'
]

taskManager.add 'socksEchoIntegrationTest', [
  'socksEchoIntegrationTestModule'
  'jasmine_chromeapp:socksEcho'
]

taskManager.add 'integration_test', [
  'tcpIntegrationTest'
  'socksEchoIntegrationTest'
]

# Run unit tests to produce coverage; these are separate from unit_tests because
# they make tests hard to debug and fix.
taskManager.add 'coverage', [
  'browserifyCovSpecs'
  'jasmine:arraybuffersCov'
  'jasmine:bridgeCov'
  'jasmine:handlerCov'
  'jasmine:buildToolsCov'
  'jasmine:loggingCov'
  'jasmine:loggingProviderCov'
  'jasmine:webrtcCov'
  'jasmine:queueCov'
]

taskManager.add 'test', ['unit_test', 'integration_test']

# Default task, build dev, run tests, make the distribution build.
taskManager.add 'default', ['base']

#-------------------------------------------------------------------------
rules = require './build/tools/common-grunt-rules'
path = require 'path'

browserifyIntegrationTest = (path) ->
  Rule.browserifySpec(path, {
    browserifyOptions: { standalone: 'browserified_exports' }
  });

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

      libsForEchoServerChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['echo', 'loggingprovider']
          localDestPath: 'samples/echo-server-chromeapp/'
      libsForEchoServerFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['echo', 'loggingprovider']
          localDestPath: 'samples/echo-server-firefoxapp/data/'

      libsForSimpleSocksChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['simple-socks', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators'
          ]
          localDestPath: 'samples/simple-socks-chromeapp/'
      libsForSimpleSocksFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['simple-socks', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators'
          ]
          localDestPath: 'samples/simple-socks-firefoxapp/data/'

      libsForCopyPasteSocksChromeApp:
        Rule.copyLibs
          npmLibNames: [
            'freedom-for-chrome'
          ]
          pathsFromDevBuild: ['copypaste-socks', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators'
            'i18n'
            'bower/polymer'
            'freedom-pgp-e2e'
          ]
          localDestPath: 'samples/copypaste-socks-chromeapp/'
      libsForCopyPasteSocksFirefoxApp:
        Rule.copyLibs
          npmLibNames: [
            'freedom-for-firefox'
          ]
          pathsFromDevBuild: ['copypaste-socks', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators'
            'i18n'
            'bower'
            'freedom-pgp-e2e'
          ]
          localDestPath: 'samples/copypaste-socks-firefoxapp/data'

      libsForSimpleTurnChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['simple-turn', 'turn-frontend', 'turn-backend', 'loggingprovider']
          localDestPath: 'samples/simple-turn-chromeapp/'
      libsForSimpleTurnFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['simple-turn', 'turn-frontend', 'turn-backend', 'loggingprovider']
          localDestPath: 'samples/simple-turn-firefoxapp/data'

      libsForSimpleChurnChatChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['churn-pipe', 'loggingprovider']
          localDestPath: 'samples/simple-churn-chat-chromeapp/'
      libsForCopyPasteChurnChatChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators'
          ]
          localDestPath: 'samples/copypaste-churn-chat-chromeapp/'

      # Integration Tests.
      libsForIntegrationTcp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['loggingprovider']
          localDestPath: 'integration-tests/tcp'
      libsForIntegrationSocksEcho:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['churn-pipe', 'loggingprovider', 'port-control']
          localDestPath: 'integration-tests/socks-echo'

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
      bridge: Rule.jasmineSpec 'bridge'
      bridgeCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'bridge')
      buildTools: Rule.jasmineSpec 'build-tools'
      buildToolsCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'build-tools')
      churn: Rule.jasmineSpec 'churn'
      churnCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'churn')
      handler: Rule.jasmineSpec 'handler'
      handlerCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'handler')
      logging: Rule.jasmineSpec 'logging'
      loggingCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'logging')
      loggingProvider: Rule.jasmineSpec 'loggingprovider'
      loggingProviderCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'loggingprovider')
      net: Rule.jasmineSpec 'net'
      netCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'net')
      pool: Rule.jasmineSpec 'pool'
      poolCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'pool')
      rtcToNet: Rule.jasmineSpec 'rtc-to-net'
      rtcToNetCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'rtc-to-net')
      simpleTransformers: Rule.jasmineSpec 'simple-transformers'
      simpleTransformersCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'simple-transformers')
      turnFrontEndMessagesSpec: Rule.browserifySpec 'turn-frontend/messages'
      turnFrontEndSpec: Rule.browserifySpec 'turn-frontend/turn-frontend'

      socksCommon: Rule.jasmineSpec('socks-common',
          [path.join(thirdPartyBuildPath, 'ipaddr/ipaddr.js')]);
      socksCommonCov: Rule.addCoverageToSpec(Rule.jasmineSpec('socks-common',
          [path.join(thirdPartyBuildPath, 'ipaddr/ipaddr.js')]));

      socksToRtc: Rule.jasmineSpec 'socks-to-rtc'
      socksToRtcCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'socks-to-rtc')
      webrtc: Rule.jasmineSpec 'webrtc'
      webrtcCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'webrtc')
      queue: Rule.jasmineSpec 'queue'
      queueCov: Rule.addCoverageToSpec(Rule.jasmineSpec 'queue')

    browserify:
      # Browserify freedom-modules in the library
      loggingProvider: Rule.browserify 'loggingprovider/freedom-module'
      echoFreedomModule: Rule.browserify 'echo/freedom-module'
      churnPipeFreedomModule: Rule.browserify(
          'churn-pipe/freedom-module',
          {
            # Emscripten, used to compile FTE and Rabbit to JS has unused
            # require statements for `ws` and for `path` that need to be
            # ignored.
            ignore: ['ws', 'path']
            browserifyOptions: { standalone: 'browserified_exports' }
          })
      portControlFreedomModule: Rule.browserify 'port-control/freedom-module'
      simpleSocksFreedomModule: Rule.browserify 'simple-socks/freedom-module'
      copyPasteSocksFreedomModule: Rule.browserify 'copypaste-socks/freedom-module'
      simpleTurnFreedomModule: Rule.browserify 'simple-turn/freedom-module'
      turnBackendFreedomModule: Rule.browserify 'turn-backend/freedom-module'
      turnFrontendFreedomModule: Rule.browserify 'turn-frontend/freedom-module'
      simpleChurnChatFreedomModule: Rule.browserify 'samples/simple-churn-chat-chromeapp/freedom-module'
      copyPasteChurnChatFreedomModule: Rule.browserify 'samples/copypaste-churn-chat-chromeapp/freedom-module'
      # Browserify specs
      arraybuffersSpec: Rule.browserifySpec 'arraybuffers/arraybuffers'
      arraybuffersCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'arraybuffers/arraybuffers')
      bridgeSpec: Rule.browserifySpec 'bridge/bridge'
      bridgeCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'bridge/bridge')
      buildToolsTaskmanagerSpec: Rule.browserifySpec 'build-tools/taskmanager'
      buildToolsTaskmanagerCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'build-tools/taskmanager')
      churnSpec: Rule.browserifySpec 'churn/churn'
      churnCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'churn/churn')
      handlerSpec: Rule.browserifySpec 'handler/queue'
      handlerCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'handler/queue')
      loggingProviderSpec: Rule.browserifySpec 'loggingprovider/loggingprovider'
      loggingProviderCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'loggingprovider/loggingprovider')
      loggingSpec: Rule.browserifySpec 'logging/logging'
      loggingCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'logging/logging')
      peerconnectionSpec: Rule.browserifySpec 'webrtc/peerconnection'
      peerconnectionCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'webrtc/peerconnection')
      poolSpec: Rule.browserifySpec 'pool/pool'
      poolCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'pool/pool')
      rtcToNetSpec: Rule.browserifySpec 'rtc-to-net/rtc-to-net'
      rtcToNetCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'rtc-to-net/rtc-to-net')
      simpleTransformersCaesarSpec: Rule.browserifySpec 'simple-transformers/caesar'
      simpleTransformersCaesarCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'simple-transformers/caesar')
      socksCommonHeadersSpec: Rule.browserifySpec 'socks-common/socks-headers'
      socksCommonHeadersCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'socks-common/socks-headers')
      socksToRtcSpec: Rule.browserifySpec 'socks-to-rtc/socks-to-rtc'
      socksToRtcCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'socks-to-rtc/socks-to-rtc')
      tcpSpec: Rule.browserifySpec 'net/tcp'
      tcpCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'net/tcp')
      turnFrontEndMessagesSpec: Rule.browserifySpec 'turn-frontend/messages'
      turnFrontEndMessagesCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'turn-frontend/messages')
      turnFrontEndSpec: Rule.browserifySpec 'turn-frontend/turn-frontend'
      turnFrontEndCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'turn-frontend/turn-frontend')
      datachannelSpec: Rule.browserifySpec 'webrtc/datachannel'
      datachannelCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'webrtc/datachannel')
      queueSpec: Rule.browserifySpec 'queue/queue'
      queueCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'queue/queue')
      # Browserify sample apps main freedom module and core environments
      copypasteFreedomChatFreedomModule: Rule.browserify 'samples/copypaste-freedom-chat/freedom-module'
      copypasteFreedomChatMain: Rule.browserify 'samples/copypaste-freedom-chat/main.core-env'
      simpleFreedomChatFreedomModule: Rule.browserify 'samples/simple-freedom-chat/freedom-module'
      simpleFreedomChatMain: Rule.browserify 'samples/simple-freedom-chat/main.core-env'
      echoServerChromeApp: Rule.browserify 'samples/echo-server-chromeapp/background.core-env'
      simpleSocksChromeApp: Rule.browserify 'samples/simple-socks-chromeapp/background.core-env'
      copyPasteSocksMain: Rule.browserify 'copypaste-socks/main.core-env'
      simpleTurnChromeApp: Rule.browserify 'samples/simple-turn-chromeapp/background.core-env'
      simpleChurnChatChromeApp: Rule.browserify 'samples/simple-churn-chat-chromeapp/main.core-env'
      copyPasteChurnChatChromeApp: Rule.browserify 'samples/copypaste-churn-chat-chromeapp/main.core-env'
      # Integration tests.
      integrationTcpFreedomModule:
        Rule.browserify 'integration-tests/tcp/freedom-module'
      integrationTcpSpec:
        browserifyIntegrationTest 'integration-tests/tcp/tcp.core-env'
      integrationSocksEchoFreedomModule:
        Rule.browserify 'integration-tests/socks-echo/freedom-module'
      integrationSocksEchoChurnSpec:
        browserifyIntegrationTest 'integration-tests/socks-echo/churn.core-env'
      integrationSocksEchoNochurnSpec:
        browserifyIntegrationTest 'integration-tests/socks-echo/nochurn.core-env'
      integrationSocksEchoSlowSpec:
        browserifyIntegrationTest 'integration-tests/socks-echo/slow.core-env'

    vulcanize:
      copyPasteSocks:
        options:
          inline: true
          csp: true
        files: [
          {
            src: path.join(devBuildPath, 'copypaste-socks/polymer-components/root.html')
            dest: path.join(devBuildPath, 'copypaste-socks/polymer-components/vulcanized.html')
          }
        ]

    jasmine_chromeapp:
      tcp:
        files: [
          {
            cwd: devBuildPath + '/integration-tests/tcp/',
            src: ['**/*', '!jasmine_chromeapp/**/*']
            dest: './',
            expand: true
          }
        ]
        scripts: [
          'freedom-for-chrome/freedom-for-chrome.js'
          'tcp.core-env.spec.static.js'
        ]
        options:
          outDir: devBuildPath + '/integration-tests/tcp/jasmine_chromeapp/'
          keepRunner: false
      socksEcho:
        files: [
          {
            cwd: devBuildPath + '/integration-tests/socks-echo/',
            src: ['**/*', '!jasmine_chromeapp*/**']
            dest: './',
            expand: true
          }
        ]
        scripts: [
          'freedom-for-chrome/freedom-for-chrome.js'
          'churn.core-env.spec.static.js'
          'nochurn.core-env.spec.static.js'
        ]
        options:
          outDir: devBuildPath + '/integration-tests/socks-echo/jasmine_chromeapp/'
          keepRunner: false
      socksEchoSlow:
        files: [
          {
            cwd: devBuildPath + '/integration-tests/socks-echo/',
            src: ['**/*', '!jasmine_chromeapp*/**']
            dest: './',
            expand: true
          }
        ]
        scripts: [
          'freedom-for-chrome/freedom-for-chrome.js'
          'slow.core-env.spec.static.js'
        ]
        options:
          outDir: devBuildPath + '/integration-tests/socks-echo/jasmine_chromeapp_slow/'
          keepRunner: true

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
  grunt.loadNpmTasks 'grunt-jasmine-chromeapp'
  grunt.loadNpmTasks 'grunt-ts'
  grunt.loadNpmTasks 'grunt-vulcanize'

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
