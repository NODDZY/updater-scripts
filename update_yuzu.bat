@echo off
setlocal

:: Set path variables, repository URL, etc
set dlfile=%temp%\yuzu.zip
set defdir=yuzu-windows-msvc
set yuzulastverpath=VERSION

set linkmain=yuzu-emu/yuzu-mainline
set link=https://api.github.com/repos/%linkmain%/releases/latest

:: Check last version
:: If first install (or no VERSION file) set current version to null
if NOT EXIST %yuzulastverpath% (set oldver="")
set /p oldver=<%yuzulastverpath%

:: Get Yuzu version and date from releases/latest
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
echo ###  ### ##   ##  #######  ##   ##
echo  ##  ##  ##   ##  ##  ##   ##   ##
echo   ####   ##   ##     ##    ##   ##
echo    ##    ##   ##   ##      ##   ##
echo    ##    ##   ##  ##   ##  ##   ##
echo   ####    #####   #######   #####
echo.
if not %oldver% == "" (echo Current version: %oldver%)
echo Latest version:  %ver%
echo.
choice /C:12 /N /M "Do you want to update? [1 - Yes, 2 - Exit]: "
if errorlevel 2 goto :EXIT
if errorlevel 1 goto :DOWNLOAD

:DOWNLOAD
echo Downloading...
:: Get Yuzu release as .zip from releases/latest
for /f "tokens=2 delims= " %%a in ('curl -s %link% ^| findstr /L "browser_download_url" ^| findstr /V "debug" ^| findstr /L ".zip"') do (set dl=%%a)
:: Download file using Invoke-WebRequest command
if not exist %dlfile% (powershell -command "& {Invoke-WebRequest -Uri %dl% -OutFile %dlfile%}")
:: Extract downloaded .zip file
tar -xf %dlfile%
:: Copy content of yuzu-windows-msvc folder to current folder
xcopy .\%defdir%\ .\ /E /H /C /I /Y
:: Delete temporary .zip file and remove extracted folder
del /f /q %dlfile%
rmdir /s /q .\%defdir%
:: Update VERSION file
echo %ver% > %yuzulastverpath%
goto EXIT

:EXIT
endlocal
exit