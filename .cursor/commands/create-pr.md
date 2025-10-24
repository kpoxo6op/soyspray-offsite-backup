# Create PR

## Overview

Create a well-structured pull request with proper description

## Steps

1. **Clean up commits**
    - Run: `git diff origin/main..HEAD` to see all changes
    - Analyze changes and group into logical commits
    - Run: `git reset --soft origin/main` (keeps all changes staged)
    - Run: `git reset` (unstage everything)
    - Stage and commit changes in logical groups:
      - Use `git add <files>` for each logical group
      - Use `git commit -m "clear message example"` for each group
      - Repeat until all changes are committed
    - Verify: `git diff origin/main` should show nothing
    - Check for untracked files: `git status` and add test documentation if present
    - Force push: `git push --force-with-lease`
2. **Prepare branch**
    - Ensure all changes are committed
    - Push branch to remote (if not done in step 2)
    - Verify branch is up to date with main
3. **Set up PR**
    - Summarize changes clearly
    - Check if the branch already has a PR open, if so, update the PR instead of creating a new one.
    - Create PR with descriptive title and description. Use gh CLI as priority. Never use emojis, deter from using bulletpoints, use coherent sentences, keep the line lengh under 80 chars. Use bulletpoints as the last resort.
