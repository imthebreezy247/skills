@echo off
REM Installation script for Claude Desktop Skills
REM This copies all skills to Claude Desktop's skills directory

echo ========================================
echo Claude Desktop Skills Installer
echo ========================================
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

echo.
echo ========================================
echo Installing Example Skills
echo ========================================
echo.

REM Copy all example skills
for /d %%i in (algorithmic-art artifacts-builder brand-guidelines canvas-design internal-comms mcp-builder skill-creator slack-gif-creator template-skill theme-factory webapp-testing) do (
    if exist "%%i" (
        echo Installing %%i...
        xcopy "%%i" "%CLAUDE_SKILLS_DIR%\%%i\" /E /I /Y >nul
        echo    - %%i installed successfully
    )
)

echo.
echo ========================================
echo Installing Document Skills
echo ========================================
echo.

REM Copy all document skills
for /d %%i in (document-skills\docx document-skills\pdf document-skills\pptx document-skills\xlsx) do (
    if exist "%%i" (
        for %%j in (%%i) do set "skillname=%%~nxj"
        echo Installing !skillname!...
        xcopy "%%i" "%CLAUDE_SKILLS_DIR%\!skillname!\" /E /I /Y >nul
        echo    - !skillname! installed successfully
    )
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo All skills have been installed to:
echo %CLAUDE_SKILLS_DIR%
echo.
echo Next steps:
echo 1. Restart Claude Desktop if it's running
echo 2. Skills will be automatically available
echo 3. See SKILLS_USER_GUIDE.md for how to use them
echo.
pause
