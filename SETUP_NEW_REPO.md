# Setup Instructions for Your New GitHub Repo

Your new repo: `git@github.com:bladehaze/sqlite3-with-additional-features.git`

## Step-by-Step Setup

### Step 1: Change the remote to your new repo

```bash
# Remove current origin (points to SQLite upstream)
git remote remove origin

# Add your new repo as origin
git remote add origin git@github.com:bladehaze/sqlite3-with-additional-features.git

# Verify
git remote -v
```

### Step 2: Check current branch and create feature branch

```bash
# Check what branch you're on
git branch

# If you have EXCLUDE changes, create feature branch from current state
git checkout -b exclude-feature

# Verify EXCLUDE changes are there
grep -n "EXCLUDE" src/parse.y
```

### Step 3: Commit all the new files (workflows, docs, etc.)

```bash
# Add all new files
git add .github/ .gitignore *.md setup-branches.sh patches/

# Commit
git commit -m "Add GitHub Actions workflows and documentation for EXCLUDE feature"
```

### Step 4: Push feature branch

```bash
# Push feature branch
git push -u origin exclude-feature
```

### Step 5: Set up main branch

```bash
# Go to main branch
git checkout main

# If main doesn't have EXCLUDE changes, that's good - it should match upstream
# Fetch upstream to make sure we have latest
git fetch upstream

# Reset main to match upstream (removes any local EXCLUDE changes)
UPSTREAM_BRANCH=$(git ls-remote --heads upstream | grep -E 'refs/heads/(master|main)' | head -1 | cut -f2 | sed 's|refs/heads/||')
if [ -z "$UPSTREAM_BRANCH" ]; then
  UPSTREAM_BRANCH="master"
fi
echo "Upstream branch: $UPSTREAM_BRANCH"

# Reset main to upstream
git reset --hard upstream/$UPSTREAM_BRANCH

# Push main branch
git push -u origin main
```

### Step 6: Verify setup

```bash
# Check branches
git branch -a

# Verify feature branch has EXCLUDE
git checkout exclude-feature
grep -n "EXCLUDE" src/parse.y

# Verify main doesn't have EXCLUDE (should be clean)
git checkout main
grep -n "EXCLUDE" src/parse.y || echo "Good: main is clean"
```

### Step 7: Check GitHub Actions

1. Go to: https://github.com/bladehaze/sqlite3-with-additional-features
2. Click the **"Actions"** tab
3. You should see workflows running automatically!

## Quick Command Summary

```bash
# 1. Change remote
git remote remove origin
git remote add origin git@github.com:bladehaze/sqlite3-with-additional-features.git

# 2. Create feature branch (if not exists)
git checkout -b exclude-feature

# 3. Commit new files
git add .github/ .gitignore *.md setup-branches.sh patches/
git commit -m "Add GitHub Actions workflows and documentation"

# 4. Push feature branch
git push -u origin exclude-feature

# 5. Set up main
git checkout main
git fetch upstream
UPSTREAM_BRANCH=$(git ls-remote --heads upstream | grep -E 'refs/heads/(master|main)' | head -1 | cut -f2 | sed 's|refs/heads/||')
[ -z "$UPSTREAM_BRANCH" ] && UPSTREAM_BRANCH="master"
git reset --hard upstream/$UPSTREAM_BRANCH
git push -u origin main
```

## What Happens Next

1. **GitHub Actions will run automatically** when you push
2. The **build workflow** will generate `sqlite3.c` and commit it to main
3. The **sync workflow** will run daily to sync with upstream

## Troubleshooting

**If push fails:**
- Make sure you have SSH keys set up for GitHub
- Or use HTTPS: `git remote set-url origin https://github.com/bladehaze/sqlite3-with-additional-features.git`

**If workflows don't run:**
- Check that `.github/workflows/` directory was pushed
- Go to Actions tab and check for any errors
