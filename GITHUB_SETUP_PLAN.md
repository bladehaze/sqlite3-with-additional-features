# GitHub Repository Setup Plan for SQLite with EXCLUDE Feature

## Overview
Set up a GitHub repository that automatically:
1. Syncs with upstream SQLite repository
2. Applies the EXCLUDE feature patch
3. Regenerates the amalgamation (sqlite3.c)
4. Publishes the modified SQLite with EXCLUDE support

## Repository Structure

```
sqlite-with-exclude/
├── .github/
│   └── workflows/
│       ├── sync-upstream.yml      # Auto-sync with upstream
│       └── build-amalgamation.yml  # Build and publish
├── patches/
│   └── exclude-feature.patch      # The EXCLUDE feature patch
├── sqlite3.c                      # Generated amalgamation
├── sqlite3.h                      # Generated header
├── README.md                      # Documentation
└── .gitignore                     # Ignore build artifacts
```

## Workflow Strategy

### Workflow 1: Sync Upstream (Daily/Weekly)
- Triggers: Scheduled (daily) or manual
- Steps:
  1. Fetch latest from upstream SQLite
  2. Merge/rebase into main branch
  3. Apply patch (if not already applied)
  4. Test build
  5. Commit if successful

### Workflow 2: Build Amalgamation (On Push/PR)
- Triggers: Push to main, PRs
- Steps:
  1. Checkout code
  2. Apply patch (if needed)
  3. Build lemon parser
  4. Generate parse.c from parse.y
  5. Run `make target_source` to prepare tsrc/
  6. Run `mksqlite3c.tcl` to generate sqlite3.c
  7. Generate sqlite3.h
  8. Test compilation
  9. Create release artifact or commit sqlite3.c

## Implementation Plan

### Phase 1: Initial Setup
1. Fork/clone SQLite repository
2. Create patches/ directory with patch file
3. Set up GitHub Actions workflows
4. Configure upstream remote

### Phase 2: Automation
1. Create sync workflow to pull from upstream
2. Create build workflow to generate amalgamation
3. Set up release automation (optional)

### Phase 3: Testing
1. Test patch application
2. Test amalgamation generation
3. Test compilation
4. Verify EXCLUDE feature works

## GitHub Actions Requirements

### Secrets/Config Needed:
- None required (all public repos)

### Tools Needed:
- Tcl (for mksqlite3c.tcl)
- C compiler (gcc/clang)
- make
- lemon (SQLite's parser generator)

### Dependencies:
- SQLite source code
- Patch file
- Build tools

## Branch Strategy

- `main` - Synced with upstream + patch applied
- `upstream` - Tracking upstream SQLite (read-only reference)
- `patched` - Main branch with patch (default branch)

## Release Strategy

Options:
1. **Auto-commit sqlite3.c** - Commit generated files to repo
2. **GitHub Releases** - Create releases with sqlite3.c as artifact
3. **Both** - Commit to repo + create releases

Recommended: Both - commit for easy access, releases for versioning
