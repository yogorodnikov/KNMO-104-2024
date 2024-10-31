@echo off
setlocal enabledelayedexpansion

if "%~1" == "-h" goto :help
if "%~1" == "--help" goto :help

set horizontal_count=%1
set vertical_count=%2
set input_dir=%3
set output_file=%4

if "%~1" == "" (
    goto :help
)
if "%~2" == "" (
    goto :help
)
if "%~3" == "" (
    goto :help
)
if "%~4" == "" (
    goto :help
)

for /f "delims=0123456789" %%i in ("%~1") do (
    goto :help
)
for /f "delims=0123456789" %%i in ("%~2") do (
    goto :help
)

if not exist "%~3" (
    goto :help
)

set file_list=
for %%f in (%input_dir%\*.jpg %input_dir%\*.jpeg %input_dir%\*.png) do (
    set file_list=!file_list! "%%f"
)

set /a required_images=horizontal_count*vertical_count
for %%i in (%file_list%) do (
    set /a count+=1
    if !count! gtr !required_images! (
        goto continue
    )
)
if !count! lss !required_images! (
    echo Not enough images for collage.
    exit /b
)
:continue

set input_files=
for %%i in (%file_list%) do (
    set /a counter+=1
    if !counter! leq !required_images! (
        set input_files=!input_files! %%i
    )
)

set max_width=0
set max_height=0
for %%i in (%input_files%) do (
    for /f "tokens=1,2 delims=x" %%a in ('magick identify -format "%%wx%%h" %%i') do (
        if %%a gtr !max_width! set max_width=%%a
        if %%b gtr !max_height! set max_height=%%b
    )
)


set counter=0
set size="!max_width!x!max_height! ^!"
set resized_files=
for %%i in (%input_files%) do (
    set /a counter+=1
    if !counter! leq !required_images! (
        magick %%i -resize !size! resized_!counter!.jpg
        set resized_files=!resized_files! resized_!counter!.jpg
    )
)

magick montage !resized_files! -geometry +0+0 -tile %horizontal_count%x%vertical_count% %output_file%

for %%i in (%resized_files%) do (
    rm %%i
)

echo Saved as: %output_file%

goto:eof

:help
echo Usage:
echo        converter.bat [horizontal_imgs] [vertical_imgs] [input_dir] [name_of_output_file.jpg]
:eof