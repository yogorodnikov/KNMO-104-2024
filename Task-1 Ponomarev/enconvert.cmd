@echo off
if "%1"=="/?" ( 
    echo Usage: enconvert.cmd directory
    exit /b
)

if not exist %~f1/ (
    echo Directory doesn't exist!
    exit /b 1
)
 
if exist temp.txt (
    echo Rename file %cd%\temp.txt and reboot
    exit /b
)
 
for /r %1 %%f in (*.txt) do (
    echo %%~fsf
    iconv -f cp866 -t utf-8 %%~fsf > temp.txt
    copy temp.txt %%~fsf
    del temp.txt
)
