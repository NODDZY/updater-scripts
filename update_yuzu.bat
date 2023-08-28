@echo off
setlocal

:: Set path variables, repository URL, etc
set dlfile=%temp%\yuzu.zip
set defdir=yuzu-windows-msvc
set lastverpath=VERSION

set repo=yuzu-emu/yuzu-mainline
set link=https://api.github.com/repos/%repo%/releases/latest

:: Get local version
:: If first install (or no VERSION file) set current version to null
set oldver=""
if exist %lastverpath% (set /p oldver=<%lastverpath%)

:: Get latest version
for /f "tokens=2 delims=, " %%a in ('curl -s %link% ^| findstr /l "tag_name"') do (set ver=%%a)
set ver=%ver:"=%
:: Simple check for API access
:: Will trigger if API rate limit exceeded or if user has no internet connection
if not defined ver (
    echo Error getting GitHub API
    pause
    goto :EXIT
)

:: Show CLI menu
cls
echo.
echo ###  ###  ##   ##  #######  ##   ##
echo  ##  ##   ##   ##  ##  ##   ##   ##
echo   ####    ##   ##    ###    ##   ##
echo    ##     ##   ##   ##  ##  ##   ##
echo   ####     #####   #######   #####
echo.
if not %oldver% == "" (echo Current version: %oldver%)
echo Latest version:  %ver%
echo.
choice /c:12 /n /m "Do you want to update? [1 - Yes, 2 - Exit]: "
if errorlevel 2 goto :EXIT
if errorlevel 1 goto :DOWNLOAD

:DOWNLOAD
echo Downloading...
:: Download latest release
for /f "tokens=2 delims= " %%a in ('curl -s %link% ^| findstr /l "browser_download_url" ^| findstr /v "debug" ^| findstr /l ".zip"') do (set dl=%%a)
if not exist %dlfile% (powershell -command "& {Invoke-WebRequest -Uri %dl% -OutFile %dlfile%}")
:: Extract downloaded .zip file
tar -xf %dlfile%
:: Copy content of yuzu-windows-msvc folder to current folder
xcopy .\%defdir%\ .\ /E /H /C /I /Y
:: Delete temporary .zip file and remove extracted folder
del /f /q %dlfile%
rmdir /s /q .\%defdir%
:: Update VERSION file
echo %ver% > %lastverpath%
goto :EXIT

:EXIT
endlocal
exit
