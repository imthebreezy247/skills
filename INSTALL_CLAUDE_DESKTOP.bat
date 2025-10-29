@echo off
setlocal enabledelayedexpansion
REM Installation script for Claude Desktop Skills
REM This copies all skills to Claude Desktop's skills directory

REM Change to the directory where this batch file is located
cd /d "%~dp0"

echo ========================================
echo Claude Desktop Skills Installer
echo ========================================
echo.
echo Running from: %CD%
echo.

REM Set the Claude Desktop skills directory path
set "CLAUDE_SKILLS_DIR=%APPDATA%\Claude\skills"

echo Checking Claude Desktop installation...
if not exist "%APPDATA%\Claude" (
    echo ERROR: Claude Desktop not found!
    echo Please install Claude Desktop first from https://claude.ai/download
    pause
    exit /b 1
)

echo Creating skills directory if it doesn't exist...
if not exist "%CLAUDE_SKILLS_DIR%" (
    mkdir "%CLAUDE_SKILLS_DIR%"
    echo Created skills directory: %CLAUDE_SKILLS_DIR%
) else (
    echo Skills directory already exists: %CLAUDE_SKILLS_DIR%
)

REM Clean up old broken installation if it exists
if exist "%CLAUDE_SKILLS_DIR%\!skillname!" (
    echo Cleaning up old broken installation...
    rmdir /S /Q "%CLAUDE_SKILLS_DIR%\!skillname!" 2>nul
    echo    - Removed broken !skillname! folder
)

echo.
echo ========================================
echo Installing Example Skills
echo ========================================
echo.

REM Copy all example skills
set SKILLS_INSTALLED=0
for %%i in (algorithmic-art artifacts-builder brand-guidelines canvas-design internal-comms mcp-builder skill-creator slack-gif-creator template-skill theme-factory webapp-testing) do (
    if exist "%%i" (
        echo Installing %%i...
        xcopy "%%i" "%CLAUDE_SKILLS_DIR%\%%i\" /E /I /Y /Q
        if !ERRORLEVEL! EQU 0 (
            echo    - %%i installed successfully
            set /a SKILLS_INSTALLED+=1
        ) else (
            echo    - ERROR installing %%i
        )
    ) else (
        echo    - WARNING: %%i folder not found, skipping
    )
)

echo.
echo ========================================
echo Installing Document Skills
echo ========================================
echo.

REM Copy all document skills individually
if exist "document-skills\docx" (
    echo Installing docx...
    xcopy "document-skills\docx" "%CLAUDE_SKILLS_DIR%\docx\" /E /I /Y /Q
    if !ERRORLEVEL! EQU 0 (
        echo    - docx installed successfully
        set /a SKILLS_INSTALLED+=1
    )
) else (
    echo    - WARNING: document-skills\docx not found
)

if exist "document-skills\pdf" (
    echo Installing pdf...
    xcopy "document-skills\pdf" "%CLAUDE_SKILLS_DIR%\pdf\" /E /I /Y /Q
    if !ERRORLEVEL! EQU 0 (
        echo    - pdf installed successfully
        set /a SKILLS_INSTALLED+=1
    )
) else (
    echo    - WARNING: document-skills\pdf not found
)

if exist "document-skills\pptx" (
    echo Installing pptx...
    xcopy "document-skills\pptx" "%CLAUDE_SKILLS_DIR%\pptx\" /E /I /Y /Q
    if !ERRORLEVEL! EQU 0 (
        echo    - pptx installed successfully
        set /a SKILLS_INSTALLED+=1
    )
) else (
    echo    - WARNING: document-skills\pptx not found
)

if exist "document-skills\xlsx" (
    echo Installing xlsx...
    xcopy "document-skills\xlsx" "%CLAUDE_SKILLS_DIR%\xlsx\" /E /I /Y /Q
    if !ERRORLEVEL! EQU 0 (
        echo    - xlsx installed successfully
        set /a SKILLS_INSTALLED+=1
    )
) else (
    echo    - WARNING: document-skills\xlsx not found
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Total skills installed: !SKILLS_INSTALLED!
echo Installation directory: %CLAUDE_SKILLS_DIR%
echo.
echo.
echo === VERIFYING INSTALLATION ===
echo.
echo Installed skills:
dir /b "%CLAUDE_SKILLS_DIR%" 2>nul
echo.
echo.
echo ========================================
echo NEXT STEPS
echo ========================================
echo.
echo 1. RESTART Claude Desktop if it's running
echo 2. Skills will be automatically available
echo 3. Try: "Use the DOCX skill to create a meeting agenda"
echo 4. Read SKILLS_USER_GUIDE.md for more examples
echo.
echo ========================================
echo.
echo Press any key to close this window...
pause >nul
echo.
echo Closing...
timeout /t 1 /nobreak >nul
