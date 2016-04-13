fs = require('fs')
_ = require('lodash')
path = require('path')
rules = require('./build/tools/common-grunt-rules')
TaskManager = require './build/tools/taskmanager'

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
})

readJSONFile = (file) -> JSON.parse(fs.readFileSync(file, 'utf8'))

browserifyIntegrationTest = (path) ->
  Rule.browserifySpec(path, {
    browserifyOptions: { standalone: 'browserified_exports' }
  })

gruntConfig =
config =
  pkg: readJSONFile('package.json')

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
    libsForDeployerChromeApp:
      Rule.copyLibs
        npmLibNames: ['freedom-for-chrome', 'forge-min']
        pathsFromDevBuild: ['loggingprovider', 'cloud/deployer', 'cloud/digitalocean', 'cloud/install']
        localDestPath: 'samples/deployer-chromeapp/'
    libsForDeployerFirefoxApp:
      Rule.copyLibs
        npmLibNames: ['freedom-for-firefox', 'forge-min']
        pathsFromDevBuild: ['loggingprovider', 'cloud/deployer', 'cloud/digitalocean', 'cloud/install']
        localDestPath: 'samples/deployer-firefoxapp/data'

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

  tslint:
    options:
      configuration: 'src/tslint.json'
    files:
      src: [
        'src/**/*.ts'
      ]

  jasmine: {}

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
    # TODO: Make the browserified SSH stuff re-useable, e.g. freedomjs module.
    cloudInstallerFreedomModule: Rule.browserify('cloud/install/freedom-module', {
      alias : [
        # Shims for node's dns and net modules from freedom-social-xmpp,
        # with a couple of fixes.
        './src/cloud/social/shim/net.js:net'
        './src/cloud/social/shim/dns.js:dns'
        # Alternative that works for freedomjs modules.
        './src/cloud/social/alias/brorand.js:brorand'
        # Fallback for crypto-browserify's randombytes, for Firefox.
        './src/cloud/social/alias/randombytes.js:randombytes'
      ]
    })
    cloudSocialProviderFreedomModule: Rule.browserify('cloud/social/freedom-module', {
      alias : [
        # Shims for node's dns and net modules from freedom-social-xmpp,
        # with a couple of fixes.
        './src/cloud/social/shim/net.js:net'
        './src/cloud/social/shim/dns.js:dns'
        # Alternative that works for freedomjs modules.
        './src/cloud/social/alias/brorand.js:brorand'
        # Fallback for crypto-browserify's randombytes, for Firefox.
        './src/cloud/social/alias/randombytes.js:randombytes'
      ]
    })
    digitalOceanFreedomModule: Rule.browserify 'cloud/digitalocean/freedom-module'
    # Sample app freedom modules.
    copypasteChatFreedomModule: Rule.browserify 'copypaste-chat/freedom-module'
    copypasteSocksFreedomModule: Rule.browserify 'copypaste-socks/freedom-module'
    deployerFreedomModule: Rule.browserify 'cloud/deployer/freedom-module'
    echoServerFreedomModule: Rule.browserify 'echo/freedom-module'
    simpleChatFreedomModule: Rule.browserify 'simple-chat/freedom-module'
    simpleSocksFreedomModule: Rule.browserify 'simple-socks/freedom-module'
    simpleTurnFreedomModule: Rule.browserify 'simple-turn/freedom-module'
    uprobeFreedomModule: Rule.browserify 'uprobe/freedom-module'
    zorkFreedomModule: Rule.browserify 'zork/freedom-module'
    # Sample app main environments (samples with UI).
    copypasteChatMain: Rule.browserify 'copypaste-chat/main.core-env'
    copypasteSocksMain: Rule.browserify 'copypaste-socks/main.core-env'
    simpleChatMain: Rule.browserify 'simple-chat/main.core-env'
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

# The top level tasks. These are the highest level grunt-tasks defined in terms
# of specific grunt rules below and given to grunt.initConfig
taskManager = new TaskManager.Manager()

# Builds everything except sample apps.
taskManager.add 'base', [
  'copy:src'
  'ts:srcInModuleEnv'
  'ts:srcInCoreEnv'
  'browserify:loggingProvider'
  'browserify:churnPipeFreedomModule'
  'browserify:cloudInstallerFreedomModule'
  'browserify:cloudSocialProviderFreedomModule'
  'browserify:digitalOceanFreedomModule'
]

taskManager.add 'samples', [
  'echoServer'
  'copypasteChat'
  'copypasteSocks'
  'deployer'
  'simpleChat'
  'simpleSocks'
  'simpleTurn'
  'uprobe'
  'zork'
]

# Makes the distribution build.
taskManager.add 'dist', [
  'base'
  'samples'
  'lint'
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

taskManager.add 'deployer', [
  'base'
  'browserify:deployerFreedomModule'
  'copy:libsForDeployerChromeApp'
  'copy:libsForDeployerFirefoxApp'
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

specList = Rule.getTests('src', undefined, ['integration-tests'])

# Run unit tests
taskManager.add 'unit_test', [
  'base',
].concat _.flatten(Rule.buildAndRunTest(spec, gruntConfig) for spec in specList)

taskManager.add 'coverage', [
  'base',
].concat _.flatten(Rule.buildAndRunTest(spec, gruntConfig, true) for spec in specList)

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

taskManager.add 'lint', ['tslint']

taskManager.add 'test', ['unit_test', 'integration_test']

# Default task, build dev, run tests, make the distribution build.
taskManager.add 'default', ['base']

#-------------------------------------------------------------------------

module.exports = (grunt) ->
  grunt.initConfig(gruntConfig)

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
  grunt.loadNpmTasks 'grunt-tslint'
  grunt.loadNpmTasks 'grunt-vulcanize'

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  )
