module.exports = (grunt) ->

  path = require 'path';

  #-------------------------------------------------------------------------
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'

    typescript:
      taskmanager:  # source code
        src: ['src/taskmanager/taskmanager.ts']
        dest: 'build/'
        options:
          basePath: 'src/'
      taskmanager_spec:  # spec test files
        src: ['src/taskmanager/taskmanager.spec.ts']
        dest: 'build/'
        options:
          basePath: 'src/'
      util:  # source code
        src: ['src/util/arraybuffers.ts']
        dest: 'build/'
        options:
          basePath: 'src/'
          ignoreError: false
      util_spec:  # spec test files
        src: ['src/util/arraybuffers.spec.ts']
        dest: 'build/'
        options:
          basePath: 'src/'
          ignoreError: false
    jasmine:
      taskmanager:
        src: ['build/taskmanager/taskmanager.js']
        options:
          specs: 'build/taskmanager/taskmanager.spec.js'
          outfile: 'build/_SpecRunner.html'
          keepRunner: true
      util:
        src: ['build/util/**/*.js']
        options:
          specs: 'build/util/**/*.spec.js'
    clean: ['build/**']
  }  # grunt.initConfig

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-typescript'

  #-------------------------------------------------------------------------
  grunt.registerTask 'build', [
    'typescript:taskmanager'
    'typescript:taskmanager_spec'
    'typescript:util'
    'typescript:util_spec'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  grunt.registerTask 'test', [
    'build'
    'jasmine:taskmanager'
    'jasmine:util'
  ]

  grunt.registerTask 'default', [
    'build'
  ]
