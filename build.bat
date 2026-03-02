@echo off
setlocal enabledelayedexpansion
title Minecraft Mod Builder

echo ============================================
echo         Minecraft Mod Builder
echo ============================================
echo.

:: -----------------------------------------------
:: Step 1: Check if Docker is installed
:: -----------------------------------------------
echo [1/3] Checking if Docker is installed...
docker --version >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Docker is not installed. Starting installer...
    echo.
    echo This may take a few minutes. Please follow any prompts that appear.
    echo After Docker finishes installing, you may need to restart your computer.
    echo Once restarted, just run this file again to build your mod!
    echo.

    :: Download Docker Desktop installer
    echo Downloading Docker Desktop installer...
    powershell -Command "Invoke-WebRequest -Uri 'https://desktop.docker.com/win/main/amd64/Docker%%20Desktop%%20Installer.exe' -OutFile '%TEMP%\DockerDesktopInstaller.exe'"
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo ERROR: Could not download Docker. Please check your internet connection.
        echo You can also download Docker manually from: https://www.docker.com/products/docker-desktop/
        pause
        exit /b 1
    )

    echo Running Docker installer...
    "%TEMP%\DockerDesktopInstaller.exe" install --quiet
    if %ERRORLEVEL% NEQ 0 (
        echo.
        echo Docker installation may require a restart to complete.
        echo Please restart your computer and then run this file again.
        pause
        exit /b 1
    )

    echo.
    echo Docker was installed! Please restart your computer and run this file again.
    pause
    exit /b 0
) else (
    echo Docker is installed. Good to go!
)

:: Make sure Docker is running
echo Checking if Docker is running...
docker info >nul 2>&1
if %ERRORLEVEL% EQU 0 goto dockerready

echo Docker is installed but not running. Trying to start Docker Desktop...
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo Waiting for Docker to start (this can take up to a minute)...
set WAIT=0
:waitloop
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if %ERRORLEVEL% EQU 0 goto dockerready
set /a WAIT+=1
if !WAIT! LSS 12 (
    echo Still waiting... (!WAIT! of 12 checks done^)
    goto waitloop
)
echo.
echo ERROR: Docker did not start in time.
echo Please open Docker Desktop manually and wait for it to fully start, then run this file again.
pause
exit /b 1

:dockerready
echo Docker is ready!
echo.

:: -----------------------------------------------
:: Step 2: Build the Docker image
:: -----------------------------------------------
echo [2/3] Building the mod builder image...
echo (This may take a few minutes the first time, but will be faster after that.)
echo.
docker build -t fabric-mod-builder .
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: The image build failed. Check the output above for details.
    pause
    exit /b 1
)
echo.
echo Image built successfully!
echo.

:: -----------------------------------------------
:: Step 3: Run the mod builder
:: -----------------------------------------------
echo [3/3] Building your mod JARs...
echo.
echo Deleting old build files...
if exist "build\libs" (
    rmdir /s /q "build\libs"
)

echo Running the mod builder in Docker...
docker run --rm -v "%CD%/build/libs:/build/build/libs" fabric-mod-builder
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: The mod build failed. Check the output above for details.
    echo Common causes: a syntax error in your Java code, or a missing file.
    pause
    exit /b 1
)

echo.
echo ============================================
echo   Build complete! Your JAR files are in:
echo   build\libs\
echo ============================================
echo.
endlocal
exit /b 0