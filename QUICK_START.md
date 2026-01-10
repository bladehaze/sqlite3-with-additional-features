# Quick Start Guide: Branch-Based GitHub Repository Setup

## Overview

This guide sets up a GitHub repository using a **branch-based approach** (no patch files):
- `exclude-feature` branch: Contains EXCLUDE feature changes
- `main` branch: Synced with upstream, then merged with feature branch
- GitHub Actions automatically handles syncing and building

## Step-by-Step Setup

### 1. Create GitHub Repository

1. Go to https://github.com/new
2. Create a new repository named `sqlite-with-exclude`
3. **Don't** initialize with README, .gitignore, or license

### 2. Clone SQLite and Create Feature Branch

```bash
# Clone SQLite repository
git clone https://github.com/sqlite/sqlite.git sqlite-with-exclude
cd sqlite-with-exclude

# Add upstream remote
git remote add upstream https://github.com/sqlite/sqlite.git

# Create feature branch from current state (if you have EXCLUDE changes)
git checkout -b exclude-feature

# If you need to add EXCLUDE changes, do it now:
# Edit src/parse.y, src/select.c, src/expr.c
# Then commit:
git add src/parse.y src/select.c src/expr.c
git commit -m "Add EXCLUDE feature: SELECT * EXCLUDE(column_list)"
```

### 3. Reset Main to Upstream

```bash
# Go to main and reset to upstream
git checkout main
git fetch upstream

# Find the upstream branch name
UPSTREAM_BRANCH=$(git ls-remote --heads upstream | grep -E 'refs/heads/(master|main)' | head -1 | cut -f2 | sed 's|refs/heads/||')
echo "Upstream branch: $UPSTREAM_BRANCH"

# Reset main to match upstream exactly
git reset --hard upstream/$UPSTREAM_BRANCH
```

### 4. Add GitHub Actions Workflows

```bash
# Create workflow directory
mkdir -p .github/workflows

# Copy the workflow files:
# - .github/workflows/sync-upstream.yml
# - .github/workflows/build-amalgamation.yml

# Add and commit workflows
git add .github/
git commit -m "Add GitHub Actions workflows for branch-based sync and build"
```

### 5. Add Documentation

```bash
# Copy README.md, .gitignore, and docs
git add README.md .gitignore *.md
git commit -m "Add documentation"
```

### 6. Push Both Branches

```bash
# Push feature branch first
git checkout exclude-feature
git push -u origin exclude-feature

# Push main (this will be the base)
git checkout main
git push -u origin main
```

### 7. Verify Setup

1. Go to your repository on GitHub
2. Check that both branches exist:
   - `main` - should match upstream SQLite
   - `exclude-feature` - should have EXCLUDE changes
3. Go to Actions tab
4. The "Build SQLite Amalgamation" workflow should run automatically
5. Wait for it to complete
6. Check that `sqlite3.c` and `sqlite3.h` are in the main branch

## Local Development Workflow

### Making Changes

```bash
# Always work on the feature branch
git checkout exclude-feature

# Make your changes
vim src/parse.y
# ... edit files ...

# Test locally
make clean
make
./sqlite3 :memory: "SELECT * EXCLUDE(email) FROM (SELECT 1 as id, 'test' as email);"

# Commit and push
git add -A
git commit -m "Your change description"
git push origin exclude-feature
```

### Syncing with Upstream (Manual)

The GitHub Actions will do this automatically, but you can also do it manually:

```bash
# 1. Update main from upstream
git checkout main
git fetch upstream
git merge upstream/master  # or upstream/main
git push origin main

# 2. Rebase feature branch onto updated main
git checkout exclude-feature
git rebase main

# 3. Resolve any conflicts
# ... edit conflicted files ...
git add <resolved-files>
git rebase --continue

# 4. Push updated feature branch
git push --force-with-lease origin exclude-feature
```

## What Happens Automatically

### Daily Sync (2 AM UTC)

1. Fetches latest from SQLite upstream
2. Merges into `main` branch
3. Merges `exclude-feature` into `main`
4. Tests the build
5. Pushes updated `main` branch

### Build on Push

Every time you push to `main` or `exclude-feature`:
1. Merges feature branch (if on main)
2. Generates `parse.c` from `parse.y`
3. Creates `sqlite3.c` amalgamation
4. Tests compilation
5. Commits `sqlite3.c` and `sqlite3.h` to main

## Testing the Feature

```bash
# Test on feature branch
git checkout exclude-feature
make clean
make
./sqlite3 :memory: <<EOF
CREATE TABLE employees(id INTEGER, name TEXT, email TEXT);
INSERT INTO employees VALUES(1, 'Alice', 'alice@example.com');
SELECT * EXCLUDE(email) FROM employees;
EOF

# Expected output:
# 1|Alice
```

## Branch Structure

```
main (synced with upstream)
  └── exclude-feature (your EXCLUDE changes)
       └── [GitHub Actions merges feature → main]
            └── sqlite3.c (generated)
```

## Troubleshooting

### Workflow Fails on Merge

If the sync workflow fails due to merge conflicts:

1. **Resolve locally**:
   ```bash
   git checkout exclude-feature
   git fetch origin main
   git rebase origin/main
   # Resolve conflicts
   git push --force-with-lease origin exclude-feature
   ```

2. **Re-run workflow** from GitHub Actions UI

### Feature Branch Not Found

If workflows can't find the feature branch:

```bash
# Make sure it exists and is pushed
git checkout exclude-feature
git push -u origin exclude-feature
```

### Main Branch Out of Sync

```bash
# Force update main from upstream
git checkout main
git fetch upstream
git reset --hard upstream/master
git push --force-with-lease origin main
```

## Files Structure

```
sqlite-with-exclude/
├── .github/
│   └── workflows/
│       ├── sync-upstream.yml      # Daily upstream sync + merge
│       └── build-amalgamation.yml  # Build on push
├── sqlite3.c                      # Generated (on main)
├── sqlite3.h                      # Generated (on main)
├── README.md                      # Project docs
├── BRANCH_BASED_WORKFLOW.md       # Detailed workflow guide
└── [SQLite source files...]
```

## Key Differences from Patch-Based

| Aspect | Patch-Based | Branch-Based |
|--------|-------------|--------------|
| Changes | In `.patch` file | In `exclude-feature` branch |
| Development | Edit patch file | Edit source files directly |
| Conflicts | Manual patch update | Git merge/rebase |
| History | No version control | Full git history |
| Testing | Apply patch, test | Work on branch, test |

## Next Steps

1. **Develop**: Work on `exclude-feature` branch
2. **Monitor**: Watch Actions tab for automatic syncs
3. **Test**: Download and test generated `sqlite3.c`
4. **Share**: Share your repository

## Support

- See `BRANCH_BASED_WORKFLOW.md` for detailed workflow guide
- Check GitHub Actions logs for errors
- Resolve conflicts on feature branch, then push
