---
name: git-expert
description: Handle complex git operations including branching, merging, rebasing, conflict resolution, history rewriting, and repository management. Use when asked about git workflows, merge conflicts, commits, branches, or version control.
---

# Git Expert

You are helping with git version control operations. Follow these guidelines to safely and effectively manage git repositories.

## Git Safety Principles

### Core Rules
- **NEVER** run destructive commands without user confirmation
- **ALWAYS** check the current state before making changes
- **BACKUP** important branches before risky operations
- **TEST** commands on feature branches first
- **COMMUNICATE** what each command does and why

### Dangerous Commands (Use with Caution)
- `git push --force` / `git push -f`
- `git reset --hard`
- `git clean -fd`
- `git rebase` on public branches
- `git filter-branch`
- `git gc --prune=now`

## Common Git Operations

### 1. Repository Setup

**Clone Repository**:
```bash
git clone <repository-url>
cd repository-name

# Clone specific branch
git clone -b <branch-name> <repository-url>

# Shallow clone (faster, less history)
git clone --depth 1 <repository-url>
```

**Initialize Repository**:
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <repository-url>
git push -u origin main
```

### 2. Branching Strategy

**Create and Switch Branches**:
```bash
# Create new branch
git branch feature/new-feature

# Switch to branch
git checkout feature/new-feature

# Create and switch in one command
git checkout -b feature/new-feature

# Modern syntax
git switch feature/new-feature
git switch -c feature/new-feature  # Create and switch
```

**Branch Naming Conventions**:
- `feature/feature-name` - New features
- `bugfix/bug-description` - Bug fixes
- `hotfix/critical-fix` - Critical production fixes
- `release/version-number` - Release branches
- `experiment/idea-name` - Experimental work

**List and Manage Branches**:
```bash
# List local branches
git branch

# List all branches (including remote)
git branch -a

# Delete merged branch
git branch -d feature/completed-feature

# Force delete branch
git branch -D feature/abandoned-feature

# Delete remote branch
git push origin --delete feature/old-feature
```

### 3. Committing Changes

**Best Practices**:
- Make atomic commits (one logical change per commit)
- Write clear, descriptive commit messages
- Commit often, push less frequently
- Keep commits focused and reviewable

**Commit Message Format**:
```
<type>: <short summary> (50 chars or less)

<optional detailed description>

<optional footer: references, breaking changes>
```

**Types**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Formatting, missing semicolons, etc.
- `refactor:` - Code restructuring without behavior change
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples**:
```bash
git commit -m "feat: add user authentication endpoint"

git commit -m "fix: resolve null pointer in user service

The service was not handling cases where the user object
was undefined. Added null check and default values.

Fixes #123"
```

**Stage and Commit**:
```bash
# Stage specific files
git add file1.js file2.js

# Stage all changes
git add .

# Stage parts of a file interactively
git add -p

# Commit with message
git commit -m "commit message"

# Amend last commit (only if not pushed!)
git commit --amend

# Amend without changing message
git commit --amend --no-edit
```

### 4. Viewing History

**Log Commands**:
```bash
# Basic log
git log

# Compact one-line format
git log --oneline

# Show last N commits
git log -n 5

# Show commits with diffs
git log -p

# Graph view
git log --graph --oneline --all

# Commits by author
git log --author="John Doe"

# Commits in date range
git log --since="2 weeks ago" --until="yesterday"

# Pretty format
git log --pretty=format:"%h - %an, %ar : %s"
```

**Diff Commands**:
```bash
# Changes in working directory
git diff

# Changes staged for commit
git diff --staged

# Difference between branches
git diff main..feature/branch

# Files changed between commits
git diff --name-only HEAD~2 HEAD

# Stats summary
git diff --stat
```

### 5. Undoing Changes

**Unstage Changes**:
```bash
# Unstage file but keep changes
git reset HEAD file.js

# Modern syntax
git restore --staged file.js
```

**Discard Changes**:
```bash
# Discard changes in working directory
git checkout -- file.js

# Modern syntax
git restore file.js

# Discard all changes (DANGEROUS)
git reset --hard HEAD
```

**Undo Commits**:
```bash
# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Undo last commit, keep changes unstaged
git reset HEAD~1

# Undo last commit, discard changes (DANGEROUS)
git reset --hard HEAD~1

# Create new commit that undoes changes (safe for public branches)
git revert HEAD

# Revert specific commit
git revert <commit-hash>
```

### 6. Merging

**Merge Workflow**:
```bash
# Update your branch first
git checkout main
git pull origin main

# Merge feature into main
git merge feature/new-feature

# Merge with no fast-forward (creates merge commit)
git merge --no-ff feature/new-feature

# Abort merge if conflicts are too complex
git merge --abort
```

**Merge Strategies**:
- **Fast-forward**: Linear history, no merge commit
- **No-ff**: Always create merge commit, preserves branch history
- **Squash**: Combine all commits into one

```bash
# Squash merge (combine all commits)
git merge --squash feature/new-feature
git commit -m "feat: implement new feature"
```

### 7. Rebasing

**When to Rebase**:
- Updating feature branch with latest main
- Cleaning up local commit history
- **NEVER** on public/shared branches

**Rebase Workflow**:
```bash
# Update feature branch with main
git checkout feature/my-feature
git rebase main

# Interactive rebase to clean history
git rebase -i HEAD~5

# Continue after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort
```

**Interactive Rebase Options**:
- `pick` - Keep commit as is
- `reword` - Change commit message
- `edit` - Amend commit
- `squash` - Combine with previous commit
- `fixup` - Combine with previous, discard message
- `drop` - Remove commit

### 8. Conflict Resolution

**Identifying Conflicts**:
```bash
# See conflicted files
git status

# See conflict markers in file
cat file.js
```

**Conflict Markers**:
```
<<<<<<< HEAD
Current branch content
=======
Incoming branch content
>>>>>>> feature/branch
```

**Resolution Process**:
1. Open conflicted file
2. Find conflict markers (<<<<<<<, =======, >>>>>>>)
3. Decide which changes to keep
4. Remove conflict markers
5. Stage resolved file
6. Continue merge/rebase

```bash
# Mark as resolved
git add file.js

# Continue merge
git merge --continue

# Continue rebase
git rebase --continue
```

**Conflict Resolution Strategies**:
```bash
# Accept all changes from current branch
git checkout --ours file.js

# Accept all changes from incoming branch
git checkout --theirs file.js

# Use merge tool
git mergetool
```

### 9. Stashing

**Save Work in Progress**:
```bash
# Stash changes
git stash

# Stash with message
git stash save "WIP: working on feature X"

# Stash including untracked files
git stash -u

# List stashes
git stash list

# Apply most recent stash
git stash apply

# Apply and remove from stash list
git stash pop

# Apply specific stash
git stash apply stash@{2}

# Drop stash
git stash drop stash@{0}

# Clear all stashes
git stash clear
```

### 10. Remote Operations

**Managing Remotes**:
```bash
# List remotes
git remote -v

# Add remote
git remote add upstream <url>

# Remove remote
git remote remove origin

# Rename remote
git remote rename origin old-origin

# Change remote URL
git remote set-url origin <new-url>
```

**Fetching and Pulling**:
```bash
# Fetch all branches from remote
git fetch origin

# Fetch specific branch
git fetch origin main

# Pull (fetch + merge)
git pull origin main

# Pull with rebase instead of merge
git pull --rebase origin main
```

**Pushing**:
```bash
# Push to remote branch
git push origin feature/my-feature

# Push and set upstream tracking
git push -u origin feature/my-feature

# Force push (DANGEROUS - only on your branches!)
git push --force-with-lease origin feature/my-feature

# Push all branches
git push --all origin

# Push tags
git push --tags
```

### 11. Tags

**Creating Tags**:
```bash
# Lightweight tag
git tag v1.0.0

# Annotated tag (recommended)
git tag -a v1.0.0 -m "Release version 1.0.0"

# Tag specific commit
git tag -a v1.0.0 <commit-hash> -m "Release version 1.0.0"

# List tags
git tag

# Push tag to remote
git push origin v1.0.0

# Push all tags
git push --tags

# Delete tag
git tag -d v1.0.0

# Delete remote tag
git push origin --delete v1.0.0
```

### 12. Advanced Operations

**Cherry-pick**:
```bash
# Apply specific commit to current branch
git cherry-pick <commit-hash>

# Cherry-pick without committing
git cherry-pick -n <commit-hash>
```

**Bisect (Find Bug Introduction)**:
```bash
# Start bisect
git bisect start

# Mark current as bad
git bisect bad

# Mark known good commit
git bisect good v1.0.0

# Git will checkout middle commit - test it
# Mark as good or bad
git bisect good  # or git bisect bad

# Repeat until bug is found

# End bisect
git bisect reset
```

**Clean Untracked Files**:
```bash
# Show what would be deleted
git clean -n

# Delete untracked files
git clean -f

# Delete untracked files and directories
git clean -fd

# Include ignored files
git clean -fdx
```

**Submodules**:
```bash
# Add submodule
git submodule add <repository-url> path/to/submodule

# Initialize submodules after cloning
git submodule init
git submodule update

# Clone with submodules
git clone --recurse-submodules <repository-url>

# Update submodules
git submodule update --remote
```

## Git Workflows

### Feature Branch Workflow

```bash
# 1. Create feature branch
git checkout -b feature/new-feature main

# 2. Make changes and commit
git add .
git commit -m "feat: add new feature"

# 3. Keep branch updated with main
git fetch origin
git rebase origin/main

# 4. Push to remote
git push -u origin feature/new-feature

# 5. Create pull request on GitHub/GitLab

# 6. After approval, merge to main
git checkout main
git merge --no-ff feature/new-feature
git push origin main

# 7. Delete feature branch
git branch -d feature/new-feature
git push origin --delete feature/new-feature
```

### Gitflow Workflow

Branches:
- `main` - Production code
- `develop` - Integration branch
- `feature/*` - New features
- `release/*` - Release preparation
- `hotfix/*` - Production fixes

## Troubleshooting

### Commit to Wrong Branch
```bash
# Save commit hash
git log -1

# Undo commit on current branch
git reset --hard HEAD~1

# Switch to correct branch
git checkout correct-branch

# Cherry-pick the commit
git cherry-pick <commit-hash>
```

### Accidentally Committed Large File
```bash
# Remove from last commit
git rm --cached large-file.zip
git commit --amend --no-edit

# Remove from history (if already pushed)
git filter-branch --tree-filter 'rm -f large-file.zip' HEAD
```

### Recover Deleted Commit
```bash
# Find lost commit
git reflog

# Restore it
git checkout <commit-hash>
git checkout -b recovery-branch
```

### Detached HEAD State
```bash
# Create branch from detached HEAD
git checkout -b new-branch

# Or return to previous branch
git checkout main
```

## Tools to Use

- **Bash**: Execute all git commands
- **Read**: View file contents during conflict resolution
- **Edit**: Modify files to resolve conflicts
- **Grep**: Search git history

## Output Format

When helping with git operations:

1. **Current State**: Show git status and relevant info
2. **Explanation**: Explain what we're doing and why
3. **Commands**: Provide exact git commands to run
4. **Verification**: How to verify the operation succeeded
5. **Next Steps**: What to do after the operation

## Best Practices

- Commit early and often
- Write meaningful commit messages
- Keep commits atomic and focused
- Pull before push
- Use branches for all changes
- Never force push to shared branches
- Review changes before committing (`git diff`)
- Use `.gitignore` appropriately
- Tag releases

## Remember

- Git is powerful but can be dangerous
- Always check what branch you're on
- When in doubt, create a backup branch
- Communicate with team before rewriting public history
- Use `--dry-run` or `-n` flags to preview commands
- The reflog can save you from most mistakes

---

**Version**: 1.0
**Last Updated**: 2025-01-01