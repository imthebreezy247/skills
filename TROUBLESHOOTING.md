# Troubleshooting Guide

## Common Installation Issues

### Issue 1: "Document skills showing as !skillname!"

**This is now fixed!** The updated installer properly names document skills.

**If you still see this:**
- Re-download the latest `INSTALL_CLAUDE_DESKTOP.bat`
- Run it again
- The skills will be renamed correctly

---

### Issue 2: "Window closes immediately after pressing a key"

**This is now fixed!** The new installer:
- Shows you all installed skills before closing
- Uses `pause >nul` to wait for your keypress
- Gives you 1 second before closing so you can see the final message

**The window will now:**
1. Show "Press any key to close this window..."
2. Wait for your keypress
3. Show "Closing..."
4. Close after 1 second

---

### Issue 3: "Claude Desktop not found"

**Problem:** The installer can't find Claude Desktop

**Solutions:**
1. Make sure Claude Desktop is installed from https://claude.ai/download
2. Check if the installation directory exists:
   - Open File Explorer
   - Type in address bar: `%APPDATA%\Claude`
   - If it doesn't exist, Claude Desktop isn't installed

3. If Claude Desktop IS installed but in a different location:
   - Manually create the directory: `%APPDATA%\Claude\skills`
   - Copy all skill folders there manually

---

### Issue 4: "Skills installed but Claude isn't using them"

**Solutions:**

1. **Restart Claude Desktop completely**
   - Close Claude Desktop
   - Wait 5 seconds
   - Open Claude Desktop again

2. **Verify skills are in the right place**
   - Open File Explorer
   - Go to: `%APPDATA%\Claude\skills`
   - You should see 15 folders (one for each skill)

3. **Explicitly mention the skill**
   - Instead of: "Create a document"
   - Try: "Use the DOCX skill to create a document"

4. **Check skill structure**
   - Each skill folder should contain a `SKILL.md` file
   - Example: `%APPDATA%\Claude\skills\docx\SKILL.md` should exist

---

### Issue 5: "Some skills are missing"

**Check which skills installed:**

1. Open Command Prompt
2. Run: `dir /b "%APPDATA%\Claude\skills"`
3. You should see all 15 skills:
   - algorithmic-art
   - artifacts-builder
   - brand-guidelines
   - canvas-design
   - docx
   - internal-comms
   - mcp-builder
   - pdf
   - pptx
   - skill-creator
   - slack-gif-creator
   - template-skill
   - theme-factory
   - webapp-testing
   - xlsx

**If any are missing:**
- Re-run the installer
- Or manually copy the missing skill folder to `%APPDATA%\Claude\skills`

---

### Issue 6: "Permission denied" error

**Problem:** Installer can't write to the skills directory

**Solutions:**

1. **Run as Administrator**
   - Right-click `INSTALL_CLAUDE_DESKTOP.bat`
   - Click "Run as administrator"

2. **Check folder permissions**
   - Make sure your user account can write to `%APPDATA%\Claude`

---

### Issue 7: "xcopy failed" or file copying errors

**Solutions:**

1. **Close Claude Desktop first**
   - Make sure Claude Desktop isn't running
   - The installer can't overwrite files that are in use

2. **Check disk space**
   - Make sure you have at least 50MB free space

3. **Run from the correct directory**
   - The installer must be run from the skills repository folder
   - Make sure you can see all skill folders in the same directory

---

### Issue 8: "How do I know if it worked?"

**Verification steps:**

1. **Check the installer output**
   - You should see "installed successfully" for each skill
   - At the end, you'll see a list of all installed skills

2. **Check the directory**
   ```cmd
   dir /b "%APPDATA%\Claude\skills"
   ```
   Should show 15 folders

3. **Test a skill**
   - Open Claude Desktop
   - Ask: "Use the DOCX skill to create a simple document with today's date"
   - If it creates an actual .docx file, it's working!

---

### Issue 9: "Can I uninstall a skill?"

**Yes!** Just delete its folder:

1. Open File Explorer
2. Go to: `%APPDATA%\Claude\skills`
3. Delete the folder of the skill you don't want
4. Restart Claude Desktop

---

### Issue 10: "Can I install just some skills, not all?"

**Yes!** Manually copy just the ones you want:

1. Open File Explorer to the skills repository
2. Select the skill folders you want
3. Copy them to: `%APPDATA%\Claude\skills`
4. Restart Claude Desktop

**Example - Install only document skills:**
```cmd
xcopy "document-skills\docx" "%APPDATA%\Claude\skills\docx\" /E /I /Y
xcopy "document-skills\pdf" "%APPDATA%\Claude\skills\pdf\" /E /I /Y
xcopy "document-skills\pptx" "%APPDATA%\Claude\skills\pptx\" /E /I /Y
xcopy "document-skills\xlsx" "%APPDATA%\Claude\skills\xlsx\" /E /I /Y
```

---

### Issue 11: "Skills work in Claude.ai but not Claude Desktop"

**This is expected!** Skills in Claude.ai and Claude Desktop are separate:

- **Claude.ai**: Skills are already included for paid plans
- **Claude Desktop**: You need to install skills manually (that's what this installer does)

After installing, skills should work in Claude Desktop.

---

### Issue 12: "Error: The system cannot find the path specified"

**Problem:** Running installer from wrong location or paths are incorrect

**Solutions:**

1. **Make sure you're in the skills repository folder**
   - You should see folders like `algorithmic-art`, `document-skills`, etc.
   - The installer must be in the same folder as these

2. **Check your current directory**
   ```cmd
   cd
   ```
   Should show the skills repository path

3. **Navigate to correct folder first**
   ```cmd
   cd D:\Coding-Projects\skills
   INSTALL_CLAUDE_DESKTOP.bat
   ```

---

### Issue 13: "How do I update skills?"

**Just run the installer again!**

The installer uses `/Y` flag with xcopy, which overwrites existing files.

1. Pull latest updates from the repository
2. Run `INSTALL_CLAUDE_DESKTOP.bat` again
3. Restart Claude Desktop

---

## Still Having Issues?

### Manual Installation Steps:

1. **Create the skills directory**
   ```cmd
   mkdir "%APPDATA%\Claude\skills"
   ```

2. **Copy each skill manually**
   - Navigate to the skills repository in File Explorer
   - Copy each skill folder
   - Paste into `%APPDATA%\Claude\skills`

3. **Verify each skill has SKILL.md**
   - Each folder should contain a `SKILL.md` file
   - Example: `%APPDATA%\Claude\skills\docx\SKILL.md`

4. **Restart Claude Desktop**

---

## Getting Help

1. **Check the guides**
   - [QUICK_START.md](QUICK_START.md)
   - [SKILLS_USER_GUIDE.md](SKILLS_USER_GUIDE.md)
   - [INSTALLATION_SUMMARY.md](INSTALLATION_SUMMARY.md)

2. **Official documentation**
   - https://support.claude.com/en/articles/12512176-what-are-skills

3. **Verify installation**
   - Make sure you see 15 folders in `%APPDATA%\Claude\skills`
   - Each should have a `SKILL.md` file

---

## Quick Diagnostics

Run these commands to diagnose issues:

```cmd
REM Check if Claude Desktop is installed
dir "%APPDATA%\Claude"

REM Check if skills directory exists
dir "%APPDATA%\Claude\skills"

REM List all installed skills
dir /b "%APPDATA%\Claude\skills"

REM Check a specific skill
dir "%APPDATA%\Claude\skills\docx"

REM Verify SKILL.md exists
type "%APPDATA%\Claude\skills\docx\SKILL.md" | more
```

---

## Success Indicators

You'll know it's working when:

✅ Installer shows "installed successfully" for all 15 skills
✅ `%APPDATA%\Claude\skills` contains 15 folders
✅ Each folder contains a `SKILL.md` file
✅ Claude Desktop creates actual files (not just suggestions)
✅ You can say "Use the DOCX skill" and Claude knows what you mean

---

## Pro Tips

1. **Always restart Claude Desktop after installation**
2. **Explicitly mention the skill name when first testing**
3. **Check the installed skills list in the installer output**
4. **Keep the skills repository for easy updates**
5. **Create custom skills by copying template-skill**

---

**Most issues are fixed by:**
1. Re-running the installer
2. Restarting Claude Desktop
3. Explicitly mentioning the skill name
