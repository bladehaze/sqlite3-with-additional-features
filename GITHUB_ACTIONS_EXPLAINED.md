# GitHub Actions Explained

## Where Are They?

GitHub Actions workflows are YAML files located in:
```
.github/
└── workflows/
    ├── sync-upstream.yml          ← Syncs with upstream SQLite
    └── build-amalgamation.yml      ← Builds sqlite3.c
```

## What Are GitHub Actions?

GitHub Actions is GitHub's **automation platform**. When you push code to GitHub, these workflow files tell GitHub what to do automatically.

Think of it like:
- **Workflows** = Recipes (what to do)
- **Actions** = Ingredients (reusable steps)
- **Runners** = Kitchen (where it runs - GitHub's servers)

## The Two Workflows

### 1. `sync-upstream.yml` - Daily Sync

**What it does:**
- Runs every day at 2 AM UTC (or manually)
- Fetches latest code from SQLite upstream
- Merges upstream into your `main` branch
- Merges your `exclude-feature` branch into `main`
- Tests that everything compiles
- Pushes the updated `main` branch

**When it runs:**
- Daily at 2 AM UTC (automatic)
- When you click "Run workflow" (manual)
- When you push to `exclude-feature` branch

### 2. `build-amalgamation.yml` - Build sqlite3.c

**What it does:**
- Runs when you push code
- Merges `exclude-feature` into `main` (if needed)
- Generates `parse.c` from `parse.y` using lemon
- Creates `sqlite3.c` (the big single file)
- Creates `sqlite3.h` (header file)
- Tests that it compiles
- Commits `sqlite3.c` and `sqlite3.h` to your repository

**When it runs:**
- Every push to `main` or `exclude-feature`
- When you create a pull request
- When you click "Run workflow" (manual)

## How to See Them Work

### 1. Push to GitHub

```bash
# Push your code
git push origin exclude-feature
```

### 2. Go to GitHub Website

1. Open your repository on GitHub
2. Click the **"Actions"** tab (top menu)
3. You'll see workflows running!

### 3. Watch Them Run

- Yellow circle = Running
- Green checkmark = Success
- Red X = Failed

Click on a workflow to see detailed logs.

## Visual Flow

```
You push code
    ↓
GitHub sees the push
    ↓
GitHub reads .github/workflows/*.yml
    ↓
GitHub runs the workflow on their servers
    ↓
Workflow does its job (sync, build, etc.)
    ↓
Results appear in Actions tab
```

## Example: What Happens When You Push

```bash
# You do this:
git push origin exclude-feature

# GitHub automatically:
1. Sees the push
2. Reads build-amalgamation.yml
3. Starts a virtual machine (Ubuntu)
4. Checks out your code
5. Merges exclude-feature into main
6. Builds lemon parser
7. Generates parse.c
8. Generates sqlite3.c
9. Tests compilation
10. Commits sqlite3.c to main branch
11. Shows results in Actions tab
```

## Where to Find Them Locally

In your local repository:
```bash
ls -la .github/workflows/
```

You'll see:
- `sync-upstream.yml`
- `build-amalgamation.yml`

These are just text files (YAML format) that tell GitHub what to do.

## Where to See Them Work

On GitHub website:
1. Go to your repository
2. Click **"Actions"** tab
3. See all workflow runs

## Key Points

✅ **Workflows are files** in `.github/workflows/`  
✅ **They run automatically** when you push code  
✅ **You can see them** in the Actions tab on GitHub  
✅ **They run on GitHub's servers**, not your computer  
✅ **They're free** for public repositories  

## Testing Locally

You can't run GitHub Actions locally, but you can test the commands:

```bash
# Test the build process manually:
gcc -o lemon tool/lemon.c
./lemon -S src/parse.y
# ... etc
```

## Troubleshooting

**Q: I don't see workflows running?**
- Make sure you pushed the `.github/workflows/` directory
- Check the Actions tab on GitHub (not locally)

**Q: Workflow failed?**
- Click on the failed workflow
- Read the error messages
- Fix the issue and push again

**Q: Where are the logs?**
- Go to Actions tab on GitHub
- Click on a workflow run
- See detailed logs for each step

## Summary

- **Location**: `.github/workflows/*.yml` files
- **Purpose**: Automate syncing and building
- **View**: GitHub website → Actions tab
- **Trigger**: Automatic on push, or manual trigger

The workflows are already in your repository! Just push them to GitHub and they'll start working.
