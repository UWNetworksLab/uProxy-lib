@echo off

:: Get the directory where this script is and set ROOT_DIR to that path. This
:: allows script to be run from different directories but always act on the
:: directory of the project (which is where this script is located).
for %%F in (%0) do set ROOT_DIR=%%~dpF
set NPM_BIN_DIR=%ROOT_DIR%node_modules\.bin\
cd "%ROOT_DIR%"

if "%1" == "install" (
	call :installDevDependencies
	exit /b 0
)
if "%1" == "third_party" (
	call :thirdParty
	exit /b 0
)
if "%1" == "tools" (
	call :buildTools
	exit /b 0
)
if "%1" == "clean" (
	call :clean
	exit /b 0
)
if "%1" NEQ "install" if "%1" NEQ "tools" ^
if "%1" NEQ "third_party" if "%1" NEQ "clean" (
	echo Usage: setup.sh [install^|tools^|third_party^|clean]
	echo   install      - Runs npm install and creates all needed files to build
	echo                  with grunt
	echo   third_party  - Installs all the files for 'build/third_party' needed
	echo                  by our grunt build rules (This is part of the 
	echo                  'setup.sh install' process)
	echo   tools        - Builds just the tools into build/tools (This part of 
	echo                  the 'setup.sh install' process)
	echo   clean        - Removes all dependencies installed by this script.
	exit /b 0
)

:: runCmd will run built-in DOS commands, and ignore errors
:runCmd
	echo Running: %1
	%~1
goto:eof

:: On Windows, npm, bower, tsd, and grunt are batch files
:: So we have to explicitly call then with "call"
:: These also happen to be the commands that we want to assert, 
:: or exit on failure for, so there is an additional "exit /b"
:runAndAssertCmd
	echo Running: %1
	call %~1 || exit /b
goto:eof

:: Same as runAndAssertCmd, but takes in an arbitrary number of
:: arguments, and calls them without stripping the double quotes
:: This is used for commands where the path may have spaces
:runAndAssertCmdArgs
	echo Running: %*
	call %* || exit /b
goto:eof

:: Note: tsc doesn't seem to support wildcard files (e.g. "tsc *.ts" in setup.sh)
:: So we use a for loop to achieve the same effect
:buildTools
	call :runCmd "mkdir build\dev\uproxy-lib\build-tools"
	call :runCmd "copy src\build-tools\*.ts build\dev\uproxy-lib\build-tools\"
	for /f "tokens=*" %%G in ('dir /b build\dev\uproxy-lib\build-tools\*.ts') do (
		call :runAndAssertCmdArgs "%NPM_BIN_DIR%tsc" --module commonjs --noImplicitAny build\dev\uproxy-lib\build-tools\%%G
	)
	call :runCmd "mkdir build\tools"
	call :runCmd "copy build\dev\uproxy-lib\build-tools\*.js build\tools\"
goto:eof

:: Note: The "tsd reinstall" command seems to create a third_party/third_party folder 
:: on Windows, so we manually delete this after
:thirdParty
	call :runAndAssertCmdArgs "%NPM_BIN_DIR%bower" install --allow-root
	call :runCmd "mkdir build\third_party"
	call :runAndAssertCmdArgs "%NPM_BIN_DIR%tsd" reinstall --config .\third_party\tsd.json
	call :runCmd "rmdir third_party\third_party /s /q"
	call :runCmd "robocopy third_party\ build\third_party\ /s /e > nul 2>&1"
	call :runCmd "mkdir build\third_party\freedom-pgp-e2e"
	call :runCmd "copy node_modules\freedom-pgp-e2e\dist build\third_party\freedom-pgp-e2e\"
	call :runCmd "mkdir build\third_party\freedom-port-control"
	call :runCmd "copy node_modules\freedom-port-control\dist build\third_party\freedom-port-control\"
goto:eof

:: We use robocopy to delete these folders since they (esp. node_modules)
:: may have path lengths greater than 260 characters
:clean
	call :runCmd "mkdir empty_dir"
	call :runCmd "robocopy empty_dir node_modules /mir > nul 2>&1"
	call :runCmd "robocopy empty_dir build /mir > nul 2>&1"
	call :runCmd "robocopy empty_dir .tscache /mir > nul 2>&1"
	call :runCmd "rmdir empty_dir node_modules build .tscache /s /q"
goto:eof

:installDevDependencies
	call :runAndAssertCmd "npm install"
	call :thirdParty
	call :buildTools
goto:eof
