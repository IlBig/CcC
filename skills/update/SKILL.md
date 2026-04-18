---
name: update
description: Pull the latest CcC workflow skills and hooks from the upstream repo. Backs up the current versions under .claude/backup-<timestamp>/ so rollback is one copy away. Does NOT touch project artifacts (SPEC.md, AGENTS.md, RESEARCH.md, IMPLEMENTATION_NOTES.md, code, .claude/settings.json).
allowed-tools: Bash(git *) Bash(cp *) Bash(mv *) Bash(rm *) Bash(mkdir *) Bash(chmod *) Bash(mktemp *) Bash(date *) Bash(ls *) Bash(cat *) Bash(diff *) Bash(basename *) Read
---

# Update CcC workflow

## Current project state

```!
echo "Installed skills:"
ls .claude/skills/ 2>/dev/null || echo "(none)"
echo ""
echo "Hook files:"
ls hooks/ 2>/dev/null || echo "(no hooks/ dir)"
ls .git/hooks/pre-commit 2>/dev/null | sed 's|^|  |' || echo "  (no pre-commit installed)"
echo ""
echo "Upstream will be: ${CCC_REPO:-https://github.com/IlBig/CcC.git}"
```

## Run the update

```bash
set -euo pipefail

CCC_REPO="${CCC_REPO:-https://github.com/IlBig/CcC.git}"
TEMP=$(mktemp -d)
BACKUP=".claude/backup-$(date +%Y%m%d-%H%M%S)"

cleanup() { rm -rf "$TEMP"; }
trap cleanup EXIT

echo "→ Cloning $CCC_REPO ..."
if ! git clone --quiet --depth 1 "$CCC_REPO" "$TEMP/src" 2>&1; then
    echo "ERROR: git clone failed. Check network access and the CCC_REPO URL."
    exit 1
fi

if [ ! -d "$TEMP/src/skills" ] || [ ! -d "$TEMP/src/hooks" ]; then
    echo "ERROR: Remote does not look like a CcC workflow repo (missing skills/ or hooks/)."
    exit 1
fi

REMOTE_COMMIT=$(git -C "$TEMP/src" log -1 --oneline)
echo "→ Remote at: $REMOTE_COMMIT"

echo "→ Backing up current skills and hooks to $BACKUP ..."
mkdir -p "$BACKUP"
[ -d .claude/skills ] && cp -R .claude/skills "$BACKUP/skills"
mkdir -p "$BACKUP/hooks"
[ -f hooks/pre-compaction.sh ]  && cp hooks/pre-compaction.sh  "$BACKUP/hooks/pre-compaction.sh"
[ -f .git/hooks/pre-commit ]    && cp .git/hooks/pre-commit    "$BACKUP/hooks/pre-commit"

echo "→ Updating skills from upstream ..."
mkdir -p .claude/skills
for dir in "$TEMP/src/skills/"*/; do
    name=$(basename "$dir")
    mkdir -p ".claude/skills/$name"
    cp "$dir/SKILL.md" ".claude/skills/$name/SKILL.md"
done

echo "→ Updating hooks from upstream ..."
mkdir -p hooks
cp "$TEMP/src/hooks/pre-compaction.sh" hooks/pre-compaction.sh
chmod +x hooks/pre-compaction.sh

if [ -d .git/hooks ]; then
    cp "$TEMP/src/hooks/pre-commit-review.sh" .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
fi

echo ""
echo "→ Update complete."
echo ""
echo "Installed skills now:"
ls -1 .claude/skills/
echo ""
echo "Remote commit applied: $REMOTE_COMMIT"
echo "Backup saved at:       $BACKUP"
echo ""
echo "To inspect changes:  diff -r $BACKUP/skills .claude/skills"
echo "To roll back skills: rm -rf .claude/skills && cp -R $BACKUP/skills .claude/skills"
echo "To roll back hooks:  cp $BACKUP/hooks/pre-commit    .git/hooks/pre-commit"
echo "                     cp $BACKUP/hooks/pre-compaction.sh hooks/pre-compaction.sh"
```

## After the script

Converse with the user in the language specified in AGENTS.md. Briefly report:

1. **Which skills changed**: run `diff -rq "$BACKUP/skills" .claude/skills` (substituting the backup path printed above) and list added / modified / removed skill directories.
2. **Whether hooks changed**: if the hook diff is non-empty, flag it — hook changes can alter commit behavior.
3. **Reassure** the user that project artifacts (`SPEC.md`, `AGENTS.md`, `RESEARCH.md`, `IMPLEMENTATION_NOTES.md`, `.claude/settings.json`, any source code) were NOT touched.
4. **If any locally-customized skill was overwritten**, point at the backup path so the user can diff and reapply personal edits.

Do NOT auto-commit the updates — the user decides if and when to commit the refreshed files.
