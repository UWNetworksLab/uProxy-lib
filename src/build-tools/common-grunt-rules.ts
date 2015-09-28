// common-grunt-rules

/// <reference path='../../../third_party/typings/node/node.d.ts' />

import path = require('path');
import fs = require('fs');

export interface RuleConfig {
  // The path where code in this repository should be built in.
  devBuildPath :string;
  // The path from where third party libraries should be copied. e.g. as used by
  // sample apps.
  thirdPartyBuildPath :string;
  // The path to copy modules from this repository into. e.g. as used by sample
  // apps.
  localLibsDestPath :string;
}

export interface JasmineRule {
  src :string[];
  options ?:{
    specs :string[];
    outfile ?:string;
    keepRunner ?:boolean;
    template ?:string;
    templateOptions ?:{
      files    : string[];
      coverage : string;
      report   : {
          type :string;
          options :{
            dir: string;
          };
        }[];
    };
  };
}

export interface BrowserifyRule {
  src :string[];
  dest :string;
  options ?:{
    transform ?:Object[][];
    debug ?:boolean;
  };
}

export interface CopyFilesDescription {
  src     : string[];
  dest    : string;
  expand ?: boolean;
  cwd    ?: string;
  nonull ?: boolean;
  onlyIf ?: string; // can be: 'modified'
}

export interface CopyRule {
  files :CopyFilesDescription[];
}

export class Rule {
  constructor(public config :RuleConfig) {}

  // Note: argument is modified (and returned for conveniece);
  public addCoverageToSpec(spec:JasmineRule) :JasmineRule {
    var basePath = path.dirname(spec.options.outfile);

    spec.options.template = require('grunt-template-jasmine-istanbul');
    spec.options.templateOptions = {
      files: ['**/*', '!node_modules/**'],
      // Output location for coverage results
      coverage: path.join(basePath, 'coverage/results.json'),
      report: [
        { type: 'html', options: { dir: path.join(basePath, 'coverage') } },
        { type: 'lcov', options: { dir: path.join(basePath, 'coverage') } }
      ]
    };
    return spec;
  }

  // Grunt Jasmine target creator
  // Assumes that the each spec file is a fully browserified js file.
  public jasmineSpec(name:string, morefiles?:string[]) :JasmineRule {
    if (!morefiles) { morefiles = []; }
    return {
      src: [
        require.resolve('arraybuffer-slice'),
        require.resolve('es6-promise'),
        path.join(this.config.thirdPartyBuildPath, 'promise-polyfill.js'),
      ].concat(morefiles),
      options: {
        specs: [ path.join(this.config.devBuildPath, name, '/**/*.spec.static.js') ],
        outfile: path.join(this.config.devBuildPath, name, '/SpecRunner.html'),
        keepRunner: true
      }
    }
  }

  // Grunt browserify target creator
  public browserify(filepath:string, options = {
        browserifyOptions: { standalone: 'browserified_exports' }
      }) :BrowserifyRule {
    return {
      src: [ path.join(this.config.devBuildPath, filepath + '.js') ],
      dest: path.join(this.config.devBuildPath, filepath + '.static.js'),
      options: options
    };
  }

  // Note: argument is modified (and returned for conveniece);
  public addCoverageToBrowserify(rule:BrowserifyRule) :BrowserifyRule {
    if(!rule.options.transform) {
      rule.options.transform = [];
    }
    rule.options.transform.push(
      ['browserify-istanbul', { ignore: ['**/mocks/**', '**/*.spec.js'] }]);
    return rule
  }

  // Grunt browserify target creator, instrumented for istanbul
  public browserifySpec(filepath:string, options = {
        browserifyOptions: { standalone: 'browserified_exports' }
      }) : BrowserifyRule {
    return {
      src: [ path.join(this.config.devBuildPath, filepath + '.spec.js') ],
      dest: path.join(this.config.devBuildPath, filepath + '.spec.static.js'),
      options: options
    };
  }

  // Copies libs from npm, local libraries, and third party libraries to the
  // destination folder.
  public copyLibs(copyInfo:{
    // The names of npm libraries who's package exports should be copied (a
    // single JS file, see: https://docs.npmjs.com/files/package.json#main), or
    // the names of individual files from npm modules, using the require.resolve
    // nameing style, see: https://github.com/substack/node-resolve
    npmLibNames ?:string[];
    // Paths within this repository's build directory to be copied.
    pathsFromDevBuild ?:string[];
    // Paths within third party to be copied.
    pathsFromThirdPartyBuild ?:string[];
    // Other copy-style paths to be copied
    files ?:CopyFilesDescription[];
    // A relative (to devBuildPath) destination to copy files to.
    localDestPath:string; }) :CopyRule {

    // Default to empty list of dependencies.
    copyInfo.npmLibNames = copyInfo.npmLibNames || [];
    copyInfo.pathsFromDevBuild = copyInfo.pathsFromDevBuild || [];
    copyInfo.pathsFromThirdPartyBuild = copyInfo.pathsFromThirdPartyBuild || [];
    copyInfo.files = copyInfo.files || [];

    var destPath = path.join(this.config.devBuildPath, copyInfo.localDestPath);
    var destPathForLibs = path.join(destPath, this.config.localLibsDestPath);

    var allFilesForlibPaths :CopyFilesDescription[] = [];

    // The file-set for npm module files (or npm module output) from each of
    // |npmLibNames| to the destination path.
    copyInfo.npmLibNames.map((npmName) => {
      var npmModuleDirName :string;
      if (path.dirname(npmName) === '.') {
        // Note: |path.dirname(npmName)| gives '.' when |npmName| is just the
        // npm module name.
        npmModuleDirName = npmName;
      } else {
        npmModuleDirName = path.dirname(npmName);
      }

      var absoluteNpmFilePath = require.resolve(npmName);
      allFilesForlibPaths.push({
          expand: false,
          nonull: true,
          src: [absoluteNpmFilePath],
          dest: path.join(destPath,
                          npmModuleDirName,
                          path.basename(absoluteNpmFilePath)),
          onlyIf: 'modified'
        });
    });

    // The file-set for all relevant files in pathsFromDevBuild.
    copyInfo.pathsFromDevBuild.map((libPath) => {
      allFilesForlibPaths.push({
        expand: true,
        cwd: this.config.devBuildPath,
        src: [
          libPath + '/**/*',
          '!' + libPath + '/**/*.ts',
          '!' + libPath + '/**/*.spec.js',
          '!' + libPath + '/**/SpecRunner.html'
        ],
        dest: destPathForLibs,
        onlyIf: 'modified'
      });
    });

    // Provide a file-set to be copied for each local third_party module that is
    // listed in |pathsFromthirdPartyBuild|.
    copyInfo.pathsFromThirdPartyBuild.map((libPath) => {
      allFilesForlibPaths.push({
        expand: true,
        cwd: this.config.thirdPartyBuildPath,
        src: [
          libPath + '/**/*',
          '!' + libPath + '/**/*.ts',
          '!' + libPath + '/**/*.spec.js',
          '!' + libPath + '/**/SpecRunner.html'
        ],
        dest: destPath,
        onlyIf: 'modified'
      });
    });

    return { files: allFilesForlibPaths.concat(copyInfo.files) };
  }

  /*
   * Returns a list of tasks that should be run in order to build each spec.ts
   * file under a given directory.
   *
   * rootDir is the directory under which the layout will match what this file
   * expects for paths being passed in (i.e. under devBuildPath).
   *
   * getTests('src', gruntConfig);
   *   This adds tests for all the directories under src/ and browserifies all
   *   spec files within those directories.
   * getTests('src', gruntConfig, 'generic_ui/scripts');
   *   This adds tests for all the directories under src/generic_ui/scripts and
   *   browserifies spec files within those directories.  All paths will be
   *   relative to src/.
   * getTests('src', gruntConfig, undefined, ['integration-tests']);
   *   This adds tests for all the directories under src/ and browserifies all
   *   spec files within those directories.  Any directories named
   *   "integration-tests" will not be examined.
   */
  public getTests = (rootDir :string, gruntConfig :{[c :string] :{[t :string] :Object}},
                     current?:string, ignore?:string[], coverage?:boolean) => {
    if (typeof ignore === 'undefined') {
      ignore = [];
    }

    if (typeof coverage === 'undefined') {
      coverage = false;
    }

    if (typeof current === 'undefined') {
      current = '';
    }

    var dir = path.join(rootDir, current);

    var tasks :string[] = [];
    var childTasks :string[] = [];

    var files = fs.readdirSync(dir);
    for (var f in files) {
      var file = files[f];
      if (ignore.indexOf(file) !== -1) {
        continue;
      }

      var stats = fs.statSync(path.join(dir, file));
      if (stats.isDirectory()) {
        childTasks = childTasks.concat(
            this.getTests(rootDir, gruntConfig, path.join(current, file), ignore, coverage));
        continue;
      }

      var match = /(.+)\.spec\.ts/.exec(file);
      if (!match) {
        continue;
      }

      var loc = path.join(current, match[1]);
      var browserifyName = loc + 'Spec';
      var browserifyRule = this.browserifySpec(loc);

      if (coverage) {
        browserifyName += 'Cov';
        browserifyRule = this.addCoverageToBrowserify(browserifyRule);
      }

      gruntConfig['browserify'][browserifyName] = browserifyRule;
      tasks.push('browserify:' + browserifyName);
    }

    if (tasks.length) {
      var testName = current;
      var testRule = this.jasmineSpec(current);

      if (coverage) {
        testName += 'Cov';
        testRule = this.addCoverageToSpec(testRule);
      }

      gruntConfig['jasmine'][testName] = testRule;
      tasks.push('jasmine:' + testName);
    }

    return childTasks.concat(tasks);
  }

}  // class Rule
