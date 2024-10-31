@echo off 
for /R %directory% %%f in (*.txt) do (
    chcp 65001
    type "%%f" > "%%f-utf8.txt"
    del %%f
    echo errorlevel: %errorlevel%
)