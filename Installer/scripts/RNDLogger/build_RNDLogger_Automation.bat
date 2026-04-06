@echo off
REM ----------------------------------------
REM Build script for RNDLogger_Automation NSIS installer
REM ----------------------------------------

REM Exit immediately on error-like behavior is handled via checks
setlocal ENABLEDELAYEDEXPANSION

REM NSIS makensis.exe path (Windows native)
set "NSIS=C:\Program Files (x86)\NSIS\Bin\makensis.exe"

REM NSIS script name
set "NSI_SCRIPT=RNDLogger_Automation.nsi"

REM Sanity check: NSI file exists
if not exist "%NSI_SCRIPT%" (
    echo ERROR: NSIS script not found: %NSI_SCRIPT%
    exit /b 1
)

REM Sanity check: makensis.exe exists
if not exist "%NSIS%" (
    echo ERROR: makensis.exe not found at:
    echo  %NSIS%
    exit /b 1
)

echo Building NSIS installer...
echo Using: %NSIS%
echo Script: %NSI_SCRIPT%
echo.

REM Run NSIS compiler
"%NSIS%" "%NSI_SCRIPT%"
if errorlevel 1 (
    echo.
    echo ERROR: Build failed
    exit /b 1
)

echo.
echo ✅ Build completed successfully
exit /b 0
