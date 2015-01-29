// common-grunt-rules
/// <reference path='../../third_party/typings/node/node.d.ts' />
var path = require('path');
var Rule = (function () {
    function Rule(config) {
        this.config = config;
    }
    // Grunt Jasmine target creator
    // Assumes that the each spec file is a fully browserified js file.
    Rule.prototype.jasmineSpec = function (name, morefiles) {
        if (!morefiles) {
            morefiles = [];
        }
        return {
            src: [
                require.resolve('arraybuffer-slice'),
                path.join(path.dirname(require.resolve('es6-promise/package.json')), 'dist/promise-1.0.0.js')
            ].concat(morefiles),
            options: {
                specs: [path.join(this.config.devBuildDir, name, '/**/*.spec.static.js')],
                outfile: path.join(this.config.devBuildDir, name, '/SpecRunner.html'),
                keepRunner: true,
                template: require('grunt-template-jasmine-istanbul'),
                templateOptions: {
                    // Output location for coverage results
                    coverage: path.join(this.config.devBuildDir, name, 'coverage/results.json'),
                    report: {
                        type: 'html',
                        options: {
                            dir: path.join(this.config.devBuildDir, name)
                        }
                    }
                }
            }
        };
    };
    // Grunt browserify target creator
    Rule.prototype.browserify = function (filepath) {
        return {
            src: [path.join(this.config.devBuildDir, filepath + '.js')],
            dest: path.join(this.config.devBuildDir, filepath + '.static.js'),
            options: {
                debug: true,
            }
        };
    };
    // Grunt copy target creator: for copying freedom.js to
    Rule.prototype.copyFreedomToDest = function (freedomRuntimeName, destPath) {
        var freedomjsPath = require.resolve(freedomRuntimeName);
        var fileTarget = { files: [{
            nonull: true,
            src: [freedomjsPath],
            dest: path.join(destPath, path.basename(freedomjsPath)),
            onlyIf: 'modified'
        }] };
        return fileTarget;
    };
    // Grunt copy target creator: for copy a freedom library directory
    Rule.prototype.copySomeFreedomLib = function (libPath, destPath) {
        return { files: [{
            expand: true,
            cwd: this.config.devBuildDir,
            src: [
                libPath + '/*.json',
                libPath + '/*.js',
                libPath + '/*.html',
                libPath + '/*.css',
                '!' + libPath + '/*.spec.js',
                '!' + libPath + '/SpecRunner.html'
            ],
            dest: destPath,
            onlyIf: 'modified'
        }] };
    };
    return Rule;
})();
exports.Rule = Rule;
