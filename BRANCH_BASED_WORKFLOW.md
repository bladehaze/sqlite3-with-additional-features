# Branch-Based Workflow Guide

## Overview

Instead of using patch files, this repository uses a **branch-based approach** where:
- `main` branch: Synced with upstream SQLite, then merged with feature branch
- `exclude-feature` branch: Contains all EXCLUDE feature changes
- GitHub Actions automatically merges the feature branch into main after syncing with upstream

## Benefits

✅ **Easy local development**: Work directly on the feature branch  
✅ **Better conflict resolution**: Git handles merges natively  
✅ **Version control**: Full history of feature development  
✅ **Collaboration**: Multiple developers can work on the feature branch  
✅ **Testing**: Test feature branch independently before merging  

## Repository Structure

```
sqlite-with-exclude/
├── main                    # Synced with upstream + merged feature
├── exclude-feature         # EXCLUDE feature development branch
└── .github/workflows/
    ├── sync-upstream.yml   # Syncs upstream, then merges feature branch
    └── build-amalgamation.yml  # Builds from main (which includes feature)
```

## Initial Setup

### 1. Create Feature Branch from Current State

If you already have the EXCLUDE changes committed:

```bash
# Make sure you're on main with EXCLUDE changes
git checkout main

# Create feature branch from current state
git checkout -b exclude-feature

# Push feature branch
git push -u origin exclude-feature
```

### 2. Reset Main to Upstream

```bash
# Go back to main
git checkout main

# Reset to upstream (removes local EXCLUDE changes)
git fetch upstream
git reset --hard upstream/master  # or upstream/main

# Push (force update)
git push --force-with-lease origin main
```

### 3. Verify Setup

```bash
# Check branches
git branch -a

# Verify feature branch has EXCLUDE changes
git checkout exclude-feature
grep -n "EXCLUDE" src/parse.y

# Verify main doesn't have EXCLUDE changes
git checkout main
grep -n "EXCLUDE" src/parse.y || echo "Good: main is clean"
```

## Local Development Workflow

### Making Changes to EXCLUDE Feature

```bash
# Always work on the feature branch
git checkout exclude-feature

# Make your changes
vim src/parse.y
vim src/select.c
# ... etc

# Test locally
make clean
make

# Commit changes
git add -A
git commit -m "Improve EXCLUDE feature: ..."

# Push to remote
git push origin exclude-feature
```

### Syncing with Upstream (Manual)

```bash
# 1. Update main with upstream
git checkout main
git fetch upstream
git merge upstream/master  # or upstream/main
git push origin main

# 2. Rebase feature branch onto updated main
git checkout exclude-feature
git rebase main

# 3. Resolve conflicts if any
# ... edit conflicted files ...
git add <resolved-files>
git rebase --continue

# 4. Push updated feature branch
git push --force-with-lease origin exclude-feature
```

## How GitHub Actions Works

### Sync Workflow

1. **Fetches upstream**: Gets latest SQLite changes
2. **Updates main**: Merges upstream into main
3. **Merges feature branch**: Merges `exclude-feature` into `main`
4. **Tests build**: Verifies everything compiles
5. **Pushes main**: Updates main branch with merged changes

### Build Workflow

1. **Checks out code**: Gets latest main (which includes feature)
2. **Builds amalgamation**: Generates sqlite3.c
3. **Tests compilation**: Verifies it compiles
4. **Commits artifacts**: Commits sqlite3.c and sqlite3.h to main

## Conflict Resolution

### When Sync Workflow Fails

If the automatic sync fails due to conflicts:

1. **Check the workflow logs** to see what conflicted
2. **Resolve locally**:
   ```bash
   # Update main
   git checkout main
   git fetch upstream
   git merge upstream/master
   
   # Rebase feature branch
   git checkout exclude-feature
   git rebase main
   
   # Resolve conflicts
   # ... edit files ...
   git add <resolved-files>
   git rebase --continue
   
   # Push
   git push --force-with-lease origin exclude-feature
   ```
3. **Re-run the workflow** from GitHub Actions UI

### Common Conflict Scenarios

#### Scenario 1: Upstream Changed parse.y

```bash
# After rebase, you'll see conflicts in parse.y
git checkout exclude-feature
git rebase main

# Edit src/parse.y to resolve conflicts
# Keep your EXCLUDE grammar rules
# Keep upstream's other changes

git add src/parse.y
git rebase --continue
```

#### Scenario 2: Upstream Changed select.c

```bash
# Similar process for select.c
# Keep your EXCLUDE logic in selectExpander
# Keep upstream's other improvements

git add src/select.c
git rebase --continue
```

## Best Practices

### 1. Keep Feature Branch Clean

- Make focused commits
- Write clear commit messages
- Test before pushing

### 2. Regular Rebase

- Rebase feature branch onto main regularly
- Don't let conflicts accumulate
- Test after each rebase

### 3. Use Feature Branch for All EXCLUDE Work

- Never commit EXCLUDE changes directly to main
- Always work on exclude-feature branch
- Let GitHub Actions merge to main

### 4. Monitor Workflows

- Check Actions tab regularly
- Fix issues promptly
- Review generated sqlite3.c

## Branch Comparison

```bash
# See what's different between branches
git diff main..exclude-feature

# See commits in feature branch not in main
git log main..exclude-feature

# See file changes
git diff main..exclude-feature --stat
```

## Testing Locally

### Test Feature Branch

```bash
git checkout exclude-feature
make clean
make
./sqlite3 :memory: "SELECT * EXCLUDE(email) FROM (SELECT 1 as id, 'test' as email);"
```

### Test Main (After Merge)

```bash
git checkout main
make clean
make
./sqlite3 :memory: "SELECT * EXCLUDE(email) FROM (SELECT 1 as id, 'test' as email);"
```

## Migration from Patch-Based

If you were using patches before:

```bash
# 1. Apply patch to create feature branch
git checkout -b exclude-feature
git apply patches/exclude-feature.patch
git add -A
git commit -m "Add EXCLUDE feature"

# 2. Reset main to upstream
git checkout main
git fetch upstream
git reset --hard upstream/master

# 3. Push both branches
git push -u origin exclude-feature
git push --force-with-lease origin main

# 4. Patches directory is no longer needed (optional)
# rm -rf patches/
```

## Troubleshooting

### Feature Branch Not Found

If workflows complain about missing feature branch:

```bash
# Create and push it
git checkout -b exclude-feature
# ... make sure it has EXCLUDE changes ...
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

### Feature Branch Diverged

```bash
# Reset feature branch to match local state
git checkout exclude-feature
git reset --hard HEAD  # or specific commit
git push --force-with-lease origin exclude-feature
```

## Summary

- **Work on**: `exclude-feature` branch
- **Auto-synced**: `main` branch (by GitHub Actions)
- **Development**: Local on feature branch
- **Deployment**: Automatic via workflows
- **Conflicts**: Resolve on feature branch, then push
