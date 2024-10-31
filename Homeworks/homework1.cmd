@echo off
setlocal enabledelayedexpansion

chcp 65001 >nul

if "%1"=="/?" (
    echo Программа должна вывести справку по использованию и завершить работу
    echo enconvert.cmd directory
    echo Программа должна обработать все текстовые файлы из указанной папки directory.
    echo В случае возникновения каких-либо ошибок сообщить об этом пользователю
    exit /b
)

if "%1"=="" (
    echo Пожалуйста, укажите директорию для обработки.
    exit /b
)

set "directory=%1"
if not exist "%directory%" (
    echo Директория %directory% не существует.
    exit /b
)

for /r "%directory%" %%f in (*.txt) do (
    set "tempfile=%%~dpnf-temp.txt"
    set "outputfile=%%~dpnf.txt"

    iconv -f cp866 -t utf-8 "%%f" -o "!tempfile!"
    if !errorlevel! neq 0 (
        echo Ошибка при конвертации файла %%f
        del "!tempfile!"
        exit /b
    )

    move /y "!tempfile!" "!outputfile!"
    if !errorlevel! neq 0 (
        echo Ошибка при перемещении файла !tempfile! в !outputfile!
        exit /b
    )
)

echo Все файлы успешно конвертированы.
endlocal
