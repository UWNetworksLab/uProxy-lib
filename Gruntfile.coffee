TaskManager = require './tools/taskmanager'

path = require 'path'

console.log("output for es6-require:" + require.resolve('es6-promise'));

# Function to make jasmine spec assuming expected dir layout.
jasmineSpec = (name, deps = []) ->
  {
    src: [
      # Help Jasmine's PhantomJS understand promises.
      require.resolve('arraybuffer-slice/index.js')
      require.resolve('es6-promise')
    ].concat(deps).concat([
      'build/dev/' + name + '/**/*.js'
      '!build/dev/' + name + '/**/*.spec.js'
    ])
    options:
      specs: 'build/dev/' + name + '/**/*.spec.js'
      outfile: 'build/dev/' + name + '/SpecRunner.html'
      keepRunner: true
  }

browserifyTypeScript = (typeScriptEntryFileWithoutPostfix) ->
  src: [typeScriptEntryFileWithoutPostfix + '.ts']
  dest: typeScriptEntryFileWithoutPostfix + '.js'
  options:
    transform: ['tsify']
    debug: true
    bundleOptions: { debug: true }
    browserifyOptions: { debug: true }

module.exports = (grunt) ->
  #-------------------------------------------------------------------------
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'

    # TODO: This must be factored out into common-grunt-rules.
    symlink:
      # Symlink the Chrome and Firefox builds of Freedom under build/freedom/.
      freedom:
        files: [ {
          expand: true
          cwd: path.dirname(require.resolve('freedom/Gruntfile'))
          src: ['freedom.js']
          dest: 'build/freedom/'
        } ]

    copy:
      # Copy releveant non-typescript files to dev build.
      dev:
        files: [
          {
              expand: true,
              cwd: 'src/',
              src: ['**/*.html', '**/*.css',  '**/*.js'],
              dest: 'build/dev/',
              onlyIf: 'modified'
          }
        ]

      # Copy releveant non-typescript files to distribution build.
      dist:
        files: [
          {
              expand: true,
              cwd: 'src/',
              src: ['**/*.html', '**/*.css',  '**/*.js'],
              dest: 'build/dist/',
              onlyIf: 'modified'
          }
        ]

      # Copies relevant build tools into the tools directory. Should only be run
      # updating our build tools and wanting to commit and update (or when you
      # want to experimentally mess about with our build tools)
      #
      # Assumes that `ts:dev` has happened.
      tools:
        files: [{
          expand: true
          cwd: 'build/dev/'
          src: ['taskmanager/**'
                '!**/*.map'
                '!**/*.spec.js']
          dest: 'tools/'
          onlyIf: 'modified'
        }]

    tsd:
      refresh:
        options:
          # execute a command
          command: 'reinstall'
          # optional: always get from HEAD
          latest: true
          # optional: specify config file
          config: 'third_party/tsd.json'

    # Typescript rules
    ts:
      # Compile everything into the development build directory.
      dev:
        src: ['src/**/*.ts']
        #sourceRoot: 'build/'
        #mapRoot: 'build/'
        outDir: 'build/dev/'
        target: 'es5'
        comments: true
        noImplicitAny: true
        sourceMap: true
        declaration: true
        module: 'commonjs'
        fast: 'always'
      # Compile everything into the distribution build directory.
      dist:
        src: ['src/**/*.ts']
        #sourceRoot: 'build/'
        #mapRoot: 'build/'
        outDir: 'build/dist/'
        target: 'es5'
        comments: false
        noImplicitAny: true
        sourceMap: false
        declaration: true
        module: 'commonjs'
        fast: 'always'

    jamine:
      handler: jasmineSpec 'handler'
      taskmanager: jasmineSpec 'taskmanager'
      arraybuffers: jasmineSpec 'arraybuffers'
      crypto: jasmineSpec 'taskmanager'
      logging: jasmineSpec 'logging'

    browserify:
      copypasteFreedomChatMain:
        browserifyTypeScript 'build/dev/samples/copypaste-freedom-chat/main'
      copypasteFreedomChatFreedomModule:
        browserifyTypeScript 'build/dev/samples/copypaste-freedom-chat/freedom-module.ts'
      simpleFreedomChatMain:
        browserifyTypeScript 'build/dev/samples/simple-freedom-chat/main'
      simpleFreedomChatFreedomModule:
        browserifyTypeScript 'build/dev/samples/simple-freedom-chat/freedom-module.ts'

    # Compile everything into the development build directory.
    clean: ['build/'
            # 'src/.baseDir.ts' and '.tscache/' are created by grunt-ts.
            '.tscache/'
            'src/.baseDir.ts']

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-contrib-symlink'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-ts'
  grunt.loadNpmTasks 'grunt-tsd'

  #-------------------------------------------------------------------------
  # Define the tasks
  taskManager = new TaskManager.Manager();

  taskManager.add 'tools', [
    'ts:dev'
    'copy:tools'
  ]

  taskManager.add 'simpleFreedomChat', [
    'copy:dev'
    'browserify:simpleFreedomChatMain'
    'browserify:simpleFreedomChatFreedomModule'
  ]

  taskManager.add 'copypasteFreedomChat', [
    'copy:dev'
    'browserify:copypasteFreedomChatMain'
    'browserify:copypasteFreedomChatFreedomModule'
  ]

  taskManager.add 'samples', [
    'simpleFreedomChat'
    'copypasteFreedomChat'
  ]

  taskManager.add 'dev', [
    'copy:dev'
    'ts:dev'
    'samples'
  ]

  taskManager.add 'dist', [
    'copy:dist'
    'ts:dist'
  ]

  taskManager.add 'test', [
    'dev', 'jasmine'
  ]

  grunt.registerTask 'default', [
    'dev', 'dist', 'test'
  ]

  #-------------------------------------------------------------------------
  # Register the tasks
  taskManager.list().forEach((taskName) =>
    grunt.registerTask taskName, (taskManager.get taskName)
  );
