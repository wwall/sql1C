call install-racr.bat


rem compile examples
set LIB=%CD%\lib
set TEST=%CD%\tests
set LANG=%CD%\src\lang
if  Exist "%LIB%\sql1C" (
	echo Delete dir %LIB%\sql1C
	RD /Q /S %LIB%\lang
)

echo Compile %LANG% 

echo Compile exception-api.scm
%SCHEME% ++path "%RACRBIN%" ++path "%LIB%" --install --collections "%LIB%" "%LANG%\exception-api.scm" 
echo Compile lexer.scm
%SCHEME% ++path "%RACRBIN%" ++path "%LIB%" --install --collections "%LIB%" "%LANG%\lexer.scm" 

echo Testing test.lexer.scm
%SCHEME% ++path "%RACRBIN%" ++path "%LIB%"  "%TEST%\test.lexer.scm" 


 
