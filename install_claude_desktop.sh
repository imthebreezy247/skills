#!/bin/bash
# Installation script for Claude Desktop Skills (Mac/Linux)
# This copies all skills to Claude Desktop's skills directory

echo "========================================"
echo "Claude Desktop Skills Installer"
echo "========================================"
echo ""

# Determine the Claude skills directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CLAUDE_SKILLS_DIR="$HOME/Library/Application Support/Claude/skills"
else
    # Linux
    CLAUDE_SKILLS_DIR="$HOME/.config/Claude/skills"
fi

echo "Checking Claude Desktop installation..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLAUDE_DIR="$HOME/Library/Application Support/Claude"
else
    CLAUDE_DIR="$HOME/.config/Claude"
fi

if [ ! -d "$CLAUDE_DIR" ]; then
    echo "ERROR: Claude Desktop not found!"
    echo "Please install Claude Desktop first from https://claude.ai/download"
    exit 1
fi

echo "Creating skills directory if it doesn't exist..."
if [ ! -d "$CLAUDE_SKILLS_DIR" ]; then
    mkdir -p "$CLAUDE_SKILLS_DIR"
    echo "Created skills directory: $CLAUDE_SKILLS_DIR"
else
    echo "Skills directory already exists: $CLAUDE_SKILLS_DIR"
fi

echo ""
echo "========================================"
echo "Installing Example Skills"
echo "========================================"
echo ""

# Copy all example skills
for skill in algorithmic-art artifacts-builder brand-guidelines canvas-design internal-comms mcp-builder skill-creator slack-gif-creator template-skill theme-factory webapp-testing; do
    if [ -d "$skill" ]; then
        echo "Installing $skill..."
        cp -r "$skill" "$CLAUDE_SKILLS_DIR/"
        echo "   - $skill installed successfully"
    fi
done

echo ""
echo "========================================"
echo "Installing Document Skills"
echo "========================================"
echo ""

# Copy all document skills
for skill in document-skills/*/; do
    if [ -d "$skill" ]; then
        skillname=$(basename "$skill")
        echo "Installing $skillname..."
        cp -r "$skill" "$CLAUDE_SKILLS_DIR/"
        echo "   - $skillname installed successfully"
    fi
done

echo ""
echo "========================================"
echo "Installation Complete!"
echo "========================================"
echo ""
echo "All skills have been installed to:"
echo "$CLAUDE_SKILLS_DIR"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop if it's running"
echo "2. Skills will be automatically available"
echo "3. See SKILLS_USER_GUIDE.md for how to use them"
echo ""
