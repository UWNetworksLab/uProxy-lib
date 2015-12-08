TaskManager = require './build/tools/taskmanager'

#-------------------------------------------------------------------------
# The top level tasks. These are the highest level grunt-tasks defined in terms
# of specific grunt rules below and given to grunt.initConfig
taskManager = new TaskManager.Manager();

# Builds everything except sample apps.
taskManager.add 'base', [
  'copy:src'
  'ts:srcInModuleEnv'
  'ts:srcInCoreEnv'
  'browserify:loggingProvider'
  'browserify:churnPipeFreedomModule'
  'browserify:cloudSocialProviderFreedomModule'
]

taskManager.add 'samples', [
  'echoServer'
  'copypasteChat'
  'copypasteSocks'
  'simpleChat'
  'simpleSocks'
  'simpleTurn'
  'uprobe'
  'zork'
  'provision'
]

# Makes the distribution build.
taskManager.add 'dist', [
  'base'
  'samples'
  'test'
  'coverage'
  'copy:dist'
]

###
# Samples.
###
taskManager.add 'echoServer', [
  'base'
  'browserify:echoServerFreedomModule'
  'copy:libsForEchoServerChromeApp'
  'copy:libsForEchoServerFirefoxApp'
]

taskManager.add 'copypasteChat', [
  'base'
  'browserify:copypasteChatFreedomModule'
  'browserify:copypasteChatMain'
  'copy:libsForCopypasteChatChromeApp'
  'copy:libsForCopypasteChatFirefoxApp'
  'copy:libsForCopypasteChatWebApp'
]

taskManager.add 'copypasteSocks', [
  'base'
  'browserify:copypasteSocksFreedomModule'
  'browserify:copypasteSocksMain'
  'vulcanize:copypasteSocks'
  'copy:libsForCopyPasteSocksChromeApp'
  'copy:libsForCopyPasteSocksFirefoxApp'
]

taskManager.add 'simpleChat', [
  'base'
  'browserify:simpleChatFreedomModule'
  'browserify:simpleChatMain'
  'copy:libsForSimpleChatChromeApp'
  'copy:libsForSimpleChatFirefoxApp'
  'copy:libsForSimpleChatWebApp'
]

taskManager.add 'simpleSocks', [
  'base'
  'browserify:simpleSocksFreedomModule'
  'copy:libsForSimpleSocksChromeApp'
  'copy:libsForSimpleSocksFirefoxApp'
]

taskManager.add 'simpleTurn', [
  'base'
  'browserify:simpleTurnFreedomModule'
  'copy:libsForSimpleTurnChromeApp'
  'copy:libsForSimpleTurnFirefoxApp'
]

taskManager.add 'uprobe', [
  'base'
  'browserify:uprobeFreedomModule'
  'copy:libsForUprobeChromeApp'
  'copy:libsForUprobeFirefoxApp'
]

taskManager.add 'zork', [
  'base'
  'browserify:zorkFreedomModule'
  'copy:libsForZorkChromeApp'
  'copy:libsForZorkFirefoxApp'
  'copy:libsForZorkNode'
]

taskManager.add 'provision', [
  'base'
  'browserify:provisionFreedomModule'
  'copy:libsForProvisionChromeApp'
]

# Create unit test code
taskManager.add 'browserifySpecs', [
  'base'
  'browserify:aesSpec'
  'browserify:arraybuffersSpec'
  'browserify:bridgeSpec'
  'browserify:onetimeSpec'
  'browserify:candidateSpec'
  'browserify:churnSpec'
  'browserify:handlerSpec'
  'browserify:buildToolsTaskmanagerSpec'
  'browserify:loggingSpec'
  'browserify:loggingProviderSpec'
  'browserify:peerconnectionSpec'
  'browserify:datachannelSpec'
  'browserify:poolSpec'
  'browserify:tcpSpec'
  'browserify:linefeederSpec'
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
  'jasmine:churn'
  'jasmine:handler'
  'jasmine:buildTools'
  'jasmine:crypto'
  'jasmine:logging'
  'jasmine:loggingProvider'
  'jasmine:net'
  'jasmine:pool'
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
  'jasmine_firefoxaddon'  # Currently only TCP test
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
  'jasmine:netCov'
  'jasmine:poolCov'
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

      ###
      # Samples.
      ###
      libsForProvisionChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome', 'forge-min']
          pathsFromDevBuild: ['loggingprovider', 'cloud/provision']
          pathsFromThirdPartyBuild: [
          ]
          localDestPath: 'samples/provision-chromeapp/'
      libsForZorkChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['churn-pipe', 'loggingprovider', 'zork']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators',
            'freedom-port-control'
          ]
          localDestPath: 'samples/zork-chromeapp/'
      libsForZorkFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['churn-pipe', 'loggingprovider', 'zork']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators',
            'freedom-port-control'
          ]
          localDestPath: 'samples/zork-firefoxapp/data/'
      libsForZorkNode:
        Rule.copyLibs
          npmLibNames: ['freedom-for-node']
          pathsFromDevBuild: ['churn-pipe', 'loggingprovider', 'zork']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators',
            'freedom-port-control'
          ]
          localDestPath: 'samples/zork-node/'

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

      libsForCopypasteChatChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['copypaste-chat', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'freedom-port-control'
          ]
          localDestPath: 'samples/copypaste-chat-chromeapp/'
      libsForCopypasteChatFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['copypaste-chat', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'freedom-port-control'
          ]
          localDestPath: 'samples/copypaste-chat-firefoxapp/data'
      libsForCopypasteChatWebApp:
        Rule.copyLibs
          npmLibNames: ['freedom']
          pathsFromDevBuild: ['copypaste-chat', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'freedom-port-control'
          ]
          localDestPath: 'samples/copypaste-chat-webapp/'

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
            'freedom-port-control'
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
            'freedom-port-control'
          ]
          localDestPath: 'samples/copypaste-socks-firefoxapp/data'

      libsForSimpleSocksChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['simple-socks', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators'
            'freedom-port-control'
          ]
          localDestPath: 'samples/simple-socks-chromeapp/'
      libsForSimpleSocksFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['simple-socks', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'uproxy-obfuscators'
            'freedom-port-control'
          ]
          localDestPath: 'samples/simple-socks-firefoxapp/data/'

      libsForSimpleChatChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['simple-chat', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'freedom-port-control'
          ]
          localDestPath: 'samples/simple-chat-chromeapp/'
      libsForSimpleChatFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['simple-chat', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'freedom-port-control'
          ]
          localDestPath: 'samples/simple-chat-firefoxapp/data'
      # While neither churn-pipe nor freedom-port-control can be used in a
      # regular web page environment, they are included so that obfuscation
      # may be easily enabled in the Chrome and Firefox samples.
      libsForSimpleChatWebApp:
        Rule.copyLibs
          npmLibNames: ['freedom']
          pathsFromDevBuild: ['simple-chat', 'churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: [
            'freedom-port-control'
          ]
          localDestPath: 'samples/simple-chat-webapp/'

      libsForSimpleTurnChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['simple-turn', 'loggingprovider']
          localDestPath: 'samples/simple-turn-chromeapp/'
      libsForSimpleTurnFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['simple-turn', 'loggingprovider']
          localDestPath: 'samples/simple-turn-firefoxapp/data'

      libsForUprobeChromeApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['uprobe', 'loggingprovider']
          localDestPath: 'samples/uprobe-chromeapp/'
      libsForUprobeFirefoxApp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-firefox']
          pathsFromDevBuild: ['uprobe', 'loggingprovider']
          localDestPath: 'samples/uprobe-firefoxapp/data/'

      # Integration Tests.
      libsForIntegrationTcp:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['loggingprovider']
          localDestPath: 'integration-tests/tcp'
      libsForIntegrationSocksEcho:
        Rule.copyLibs
          npmLibNames: ['freedom-for-chrome']
          pathsFromDevBuild: ['churn-pipe', 'loggingprovider']
          pathsFromThirdPartyBuild: ['freedom-port-control']
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
      crypto: Rule.jasmineSpec 'crypto'
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
      # Sample app freedom modules.
      copypasteChatFreedomModule: Rule.browserify 'copypaste-chat/freedom-module'
      copypasteSocksFreedomModule: Rule.browserify 'copypaste-socks/freedom-module'
      echoServerFreedomModule: Rule.browserify 'echo/freedom-module'
      cloudSocialProviderFreedomModule: Rule.browserify('cloud/social/freedom-module', {
        alias : [
          # Shims for node's dns and net modules from freedom-social-xmpp,
          # with a couple of fixes.
          './src/cloud/social/shim/net.js:net'
          './src/cloud/social/shim/dns.js:dns'
          # Subset of ssh2-streams (all except SFTP) which works well in
          # the browser.
          './src/cloud/social/alias/ssh2-streams.js:ssh2-streams'
          # Fallback for crypto-browserify's randombytes, for Firefox.
          './src/cloud/social/alias/randombytes.js:randombytes'
        ]
      })
      simpleChatFreedomModule: Rule.browserify 'simple-chat/freedom-module'
      simpleSocksFreedomModule: Rule.browserify 'simple-socks/freedom-module'
      simpleTurnFreedomModule: Rule.browserify 'simple-turn/freedom-module'
      uprobeFreedomModule: Rule.browserify 'uprobe/freedom-module'
      zorkFreedomModule: Rule.browserify 'zork/freedom-module'
      provisionFreedomModule: Rule.browserify 'cloud/provision/freedom-module'
      # Sample app main environments (samples with UI).
      copypasteChatMain: Rule.browserify 'copypaste-chat/main.core-env'
      copypasteSocksMain: Rule.browserify 'copypaste-socks/main.core-env'
      simpleChatMain: Rule.browserify 'simple-chat/main.core-env'
      # Browserify specs
      aesSpec: Rule.browserifySpec 'crypto/aes'
      arraybuffersSpec: Rule.browserifySpec 'arraybuffers/arraybuffers'
      arraybuffersCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'arraybuffers/arraybuffers')
      bridgeSpec: Rule.browserifySpec 'bridge/bridge'
      bridgeCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'bridge/bridge')
      onetimeSpec: Rule.browserifySpec 'bridge/onetime'
      onetimeCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'bridge/onetime')
      buildToolsTaskmanagerSpec: Rule.browserifySpec 'build-tools/taskmanager'
      buildToolsTaskmanagerCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'build-tools/taskmanager')
      candidateSpec: Rule.browserifySpec 'churn/candidate'
      candidateCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'churn/candidate')
      churnSpec: Rule.browserifySpec 'churn/churn'
      churnCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'churn/churn')
      handlerSpec: Rule.browserifySpec 'handler/queue'
      handlerCovSpec: Rule.addCoverageToBrowserify(Rule.browserifySpec 'handler/queue')
      linefeederSpec: Rule.browserifySpec 'net/linefeeder'
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
      copypasteSocks:
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

    jasmine_firefoxaddon:
      tests: [
        devBuildPath + '/integration-tests/tcp/tcp.core-env.spec.static.js'
      ]
      resources: [
        devBuildPath + '/integration-tests/tcp/**/*.js*'
      ]
      helpers: [
        'node_modules/freedom-for-firefox/freedom-for-firefox.jsm'
      ]

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
  grunt.loadNpmTasks 'grunt-jasmine-firefoxaddon'
  grunt.loadNpmTasks 'grunt-ts'
  grunt.loadNpmTasks 'grunt-vulcanize'

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
