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

echo Testing shared gameplay systems. An optional argument filters test names.
cargo +nightly-2026-06-13-x86_64-pc-windows-gnu -Z panic-abort-tests test --profile dev --locked --offline --target x86_64-pc-windows-gnu -p veloren-common-systems --lib --features plugins,common/hot-reloading --jobs 4 %* -- --nocapture
exit /b %errorlevel%

:missing_tools
echo A build tool is missing. See README-FORK.md for the Windows setup.
exit /b 1
