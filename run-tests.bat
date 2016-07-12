call install-racr.bat


rem compile examples
set LIB=%CD%\lib
set TEST=%CD%\tests
set SQL1C=%CD%\src\sql1C
if  Exist "%SQL1C%\%RB%" (
	echo Delete dir %SQL1C%\%RB%
	RD /Q /S %SQL1C%\%RB%
)

echo Compile %SQL1C% example

echo Compile exception-api.scm
%SCHEME% ++path "%RACRBIN%" ++path "%LIB%" --install --collections "%LIB%" "%SQL1C%\lang\exception-api.scm" 
echo Compile lexer.scm
%SCHEME% ++path "%RACRBIN%" ++path "%LIB%" --install --collections "%LIB%" "%SQL1C%\lang\lexer.scm" 

echo Testing test.lexer.scm
%SCHEME% ++path "%RACRBIN%" ++path "%LIB%"  "%TEST%\test.lexer.scm" 


 
