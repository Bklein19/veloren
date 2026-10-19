@echo off
setlocal
cd /d "%~dp0"

if not defined VELOREN_TOOLS set "VELOREN_TOOLS=%USERPROFILE%\.codex\tools\veloren"
set "PATH=%USERPROFILE%\.cargo\bin;%VELOREN_TOOLS%\mingw64\bin;%VELOREN_TOOLS%\cmake-3.31.8-windows-x86_64\bin;%VELOREN_TOOLS%\ninja;%PATH%"
set "CMAKE_GENERATOR=Ninja"
set "CMAKE_BUILD_PARALLEL_LEVEL=4"
set "CARGO_INCREMENTAL=0"
set "CARGO_PROFILE_DEV_DEBUG=0"
set "VELOREN_ASSETS=%~dp0assets"
set "VELOREN_USERDATA=%~dp0userdata"

where cargo >nul 2>nul
if errorlevel 1 goto missing_tools
where gcc >nul 2>nul
if errorlevel 1 goto missing_tools
where cmake >nul 2>nul
if errorlevel 1 goto missing_tools
where ninja >nul 2>nul
if errorlevel 1 goto missing_tools

echo Building your Veloren fork. Unchanged code uses the existing build cache.
cargo +nightly-2026-06-13-x86_64-pc-windows-gnu build --locked --offline --target x86_64-pc-windows-gnu --bin veloren-voxygen --no-default-features --features default-publish,hot-reloading,shaderc-from-source --jobs 4
if errorlevel 1 goto build_failed
if /I "%~1"=="--build-only" exit /b 0

start "" /D "%~dp0" "%~dp0target\x86_64-pc-windows-gnu\debug\veloren-voxygen.exe"
exit /b 0

:missing_tools
echo A build tool is missing. See README-FORK.md for the Windows setup.
if /I not "%~1"=="--build-only" pause
exit /b 1

:build_failed
echo.
echo The build failed. Your existing saves have been kept.
echo Read the error above. New dependencies may need an online cargo fetch.
if /I not "%~1"=="--build-only" pause
exit /b 1
