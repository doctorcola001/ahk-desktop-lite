@echo off
rem ---------------------------------------------------------------
rem AHK desktop lite - portable launcher (no install needed)
rem Needs AutoHotkey v2's AutoHotkey64.exe in the "autohotkey"
rem folder right next to this file.
rem Download: https://www.autohotkey.com/
rem ---------------------------------------------------------------
setlocal

if not exist "%~dp0autohotkey\AutoHotkey64.exe" (
  echo.
  echo   [X] AutoHotkey64.exe not found in:
  echo       %~dp0autohotkey\
  echo.
  echo   Get the portable AutoHotkey v2 package from
  echo   https://www.autohotkey.com/  and put AutoHotkey64.exe
  echo   into that folder, then run this file again.
  echo.
  pause
  exit /b 1
)

start "" "%~dp0autohotkey\AutoHotkey64.exe" "%~dp0scripts\gui.ahk"
