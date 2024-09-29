@echo off
setlocal enabledelayedexpansion

if "%~1"=="/?" (
    echo Use: enconvert.cmd directory
    echo Program convert all .txt files from choice patch cp866 in utf-8.
    exit /b 0
)

if "%~1"=="" (
    echo Error: Choice directory
    echo Use: enconvert.cmd directory
    exit /b 1
)

set "directory=%~1"

if not exist "%directory%" (
    echo Error: Directory not found.
    exit /b 1
)

for /r "%directory%" %%f in (*.txt) do (
    set "file=%%f"
    set "tempfile=%%~dpnf_temp%%~xf"

    if exist "!tempfile!" (
        echo Error: A temporary !tempfile! already exists.
        exit /b 1
    )

    type "!file!" > "!tempfile!"
    if %errorlevel% neq 0 (
        echo Error: Error reading the file !file!.
        del "!tempfile!"
        exit /b %errorlevel%
    )

    powershell -Command "Get-Content -Path '!file!' -Encoding Default | Set-Content -Path '!tempfile!' -Encoding UTF8"
    if %errorlevel% neq 0 (
        echo Error: Error convert !file!.
        del "!tempfile!"
        exit /b %errorlevel%
    )

    move /y "!tempfile!" "!file!" > nul
    if %errorlevel% neq 0 (
        echo Error: Error when replacing a file !file!.
        del "!tempfile!"
        exit /b %errorlevel%
    )
)

echo Convert end
exit /b 0 
