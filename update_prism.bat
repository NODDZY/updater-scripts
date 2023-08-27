@echo off
setlocal

:: Set path variables, repository URL, etc
set dlfile=%temp%\prism.zip
set lastverpath=VERSION

set linkmain=PrismLauncher/PrismLauncher
set link=https://api.github.com/repos/%linkmain%/releases/latest

:: Check last version
:: If first install (or no VERSION file) set current version to null
set oldver=""
if EXIST %lastverpath% (set /p oldver=<%lastverpath%)

:: Get Prism version and date from releases/latest
for /f "tokens=2 delims=, " %%a in ('curl -s %link% ^| findstr /L "tag_name"') do (set ver=%%a)
:: Simple check for API access
:: Will trigger if API rate limit exceeded or if user has no internet connection
if NOT DEFINED ver (
    echo Error getting GitHub API
    pause
    goto :EXIT
)

:: Show CLI menu
cls
echo.
echo #####   #####   ####  ######  ##   ##
echo ##  ##  ##  ##   ##   ##      ### ###
echo #####   #####    ##   ######  ## # ##
echo ##      ## ##    ##       ##  ##   ##
echo ##      ##  ##  ####  ######  ##   ##
echo.
if not %oldver% == "" (echo Current version: %oldver%)
echo Latest version:  %ver%
echo.
choice /C:12 /N /M "Do you want to update? [1 - Yes, 2 - Exit]: "
if errorlevel 2 goto :EXIT
if errorlevel 1 goto :DOWNLOAD

:DOWNLOAD
echo Downloading...
:: Get Prism release as .zip from releases/latest
for /f "tokens=2 delims= " %%a in ('curl -s %link% ^| findstr /L "browser_download_url" ^| findstr /V "arm64-Portable" ^| findstr /L ".zip"') do (set dl=%%a)
:: Download file using Invoke-WebRequest command
if not exist %dlfile% (powershell -command "& {Invoke-WebRequest -Uri %dl% -OutFile %dlfile%}")
:: Extract downloaded .zip file to current folder
tar -xf %dlfile%
:: Delete temporary .zip file
del /f /q %dlfile%
:: Update VERSION file
echo %ver% > %lastverpath%
goto :EXIT

:EXIT
endlocal
exit
