# GitHub Actions Setup Plan

## Overview

This document outlines the plan for setting up a GitHub repository with automated workflows to:
1. Sync with upstream SQLite
2. Apply the EXCLUDE feature patch
3. Generate the SQLite amalgamation (sqlite3.c)
4. Publish the results

## Repository Structure

```
sqlite-with-exclude/
├── .github/
│   └── workflows/
│       ├── sync-upstream.yml      # Auto-sync with upstream SQLite
│       └── build-amalgamation.yml  # Build and publish amalgamation
├── patches/
│   └── exclude-feature.patch      # The EXCLUDE feature patch
├── sqlite3.c                    # Generated amalgamation (committed)
├── sqlite3.h                    # Generated header (committed)
├── README.md                    # Project documentation
└── .gitignore                   # Ignore build artifacts
```

## Workflow 1: Sync Upstream

**File**: `.github/workflows/sync-upstream.yml`

**Purpose**: Automatically sync with upstream SQLite repository

**Triggers**:
- Scheduled: Daily at 2 AM UTC
- Manual: Via workflow_dispatch
- Push: When code is pushed to main

**Steps**:
1. Checkout repository with full history
2. Add upstream remote (https://github.com/sqlite/sqlite.git)
3. Fetch latest from upstream
4. Merge/rebase upstream changes into main branch
5. Apply EXCLUDE patch
6. Test build (quick compile check)
7. Commit and push if successful
8. Create GitHub issue if sync fails (for manual intervention)

**Key Features**:
- Handles merge conflicts gracefully
- Tests patch application
- Creates issues on failure for visibility

## Workflow 2: Build Amalgamation

**File**: `.github/workflows/build-amalgamation.yml`

**Purpose**: Generate sqlite3.c and sqlite3.h from source

**Triggers**:
- Push to main/master
- Pull requests
- Manual: Via workflow_dispatch
- Path filters: Only runs when src/, patches/, or workflow files change

**Steps**:
1. Checkout code
2. Install dependencies (Tcl, build tools)
3. Apply EXCLUDE patch (if needed)
4. Build lemon parser generator
5. Generate parse.c and parse.h from parse.y
6. Generate keyword hash
7. Prepare source directory (tsrc/)
8. Generate sqlite3.h
9. Generate sqlite3.c using mksqlite3c.tcl
10. Verify amalgamation (size check, EXCLUDE feature check)
11. Test compilation
12. Upload artifacts
13. Commit sqlite3.c and sqlite3.h to repository (on main branch)
14. Create GitHub release (if triggered by tag)

**Key Features**:
- Verifies EXCLUDE feature is present in generated code
- Tests compilation to catch errors early
- Creates downloadable artifacts
- Auto-commits generated files for easy access

## Setup Steps

### 1. Create GitHub Repository

```bash
# On GitHub, create a new repository: sqlite-with-exclude
# Then locally:
git clone https://github.com/sqlite/sqlite.git sqlite-with-exclude
cd sqlite-with-exclude
```

### 2. Apply Initial Patch

```bash
mkdir -p patches
# Copy exclude-feature.patch to patches/
git apply patches/exclude-feature.patch
git add -A
git commit -m "Add EXCLUDE feature: SELECT * EXCLUDE(column_list)"
```

### 3. Add GitHub Actions

```bash
mkdir -p .github/workflows
# Copy workflow files
git add .github/
git commit -m "Add GitHub Actions workflows"
```

### 4. Push to GitHub

```bash
git remote set-url origin https://github.com/YOUR_USERNAME/sqlite-with-exclude.git
git push -u origin main
```

### 5. Configure Upstream (Optional)

The workflows will automatically add upstream, but you can also do it manually:

```bash
git remote add upstream https://github.com/sqlite/sqlite.git
git fetch upstream
```

## Workflow Behavior

### Sync Workflow Behavior

- **Daily Sync**: Runs every day at 2 AM UTC
- **Conflict Handling**: 
  - First tries merge
  - Falls back to rebase if merge fails
  - Creates issue if both fail
- **Patch Application**:
  - Checks if patch is already applied
  - Applies if needed
  - Fails workflow if patch conflicts

### Build Workflow Behavior

- **Automatic Builds**: Runs on every push to main
- **Artifact Storage**: Keeps artifacts for 90 days
- **Auto-commit**: Commits sqlite3.c and sqlite3.h to main branch
- **Release Support**: Creates releases when tags are pushed

## Maintenance

### Updating the Patch

If upstream changes require patch updates:

1. Manually resolve conflicts in your local repo
2. Generate new patch:
   ```bash
   git diff upstream/main HEAD -- src/parse.y src/select.c src/expr.c > patches/exclude-feature.patch
   ```
3. Commit and push updated patch

### Manual Sync

If automatic sync fails:

1. Check the GitHub issue created by the workflow
2. Manually sync:
   ```bash
   git fetch upstream
   git merge upstream/main
   # Resolve conflicts
   git apply patches/exclude-feature.patch
   git commit -m "Manual sync with upstream"
   git push
   ```

## Benefits

1. **Automated**: No manual intervention needed for regular updates
2. **Tested**: Every sync and build is tested
3. **Transparent**: Issues created on failures
4. **Accessible**: Generated files committed to repo
5. **Versioned**: Releases can be created from tags

## Troubleshooting

### Patch Conflicts

- Check sync workflow logs
- Manually resolve and update patch file
- Consider if upstream changes require patch modifications

### Build Failures

- Check that all dependencies are installed
- Verify Tcl scripts are in correct locations
- Check parse.c generation succeeded

### Compilation Errors

- Verify EXCLUDE token is in parse.y
- Check patch was applied correctly
- Review workflow logs for specific errors
