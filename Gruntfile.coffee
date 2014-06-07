module.exports = (grunt) ->

  path = require 'path';

  # Functions to make typescript rules based on directory layout.
  typeScriptSrcRule = (name) ->
    src: ['build/typescript-src/' + name + '/**/*.ts',
          '!build/typescript-src/' + name + '/**/*.d.ts']
    dest: 'build/'
    options:
      basePath: 'build/typescript-src/'
      ignoreError: false
      noImplicitAny: true
      sourceMap: true
  jasmineSpec = (name) ->
    src: ['build/' + name + '/**/*.js', '!build/' + name + '/**/*.spec.js']
    options:
      specs: 'build/' + name + '/**/*.spec.js'
      outfile: 'build/' + name + '/_SpecRunner.html'
      keepRunner: true

  #-------------------------------------------------------------------------
  grunt.initConfig {
    pkg: grunt.file.readJSON 'package.json'

    copy:
      thirdPartyTypeScript: { files: [
        {
          expand: true
          src: ['third_party/**/*.ts']
          dest: 'build/typescript-src/'
        }
        {
          expand: true, cwd: 'node_modules'
          src: ['freedom-typescript-api/interfaces/**/*.ts']
          dest: 'build/typescript-src'
        }
        ]}
      typeScriptSrc: { files: [ {
        expand: true, cwd: 'src/'
        src: ['**/*.ts']
        dest: 'build/typescript-src/' } ] }

    # TODO: Write code to standardize the copy rules and the typescript
    # compilation rules for a project based on this style of directory layout.
    # Including watch rules. Including spec rules. Including ignoring of .d in
    # compilation.
    typescript:
      taskmanager: typeScriptSrcRule 'taskmanager'
      arraybuffers: typeScriptSrcRule 'arraybuffers'
      handler: typeScriptSrcRule 'handler'

    jasmine:
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
  grunt.registerTask 'build', [
    'copy:thirdPartyTypeScript'
    'copy:typeScriptSrc'
    'typescript:taskmanager'
    'typescript:arraybuffers'
    'typescript:handler'
  ]

  # This is the target run by Travis. Targets in here should run locally
  # and on Travis/Sauce Labs.
  grunt.registerTask 'test', [
    'build'
    'jasmine:taskmanager'
    'jasmine:arraybuffers'
  ]

  grunt.registerTask 'default', [
    'test'
  ]
