module.exports = (grunt) ->

  path = require('path');

  #-------------------------------------------------------------------------
  grunt.initConfig {
    pkg: grunt.file.readJSON('package.json')

    typescript:
      taskmanager:
        src: ['src/taskmanager/taskmanager.ts']
        dest: 'build/'
        options: { base_path: 'src/' }
      taskmanager_spec:
        src: ['spec/taskmanager/taskmanager_spec.ts']
        dest: 'build/'
        options: { base_path: '' }
    jasmine: {
      taskmanager:
        src: ['build/taskmanager/**.js']
        options : { specs : 'build/spec/taskmanager/**/*_spec.js' }
    clean: ['build/**']
  }  # grunt.initConfig

  #-------------------------------------------------------------------------
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-jasmine'
  grunt.loadNpmTasks 'grunt-typescript'
  grunt.loadNpmTasks 'grunt-jasmine-node'
  grunt.loadNpmTasks 'grunt-env'

  #-------------------------------------------------------------------------
  grunt.registerTask 'build', [
    'typescript:taskmanager'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  grunt.registerTask 'test', [
    'build'
    'jasmine:taskmanager'
  ]

  grunt.registerTask 'default', [
    'build'
  ]
