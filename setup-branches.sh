#!/bin/bash
# Setup script to create branch-based structure from current state

set -e

FEATURE_BRANCH="exclude-feature"
UPSTREAM_REMOTE="upstream"
UPSTREAM_URL="https://github.com/sqlite/sqlite.git"

echo "=== SQLite EXCLUDE Feature - Branch Setup ==="
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Check if feature branch already exists
if git show-ref --verify --quiet refs/heads/$FEATURE_BRANCH; then
    echo "Warning: Feature branch '$FEATURE_BRANCH' already exists"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "Current branch: $CURRENT_BRANCH"
echo ""

# Step 1: Create feature branch from current state
echo "Step 1: Creating feature branch '$FEATURE_BRANCH' from current state..."
if ! git show-ref --verify --quiet refs/heads/$FEATURE_BRANCH; then
    git checkout -b $FEATURE_BRANCH
    echo "✓ Feature branch created"
else
    git checkout $FEATURE_BRANCH
    echo "✓ Switched to existing feature branch"
fi
echo ""

# Step 2: Add upstream remote if not exists
echo "Step 2: Setting up upstream remote..."
if git remote | grep -q "^${UPSTREAM_REMOTE}$"; then
    echo "✓ Upstream remote already exists"
else
    git remote add $UPSTREAM_REMOTE $UPSTREAM_URL
    echo "✓ Upstream remote added"
fi
echo ""

# Step 3: Fetch upstream
echo "Step 3: Fetching from upstream..."
git fetch $UPSTREAM_REMOTE
echo "✓ Upstream fetched"
echo ""

# Step 4: Determine upstream branch
echo "Step 4: Finding upstream branch..."
UPSTREAM_BRANCH=$(git ls-remote --heads $UPSTREAM_REMOTE | grep -E 'refs/heads/(master|main|version-[0-9])' | head -1 | cut -f2 | sed 's|refs/heads/||')
if [ -z "$UPSTREAM_BRANCH" ]; then
    UPSTREAM_BRANCH="master"
fi
echo "Upstream branch: $UPSTREAM_BRANCH"
echo ""

# Step 5: Reset main to upstream
echo "Step 5: Resetting main branch to match upstream..."
if git show-ref --verify --quiet refs/heads/main; then
    git checkout main
    echo "Warning: main branch exists. This will reset it to match upstream."
    read -p "Continue? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping main branch reset"
    else
        git reset --hard $UPSTREAM_REMOTE/$UPSTREAM_BRANCH
        echo "✓ Main branch reset to upstream"
    fi
else
    # Create main from upstream
    git checkout -b main $UPSTREAM_REMOTE/$UPSTREAM_BRANCH
    echo "✓ Main branch created from upstream"
fi
echo ""

# Step 6: Verify feature branch has EXCLUDE changes
echo "Step 6: Verifying feature branch has EXCLUDE changes..."
git checkout $FEATURE_BRANCH
if grep -q "EXCLUDE" src/parse.y 2>/dev/null; then
    echo "✓ EXCLUDE feature found in parse.y"
else
    echo "⚠ Warning: EXCLUDE not found in parse.y"
    echo "  Make sure you've committed your EXCLUDE changes to the feature branch"
fi
echo ""

# Step 7: Summary
echo "=== Setup Complete ==="
echo ""
echo "Branch structure:"
echo "  main            - Synced with upstream SQLite"
echo "  $FEATURE_BRANCH  - Contains EXCLUDE feature changes"
echo ""
echo "Next steps:"
echo "  1. Push both branches:"
echo "     git push -u origin $FEATURE_BRANCH"
echo "     git push -u origin main"
echo ""
echo "  2. Add GitHub Actions workflows to .github/workflows/"
echo ""
echo "  3. Verify workflows run successfully on GitHub"
echo ""
echo "Current branch: $(git branch --show-current)"
echo ""
