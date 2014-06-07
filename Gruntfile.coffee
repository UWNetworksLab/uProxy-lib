TaskManager = require './taskmanager'

module.exports = (grunt) ->

  FILES =
    jasmine_helpers: [
      # Help Jasmine's PhantomJS understand promises.
      'node_modules/es6-promise/dist/promise-*.js'
      '!node_modules/es6-promise/dist/promise-*amd.js'
      '!node_modules/es6-promise/dist/promise-*.min.js'
    ]

  path = require 'path';

  #-------------------------------------------------------------------------
  # Function to make a typescript rule based on expected directory layout.
  typeScriptSrcRule = (name) ->
    src: ['build/typescript-src/' + name + '/**/*.ts',
          '!build/typescript-src/' + name + '/**/*.d.ts']
    dest: 'build/'
    options:
      basePath: 'build/typescript-src/'
      ignoreError: false
      noImplicitAny: true
      sourceMap: true
  # Function to make jasmine spec assuming expected dir layout.
  jasmineSpec = (name) ->
    src: FILES.jasmine_helpers.concat([
      'build/' + name + '/**/*.js',
      '!build/' + name + '/**/*.spec.js'
    ])
    options:
      specs: 'build/' + name + '/**/*.spec.js'
      outfile: 'build/' + name + '/_SpecRunner.html'
      keepRunner: true

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

    typescript:
      taskmanager: typeScriptSrcRule 'taskmanager'
      arraybuffers: typeScriptSrcRule 'arraybuffers'
      handler: typeScriptSrcRule 'handler'

    jasmine:
      handler: jasmineSpec 'handler'
      taskmanager: jasmineSpec 'taskmanager'
      arraybuffers: jasmineSpec 'arraybuffers'

    clean: ['build/**']
  }  # grunt.initConfig

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-typescript'

  #-------------------------------------------------------------------------
  # Define the tasks
  taskManager = new TaskManager.Manager();

  taskManager.add 'typeScriptBase', [
    'copy:thirdPartyTypeScript'
    'copy:typeScriptSrc'
  ]

  taskManager.add 'taskmanager', [
    'typeScriptBase'
    'typescript:taskmanager'
  ]

  taskManager.add 'arraybuffers', [
    'typeScriptBase'
    'typescript:arraybuffers'
  ]

  taskManager.add 'handler', [
    'typeScriptBase'
    'typescript:handler'
  ]

  taskManager.add 'build', [
    'typeScriptBase'
    'arraybuffers'
    'taskmanager'
    'handler'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  taskManager.add 'test', [
    'build'
    'jasmine:handler'
    'jasmine:taskmanager'
    'jasmine:arraybuffers'
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
