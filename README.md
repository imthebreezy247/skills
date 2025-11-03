# Claude Skills Collection

## What Are Agent Skills?

**Agent Skills** are modular capabilities that extend Claude Code's functionality. They package expertise into discoverable, reusable components that Claude autonomously activates when relevant to your request.

### Key Characteristics

- **Model-Invoked**: Claude decides when to use skills based on your request and the skill's description
- **Modular**: Each skill focuses on a specific capability or domain
- **Discoverable**: Claude can list available skills when asked
- **Reusable**: Write once, use across multiple projects or share with your team

## How Skills Work

### Activation
Skills activate automatically when Claude determines they're relevant to your request. You don't need to explicitly invoke them—Claude reads the skill's description and activates it when appropriate.

**Example:**
- You ask: "Review this code for potential issues"
- Claude sees the `code-review` skill with description "Perform code reviews..."
- Claude automatically activates the skill and follows its instructions

### File Structure

Each skill is a directory containing:
```
skill-name/
├── SKILL.md (required)
└── supporting files (optional)
```

The `SKILL.md` file includes:
1. **YAML Frontmatter**: Metadata about the skill
2. **Instructions**: Detailed guidance for Claude to follow

### YAML Frontmatter Requirements

```yaml
---
name: skill-name
description: Clear description of what the skill does and when to use it
---
```

- **name**: Lowercase letters, numbers, hyphens only (max 64 chars)
- **description**: Explains the skill's purpose (max 1024 chars)

## Types of Skills

### Personal Skills (`~/.claude/skills/`)
- Available across all your projects
- Stored in your home directory
- Great for individual workflows and experiments

### Project Skills (`.claude/skills/`)
- Shared with your team
- Checked into git
- Automatically available to all team members
- **This folder is for project skills**

### Plugin Skills
- Bundled with Claude Code plugins
- Work identically to personal and project skills

## Using Skills

### Discover Available Skills
Ask Claude: "What skills are available?"

### Let Claude Choose
Simply describe what you want:
- "Review my code"
- "Write tests for this function"
- "Help me debug this issue"

Claude will automatically activate relevant skills.

## Skills in This Collection

### 1. **code-review**
Performs comprehensive code reviews checking for bugs, security issues, performance problems, and best practices.

### 2. **test-writer**
Generates unit tests, integration tests, and test suites with high coverage and best practices.

### 3. **documentation**
Creates clear, comprehensive documentation including README files, API docs, and inline comments.

### 4. **debugging**
Systematically diagnoses and fixes bugs using advanced debugging techniques.

### 5. **git-expert**
Handles complex git operations, conflict resolution, and repository management.

### 6. **api-developer**
Designs and implements RESTful and GraphQL APIs following best practices.

### 7. **refactoring**
Improves code structure, readability, and maintainability without changing behavior.

### 8. **security-audit**
Analyzes code for security vulnerabilities and implements security best practices.

### 9. **performance-optimizer**
Identifies and resolves performance bottlenecks, optimizes algorithms and database queries.

### 10. **database-expert**
Designs schemas, writes optimized queries, and manages database migrations.

## Best Practices for Creating Skills

### 1. Keep Focused
Each skill should address **one** capability, not multiple unrelated tasks.

**Good:** "Generate unit tests for JavaScript functions"
**Bad:** "Help with testing, documentation, and code review"

### 2. Write Specific Descriptions
Include concrete triggers and keywords users would mention.

**Good:** "Analyze code for security vulnerabilities including SQL injection, XSS, CSRF. Use when asked to 'audit', 'check security', or 'find vulnerabilities'."
**Bad:** "Helps with security"

### 3. Provide Clear Instructions
The skill instructions should be detailed and actionable, like giving instructions to a colleague.

### 4. Use allowed-tools (Optional)
Restrict which tools Claude can use within the skill for security or read-only workflows:

```yaml
---
name: my-skill
description: Description here
allowed-tools: [Read, Grep, Glob]
---
```

### 5. Test Thoroughly
- Test with various phrasings and contexts
- Verify the skill activates when expected
- Ensure instructions are clear and complete

### 6. Document Versions
Keep a version history in your SKILL.md to track changes.

## How to Add These Skills to Your Project

### Option 1: Project Skills (Recommended for Teams)
```bash
# Copy this folder to your project
cp -r Claude-Skills/* your-project/.claude/skills/

# Commit to git
git add .claude/skills/
git commit -m "Add Claude skills"
```

### Option 2: Personal Skills
```bash
# Copy to your home directory
mkdir -p ~/.claude/skills/
cp -r Claude-Skills/* ~/.claude/skills/
```

## Troubleshooting

### Skill Not Activating?
- Check the description includes relevant keywords
- Verify the YAML frontmatter is valid
- Make sure the name uses only lowercase letters, numbers, and hyphens
- Ask Claude "What skills are available?" to confirm it's loaded

### Skill Activating Too Often?
- Make the description more specific
- Use more targeted keywords
- Consider splitting into multiple focused skills

### Syntax Errors?
- Validate YAML frontmatter syntax
- Ensure proper markdown formatting
- Check for special characters in name field

## Examples of Using These Skills

### Code Review
```
You: "Can you review the authentication module?"
Claude: [Activates code-review skill, analyzes code for security, bugs, performance]
```

### Writing Tests
```
You: "I need tests for the user service"
Claude: [Activates test-writer skill, generates comprehensive test suite]
```

### Debugging
```
You: "This function is crashing with edge cases"
Claude: [Activates debugging skill, systematically identifies and fixes issues]
```

### API Development
```
You: "Help me build a REST API for user management"
Claude: [Activates api-developer skill, designs endpoints, implements with best practices]
```

## Additional Resources

- [Claude Code Skills Documentation](https://docs.claude.com/en/docs/claude-code/skills.md)
- [Claude Code Documentation Map](https://docs.claude.com/en/docs/claude-code/claude_code_docs_map.md)

## Contributing

Feel free to:
- Add new skills for your specific needs
- Improve existing skill instructions
- Share skills with your team via git
- Customize descriptions to match your workflow

---

**Remember**: Skills are powerful because Claude decides when to use them. Write clear descriptions and focused instructions, and Claude will invoke them at the right time!