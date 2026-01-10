# Setup Instructions for SQLite with EXCLUDE Feature

## Step 1: Create GitHub Repository

1. Go to GitHub and create a new repository (e.g., `sqlite-with-exclude`)
2. Initialize it:
   ```bash
   git clone https://github.com/sqlite/sqlite.git sqlite-with-exclude
   cd sqlite-with-exclude
   ```

## Step 2: Apply Initial Patch

1. Copy the patch file to `patches/exclude-feature.patch`
2. Apply the patch:
   ```bash
   git apply patches/exclude-feature.patch
   git add -A
   git commit -m "Add EXCLUDE feature: SELECT * EXCLUDE(column_list)"
   ```

## Step 3: Set Up GitHub Actions

1. Create `.github/workflows/` directory:
   ```bash
   mkdir -p .github/workflows
   ```

2. Copy the workflow files:
   - `.github/workflows/sync-upstream.yml`
   - `.github/workflows/build-amalgamation.yml`

3. Commit and push:
   ```bash
   git add .github/
   git commit -m "Add GitHub Actions workflows"
   git push origin main
   ```

## Step 4: Configure Upstream Remote

The workflows will automatically add the upstream remote, but you can also do it manually:

```bash
git remote add upstream https://github.com/sqlite/sqlite.git
git fetch upstream
```

## Step 5: Initial Build

1. Push to trigger the build workflow
2. Or manually trigger: Go to Actions → "Build SQLite Amalgamation" → Run workflow

## Step 6: Verify

1. Check Actions tab for successful runs
2. Verify `sqlite3.c` is generated
3. Download and test:
   ```bash
   gcc -o sqlite3 sqlite3.c -ldl -lpthread
   ./sqlite3 :memory: "SELECT * EXCLUDE(email) FROM (SELECT 1 as id, 'test' as email);"
   ```

## Workflow Behavior

### Sync Workflow
- **Triggers**: Daily at 2 AM UTC, manual, or on push
- **Actions**:
  - Fetches latest from upstream SQLite
  - Merges/rebase into main
  - Applies patch
  - Tests build
  - Commits if successful

### Build Workflow  
- **Triggers**: Push to main, PRs, manual
- **Actions**:
  - Applies patch
  - Generates parse.c from parse.y
  - Creates tsrc/ directory
  - Generates sqlite3.c amalgamation
  - Tests compilation
  - Commits sqlite3.c to repo
  - Creates artifacts

## Manual Commands

If you need to build manually:

```bash
# Install dependencies
sudo apt-get install tcl tcl-dev build-essential

# Build lemon
gcc -o lemon tool/lemon.c

# Generate parser
./lemon -DSQLITE_ENABLE_MATH_FUNCTIONS -DSQLITE_ENABLE_PERCENTILE \
        -DSQLITE_HAVE_ZLIB=1 -DSQLITE_THREADSAFE=1 -S src/parse.y

# Prepare source
make target_source  # or manually create tsrc/

# Generate amalgamation
tclsh tool/mksqlite3c.tcl --linemacros=0

# Generate header
tclsh tool/mksqlite3h.tcl . -o sqlite3.h
```

## Troubleshooting

### Patch conflicts after upstream sync
- Check the sync workflow logs
- Manually resolve conflicts if needed
- Update patch file if upstream changed significantly

### Amalgamation generation fails
- Check that all source files are in tsrc/
- Verify parse.c was generated
- Check Tcl script paths

### Compilation errors
- Verify EXCLUDE token is in parse.y
- Check that patch was applied correctly
- Review workflow logs for details
