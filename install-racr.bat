@echo off
rem path to r6rs compiler
set SCHEME=d:\tools\racket\plt-r6rs.exe
rem path to compiled files
set RB=lib
rem path to RACR
set SCRIPT_DIR=%CD%
set RACRBIN=%SCRIPT_DIR%\%RB%

if  Exist "%RACRBIN%" (
	echo delete folder "%RACRBIN%"
	rd /S /Q %RACRBIN%
   )

echo Compile racr\core.scm into %RACRBIN%
%SCHEME% --install --collections "%RACRBIN%" "%SCRIPT_DIR%\racr\racr\core.scm" > compile.racr.log

echo Compile racr\testing.scm into %RACRBIN%
%SCHEME% --install --collections "%RACRBIN%" "%SCRIPT_DIR%\racr\racr\testing.scm"  > compile.racr.log


