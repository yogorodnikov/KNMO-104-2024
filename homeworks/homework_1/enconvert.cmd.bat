@Echo Off
chcp 65001 > nul
IF "%1"=="?" (
ECHO Для использования скрипта введите путь до директории
ECHO после чего все файлы с кодировкой cp866 переведутся в кодировку UTF-8
exit /b1
) 
if "%1" == "" (
    echo Пожалуйста, выберете директорию
    exit /b 1
)
set "direc=%1"
if not exist "%direc%" (
    echo Эта директория не существует
    exit /b 1
)

FOR /R %direc% %%f IN (*.txt) DO GnuWin32\bin\iconv.exe -f CP866 -t UTF-8 %%f > %%f-utf8.txt %1
ECHO Копирование прошло успешно
)
pause