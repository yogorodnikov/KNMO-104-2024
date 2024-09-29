@echo off
setlocal enabledelayedexpansion

if "%1"=="/?" (
    echo Usage: %~nx0 directory
    echo Converts all .txt files with CP866 encoding in the specified directory to UTF-8 encoding.
    goto :EOF
)

if "%~1"=="" (
    echo Error: No directory specified.
    goto :EOF
)

if not exist "%~1" (
    echo Error: Directory "%~1" does not exist.
    goto :EOF
)

set "DIR=%~1"

FOR /R "%DIR%" %%f IN (*.txt) DO (
    set "tempFile=%TEMP%\enconvert_temp_%RANDOM%.tmp"

    if exist "!tempFile!" (
        set "tempFile=%TEMP%\enconvert_temp_%RANDOM%%RANDOM%.tmp"
    )

    powershell -Command "Get-Content -LiteralPath \"%%f\" -Encoding OEM | Out-File -LiteralPath \"!tempFile!\" -Encoding UTF8"
    if errorlevel 1 (
        echo Error processing file "%%f"
        if exist "!tempFile!" del "!tempFile!"
    ) else (
        move /Y "!tempFile!" "%%f" >nul
        if errorlevel 1 (
            echo Error replacing file "%%f"
            if exist "!tempFile!" del "!tempFile!"
        )
    )
)
endlocal
