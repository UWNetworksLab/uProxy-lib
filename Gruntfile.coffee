fs = require('fs')
path = require 'path'
rules = require './build/tools/common-grunt-rules'
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

    libsForSimpleChurnChatChromeApp:
      Rule.copyLibs
        npmLibNames: ['freedom-for-chrome']
        pathsFromDevBuild: ['churn-pipe', 'loggingprovider']
        pathsFromThirdPartyBuild: [
          'freedom-port-control'
        ]
        localDestPath: 'samples/simple-churn-chat-chromeapp/'
    libsForCopyPasteChurnChatChromeApp:
      Rule.copyLibs
        npmLibNames: ['freedom-for-chrome']
        pathsFromDevBuild: ['churn-pipe', 'loggingprovider']
        pathsFromThirdPartyBuild: [
          'uproxy-obfuscators',
          'freedom-port-control'
        ]
        localDestPath: 'samples/copypaste-churn-chat-chromeapp/'

    libsForAdventureChromeApp:
      Rule.copyLibs
        npmLibNames: ['freedom-for-chrome']
        pathsFromDevBuild: ['adventure', 'churn-pipe', 'loggingprovider']
        pathsFromThirdPartyBuild: [
          'uproxy-obfuscators',
          'freedom-port-control'
        ]
        localDestPath: 'samples/adventure-chromeapp/'
    libsForAdventureFirefoxApp:
      Rule.copyLibs
        npmLibNames: ['freedom-for-firefox']
        pathsFromDevBuild: ['adventure', 'churn-pipe', 'loggingprovider']
        pathsFromThirdPartyBuild: [
          'uproxy-obfuscators',
          'freedom-port-control'
        ]
        localDestPath: 'samples/adventure-firefoxapp/data/'

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
    simpleSocksFreedomModule: Rule.browserify 'simple-socks/freedom-module'
    copypasteSocksFreedomModule: Rule.browserify 'copypaste-socks/freedom-module'
    simpleTurnFreedomModule: Rule.browserify 'simple-turn/freedom-module'
    simpleChurnChatFreedomModule: Rule.browserify 'samples/simple-churn-chat-chromeapp/freedom-module'
    copypasteChurnChatFreedomModule: Rule.browserify 'samples/copypaste-churn-chat-chromeapp/freedom-module'
    adventureFreedomModule: Rule.browserify 'adventure/freedom-module'
    uprobeFreedomModule: Rule.browserify 'uprobe/freedom-module'
    # Browserify sample apps main freedom module and core environments
    copypasteFreedomChatFreedomModule: Rule.browserify 'samples/copypaste-freedom-chat/freedom-module'
    copypasteFreedomChatMain: Rule.browserify 'samples/copypaste-freedom-chat/main.core-env'
    simpleFreedomChatFreedomModule: Rule.browserify 'samples/simple-freedom-chat/freedom-module'
    simpleFreedomChatMain: Rule.browserify 'samples/simple-freedom-chat/main.core-env'
    copypasteSocksMain: Rule.browserify 'copypaste-socks/main.core-env'
    simpleChurnChatChromeApp: Rule.browserify 'samples/simple-churn-chat-chromeapp/main.core-env'
    copypasteChurnChatChromeApp: Rule.browserify 'samples/copypaste-churn-chat-chromeapp/main.core-env'
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

# Makes the base development build, excludes sample apps.
taskManager.add 'base', [
  'copy:src'
  'ts:srcInModuleEnv'
  'ts:srcInCoreEnv'
  'browserify:loggingProvider'
  'browserify:echoFreedomModule'
  'browserify:simpleSocksFreedomModule'
  'browserify:churnPipeFreedomModule'
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
  'copypasteSocks'
  'simpleTurn'
  'simpleChurnChatChromeApp'
  'copypasteChurnChatChromeApp'
  'adventure'
  'uprobe'
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
]

taskManager.add 'echoServerFirefoxApp', [
  'base'
  'copy:libsForEchoServerFirefoxApp'
]

taskManager.add 'simpleSocksChromeApp', [
  'base'
  'copy:libsForSimpleSocksChromeApp'
]

taskManager.add 'simpleSocksFirefoxApp', [
  'base'
  'copy:libsForSimpleSocksFirefoxApp'
]

taskManager.add 'copypasteSocks', [
  'base'
  'browserify:copypasteSocksFreedomModule'
  'browserify:copypasteSocksMain'
  'vulcanize:copypasteSocks'
  'copy:libsForCopyPasteSocksChromeApp'
  'copy:libsForCopyPasteSocksFirefoxApp'
]

taskManager.add 'simpleTurn', [
  'base'
  'browserify:simpleTurnFreedomModule'
  'copy:libsForSimpleTurnChromeApp'
  'copy:libsForSimpleTurnFirefoxApp'
]

taskManager.add 'simpleChurnChatChromeApp', [
  'base'
  'browserify:simpleChurnChatFreedomModule'
  'browserify:simpleChurnChatChromeApp'
  'copy:libsForSimpleChurnChatChromeApp'
]

taskManager.add 'copypasteChurnChatChromeApp', [
  'base'
  'browserify:copypasteChurnChatFreedomModule'
  'browserify:copypasteChurnChatChromeApp'
  'copy:libsForCopyPasteChurnChatChromeApp'
]

taskManager.add 'adventureBase', [
  'base'
  'browserify:adventureFreedomModule'
]

taskManager.add 'adventureChromeApp', [
  'adventureBase'
  'copy:libsForAdventureChromeApp'
]

taskManager.add 'adventureFirefoxApp', [
  'adventureBase'
  'copy:libsForAdventureFirefoxApp'
]

taskManager.add 'adventure', [
  'adventureChromeApp'
  'adventureFirefoxApp'
]

taskManager.add 'uprobeBase', [
  'base'
  'browserify:uprobeFreedomModule'
]

taskManager.add 'uprobeChromeApp', [
  'uprobeBase'
  'copy:libsForUprobeChromeApp'
]

taskManager.add 'uprobeFirefoxApp', [
  'uprobeBase'
  'copy:libsForUprobeFirefoxApp'
]

taskManager.add 'uprobe', [
  'uprobeChromeApp'
  'uprobeFirefoxApp'
]

# Run unit tests
taskManager.add 'unit_test', [
  'base'
].concat Rule.getTests('src', gruntConfig, undefined, ['integration-tests'])

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
  'base'
].concat Rule.getTests('src', gruntConfig, undefined, ['integration-tests'], true)

taskManager.add 'test', ['unit_test', 'integration_test']

# Default task, build dev, run tests, make the distribution build.
taskManager.add 'default', ['base']

#-------------------------------------------------------------------------
module.exports = (grunt) ->
  #-------------------------------------------------------------------------
  grunt.initConfig gruntConfig

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
  )
