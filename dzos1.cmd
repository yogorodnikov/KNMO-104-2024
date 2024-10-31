@echo off
setlocal enabledelayedexpansion

rem Display help
if "%~1" == "/?" (
    echo Usage: enconvert.cmd directory
    echo Converts all .txt files in the specified directory from CP866 to UTF-8.
    exit /b 0
)

rem Check if directory is provided
if "%~1" == "" (
    echo Please specify a directory.
    exit /b 1
)

set "directory=%~1"

rem Check if the directory exists
if not exist "%directory%" (
    echo The specified directory does not exist.
    exit /b 1
)

echo Processing directory: %directory%

rem Iterate over all .txt files in the directory and its subdirectories
for /r "%directory%" %%f in (*.txt) do (
    set "filepath=%%f"
    
    rem Create a temporary file path
    set "tmpfilepath=%%f-utf8.txt"
    
    rem Convert the file from CP866 to UTF-8
    powershell -Command "Get-Content !filepath! -Encoding Unicode | Out-File !tmpfilepath! -Encoding UTF8"
    
    rem Check if the conversion was successful
    if exist "!tmpfilepath!" (
        echo Successfully converted: !filepath!
    ) else (
        echo Error converting: !filepath!
    )
)

echo Conversion complete.
exit /b 0