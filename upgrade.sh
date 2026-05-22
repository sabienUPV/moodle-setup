#!/bin/sh -e

# Help flag
if [ "$1" = "--help" ]; then
  echo "Usage: $0 [NEW_BRANCH]"
  echo "Without arguments: Pulls latest security patches for the current branch."
  echo "With NEW_BRANCH (e.g., MOODLE_503_STABLE): Upgrades the codebase to a new major version."
  exit 0
fi

NEW_BRANCH="$1"

# Check if Moodle is initialized
if [ ! -d "html/.git" ]; then
  echo "Error: Moodle repository not found in html/. Run ./up.sh --init first."
  exit 1
fi

cd html

if [ -z "$NEW_BRANCH" ]; then
  echo "Fetching latest patches for the current branch..."
  git pull
  echo "Codebase updated successfully."
else
  echo "Upgrading to new major branch: $NEW_BRANCH..."
  
  # The magic trick: fetch ONLY the new branch with depth=1 to avoid downloading the entire history
  git remote set-branches origin "$NEW_BRANCH"
  git fetch --depth 1 origin "$NEW_BRANCH"
  git checkout "$NEW_BRANCH"
  
  echo "Successfully switched to $NEW_BRANCH."
  cd ..
  
  # Auto-patch up.sh to use the new branch for future initializations
  echo "Patching up.sh to track $NEW_BRANCH as the default..."
  sed -i -e "s/-b MOODLE_[a-zA-Z0-9_]* /-b $NEW_BRANCH /g" up.sh
  
  echo "up.sh updated successfully."
fi

# Remind the user of the crucial final Moodle step
echo "--------------------------------------------------------"
echo "⚠️ IMPORTANT: Moodle codebase has been updated."
echo "Now you MUST run the database upgrade script inside the container."
echo "Execute this command:"
echo "  docker compose exec moodle php admin/cli/upgrade.php --non-interactive"
echo "--------------------------------------------------------"