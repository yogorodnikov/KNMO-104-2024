@echo off

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

if exist temp.txt (
    echo Rename file %cd%\temp.txt and reboot
    exit /b
)

for /r %1 %%f in (*.txt) do (
    GnuWin32\bin\iconv.exe -f cp866 -t utf-8 %%~fsf > temp.txt
    copy temp.txt %%~fsf
    del temp.txt
)

echo Complite!