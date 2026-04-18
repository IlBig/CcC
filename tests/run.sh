#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
TMP_ROOT=$(mktemp -d)

cleanup() {
    rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

pass() {
    printf 'PASS %s\n' "$1"
}

fail() {
    printf 'FAIL %s\n' "$1" >&2
    exit 1
}

assert_contains() {
    local haystack=$1
    local needle=$2
    local message=$3

    if [[ "$haystack" != *"$needle"* ]]; then
        fail "$message"
    fi
}

assert_file_contains() {
    local file=$1
    local needle=$2
    local message=$3

    grep -qF "$needle" "$file" || fail "$message"
}

assert_not_exists_in_commit() {
    local repo=$1
    local path=$2
    local message=$3

    if git -C "$repo" ls-tree --name-only -r HEAD | grep -qxF "$path"; then
        fail "$message"
    fi
}

make_repo() {
    local repo=$1

    mkdir -p "$repo"
    git -C "$repo" init -q
    git -C "$repo" config user.name "Test User"
    git -C "$repo" config user.email "test@example.com"
    cp "$ROOT_DIR/hooks/pre-commit-review.sh" "$repo/.git/hooks/pre-commit"
    chmod +x "$repo/.git/hooks/pre-commit"
    printf 'REVIEW.md\n.claude/auto-memory/\n.claude/sessions/\n' > "$repo/.gitignore"
    git -C "$repo" add .gitignore
    git -C "$repo" commit -q --no-verify -m "chore: init"
}

make_fake_codex_bin() {
    local bin_dir=$1
    local script_body=$2

    mkdir -p "$bin_dir"
    cat > "$bin_dir/codex" <<EOF
#!/usr/bin/env bash
$script_body
EOF
    chmod +x "$bin_dir/codex"
}

test_pre_commit_blocks_failed_codex() {
    local repo="$TMP_ROOT/hook-fail"
    local bin_dir="$TMP_ROOT/bin-fail"
    local output

    make_repo "$repo"

    make_fake_codex_bin "$bin_dir" 'exit 42'

    printf 'VERDICT: PASS\n' > "$repo/REVIEW.md"
    printf 'content\n' > "$repo/file.txt"
    git -C "$repo" add file.txt

    set +e
    output=$(PATH="$bin_dir:$PATH" git -C "$repo" commit -m "test failure" 2>&1)
    local status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        fail "pre-commit should block when Codex exits non-zero"
    fi

    assert_contains "$output" "Codex review process failed" "pre-commit did not report Codex failure"
    pass "pre-commit blocks failed Codex runs"
}

test_pre_commit_restages_codex_fixes() {
    local repo="$TMP_ROOT/hook-restage"
    local bin_dir="$TMP_ROOT/bin-restage"

    make_repo "$repo"

    make_fake_codex_bin "$bin_dir" '
outfile=""
prev=""
for arg in "$@"; do
    if [ "$prev" = "-o" ]; then
        outfile="$arg"
    fi
    prev="$arg"
done
printf "fixed\n" >> file.txt
printf "new test\n" > new_test.txt
printf "VERDICT: PASS\n" > "$outfile"
'

    printf 'VERDICT: FAIL - stale\n' > "$repo/REVIEW.md"
    printf 'original\n' > "$repo/file.txt"
    git -C "$repo" add file.txt

    PATH="$bin_dir:$PATH" git -C "$repo" commit -q -m "test pass"

    assert_file_contains "$repo/file.txt" "fixed" "Codex fix was not applied to working tree"
    assert_file_contains "$repo/REVIEW.md" "VERDICT: PASS" "Fresh review output did not replace stale review"
    git -C "$repo" show --name-only --format=oneline HEAD | grep -qxF "new_test.txt" || fail "Codex-created file was not included in commit"
    assert_not_exists_in_commit "$repo" "REVIEW.md" "REVIEW.md should not be committed by the hook"
    pass "pre-commit restages Codex fixes and keeps REVIEW.md out of the commit"
}

test_pre_commit_blocks_dirty_worktree() {
    local repo="$TMP_ROOT/hook-dirty"
    local bin_dir="$TMP_ROOT/bin-dirty"
    local output

    make_repo "$repo"

    make_fake_codex_bin "$bin_dir" '
outfile=""
prev=""
for arg in "$@"; do
    if [ "$prev" = "-o" ]; then
        outfile="$arg"
    fi
    prev="$arg"
done
printf "VERDICT: PASS\n" > "$outfile"
'

    printf 'tracked\n' > "$repo/tracked.txt"
    git -C "$repo" add tracked.txt
    git -C "$repo" commit -q --no-verify -m "seed"

    printf 'staged\n' > "$repo/staged.txt"
    git -C "$repo" add staged.txt
    printf 'dirty\n' > "$repo/tracked.txt"

    set +e
    output=$(PATH="$bin_dir:$PATH" git -C "$repo" commit -m "dirty worktree" 2>&1)
    local status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        fail "pre-commit should block with unstaged tracked changes"
    fi

    assert_contains "$output" "Unstaged tracked changes detected" "pre-commit did not detect a dirty worktree"
    pass "pre-commit blocks dirty worktrees"
}

test_pre_commit_allows_ignored_claude_sessions() {
    local repo="$TMP_ROOT/hook-ignored-sessions"
    local bin_dir="$TMP_ROOT/bin-ignored-sessions"

    make_repo "$repo"

    make_fake_codex_bin "$bin_dir" '
outfile=""
prev=""
for arg in "$@"; do
    if [ "$prev" = "-o" ]; then
        outfile="$arg"
    fi
    prev="$arg"
done
printf "VERDICT: PASS\n" > "$outfile"
'

    mkdir -p "$repo/.claude/sessions"
    printf '{"session":"runtime"}\n' > "$repo/.claude/sessions/session.jsonl"
    printf 'content\n' > "$repo/file.txt"
    git -C "$repo" add file.txt

    PATH="$bin_dir:$PATH" git -C "$repo" commit -q -m "ignored session files"
    git -C "$repo" rev-parse --verify HEAD >/dev/null || fail "commit should succeed with ignored Claude session files present"
    assert_not_exists_in_commit "$repo" ".claude/sessions/session.jsonl" "ignored Claude session files should not be committed"
    pass "pre-commit ignores Claude session runtime files when they are gitignored"
}

test_pre_compaction_prompt_uses_continue() {
    local repo="$TMP_ROOT/precompact"
    local output

    mkdir -p "$repo"
    printf '# Notes\n' > "$repo/IMPLEMENTATION_NOTES.md"
    output=$(cd "$repo" && "$ROOT_DIR/hooks/pre-compaction.sh")

    assert_contains "$output" '"hookEventName": "PreCompact"' "PreCompact hook did not output hook metadata"
    assert_contains "$output" '/continue' "PreCompact hook still references the legacy /resume command"
    pass "pre-compaction emits the /continue reminder"
}

make_source_snapshot_repo() {
    local source_repo=$1

    mkdir -p "$source_repo"
    (
        cd "$ROOT_DIR"
        tar --exclude=.git -cf - .
    ) | (
        cd "$source_repo"
        tar -xf -
    )

    git -C "$source_repo" init -q
    git -C "$source_repo" config user.name "Snapshot User"
    git -C "$source_repo" config user.email "snapshot@example.com"
    git -C "$source_repo" add -A
    git -C "$source_repo" commit -q --no-verify -m "snapshot"
}

test_ccc_handles_missing_git_identity() {
    local sandbox="$TMP_ROOT/ccc"
    local bin_dir="$sandbox/bin"
    local home_dir="$sandbox/home"
    local source_repo="$sandbox/source"
    local output

    make_source_snapshot_repo "$source_repo"
    mkdir -p "$bin_dir" "$home_dir"

    cat > "$bin_dir/npm" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$bin_dir/claude" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
    cat > "$bin_dir/codex" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = "login" ]; then
    exit 0
fi
exit 0
EOF
    chmod +x "$bin_dir/npm" "$bin_dir/claude" "$bin_dir/codex"

    mkdir -p "$sandbox/work"
    set +e
    output=$(
        cd "$sandbox/work" && \
        HOME="$home_dir" GIT_CONFIG_NOSYSTEM=1 PATH="$bin_dir:$PATH" CCC_REPO="$source_repo" "$ROOT_DIR/ccc" Demo 2>&1
    )
    local status=$?
    set -e

    if [ "$status" -ne 0 ]; then
        fail "ccc should succeed even when git identity is missing"
    fi

    assert_contains "$output" "initial commit will be skipped" "ccc did not warn about missing git identity"
    [ -d "$sandbox/work/Demo/.git" ] || fail "ccc did not create the target repository"
    [ -f "$sandbox/work/Demo/AGENTS.md" ] || fail "ccc did not create AGENTS.md"
    assert_file_contains "$sandbox/work/Demo/.gitignore" "REVIEW.md" "Generated .gitignore is missing REVIEW.md"
    assert_file_contains "$sandbox/work/Demo/.gitignore" ".claude/auto-memory/" "Generated .gitignore is missing .claude/auto-memory/"
    assert_file_contains "$sandbox/work/Demo/.gitignore" ".claude/sessions/" "Generated .gitignore is missing .claude/sessions/"
    if git -C "$sandbox/work/Demo" rev-parse --verify HEAD >/dev/null 2>&1; then
        fail "ccc should skip the initial commit when git identity is missing"
    fi
    pass "ccc creates the project and skips the initial commit without git identity"
}

test_skill_tool_whitelists() {
    assert_file_contains "$ROOT_DIR/skills/continue/SKILL.md" "Bash(cat *)" "/continue is missing Bash(cat *) in allowed-tools"
    assert_file_contains "$ROOT_DIR/skills/notes/SKILL.md" "Bash(cat *)" "/notes is missing Bash(cat *) in allowed-tools"
    assert_file_contains "$ROOT_DIR/skills/review/SKILL.md" 'git diff "@{upstream}..HEAD"' "/review no longer includes upstream diff coverage"
    assert_file_contains "$ROOT_DIR/skills/review/SKILL.md" "git diff HEAD" "/review no longer includes worktree diff coverage"
    assert_file_contains "$ROOT_DIR/skills/update/SKILL.md" "Bash(git *)" "/update is missing Bash(git *) in allowed-tools"
    pass "skills expose the shell commands they use"
}

test_update_skill_contract() {
    local skill="$ROOT_DIR/skills/update/SKILL.md"
    assert_file_contains "$skill" "CCC_REPO" "/update must use CCC_REPO env variable"
    assert_file_contains "$skill" ".claude/backup-" "/update must back up before overwriting"
    assert_file_contains "$skill" "SPEC.md" "/update must document that SPEC.md is NOT touched"
    assert_file_contains "$skill" "AGENTS.md" "/update must document that AGENTS.md is NOT touched"
    pass "/update skill honors the safety contract"
}

test_ccc_installs_update_skill() {
    local sandbox="$TMP_ROOT/ccc-update"
    local bin_dir="$sandbox/bin"
    local home_dir="$sandbox/home"
    local source_repo="$sandbox/source"

    make_source_snapshot_repo "$source_repo"
    mkdir -p "$bin_dir" "$home_dir" "$sandbox/work"

    for bin in npm claude codex; do
        cat > "$bin_dir/$bin" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
        chmod +x "$bin_dir/$bin"
    done

    set +e
    (
        cd "$sandbox/work" && \
        HOME="$home_dir" GIT_CONFIG_NOSYSTEM=1 PATH="$bin_dir:$PATH" \
            CCC_REPO="$source_repo" CCC_LANG=en "$ROOT_DIR/ccc" UpdateProj >/dev/null 2>&1
    )
    set -e

    [ -f "$sandbox/work/UpdateProj/.claude/skills/update/SKILL.md" ] \
        || fail "ccc did not install the /update skill"
    assert_file_contains "$sandbox/work/UpdateProj/.claude/skills/update/SKILL.md" \
        "CCC_REPO" "installed /update skill is missing the CCC_REPO reference"
    pass "ccc bootstraps the /update skill"
}

test_pre_commit_allows_warn_verdict() {
    local repo="$TMP_ROOT/hook-warn"
    local bin_dir="$TMP_ROOT/bin-warn"

    make_repo "$repo"

    make_fake_codex_bin "$bin_dir" '
outfile=""
prev=""
for arg in "$@"; do
    if [ "$prev" = "-o" ]; then
        outfile="$arg"
    fi
    prev="$arg"
done
printf "VERDICT: WARN - minor cosmetic issue\n" > "$outfile"
'

    printf 'content\n' > "$repo/file.txt"
    git -C "$repo" add file.txt

    PATH="$bin_dir:$PATH" git -C "$repo" commit -q -m "warn verdict"
    assert_file_contains "$repo/REVIEW.md" "VERDICT: WARN" "REVIEW.md missing WARN verdict"
    git -C "$repo" rev-parse --verify HEAD >/dev/null || fail "commit should succeed on WARN verdict"
    pass "pre-commit allows WARN verdict"
}

test_pre_commit_blocks_oversized_diff() {
    local repo="$TMP_ROOT/hook-big"
    local bin_dir="$TMP_ROOT/bin-big"
    local output

    make_repo "$repo"
    make_fake_codex_bin "$bin_dir" 'printf "VERDICT: PASS\n" > "${@: -1}"'

    # Generate a diff much larger than MAX_DIFF_LINES (50 lines here)
    local i=0
    : > "$repo/big.txt"
    while [ "$i" -lt 200 ]; do
        printf 'line %s\n' "$i" >> "$repo/big.txt"
        i=$((i + 1))
    done
    git -C "$repo" add big.txt

    set +e
    output=$(MAX_DIFF_LINES=50 PATH="$bin_dir:$PATH" git -C "$repo" commit -m "oversized" 2>&1)
    local status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        fail "pre-commit should block when diff exceeds MAX_DIFF_LINES"
    fi
    assert_contains "$output" "Diff too large" "pre-commit did not report oversized diff"
    pass "pre-commit blocks oversized diffs"
}

test_pre_commit_blocks_malformed_verdict() {
    local repo="$TMP_ROOT/hook-bad-verdict"
    local bin_dir="$TMP_ROOT/bin-bad-verdict"
    local output

    make_repo "$repo"
    make_fake_codex_bin "$bin_dir" '
outfile=""
prev=""
for arg in "$@"; do
    if [ "$prev" = "-o" ]; then
        outfile="$arg"
    fi
    prev="$arg"
done
printf "VERDICT: okay\n" > "$outfile"
'

    printf 'content\n' > "$repo/file.txt"
    git -C "$repo" add file.txt

    set +e
    output=$(PATH="$bin_dir:$PATH" git -C "$repo" commit -m "bad verdict" 2>&1)
    local status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        fail "pre-commit should block when verdict is unrecognized"
    fi
    assert_contains "$output" "Unrecognized verdict" "pre-commit did not reject malformed verdict"
    pass "pre-commit blocks malformed verdict lines"
}

test_pre_commit_blocks_missing_review_file() {
    local repo="$TMP_ROOT/hook-no-review"
    local bin_dir="$TMP_ROOT/bin-no-review"
    local output

    make_repo "$repo"
    # Codex exits 0 but writes nothing to the output file
    make_fake_codex_bin "$bin_dir" 'exit 0'

    printf 'content\n' > "$repo/file.txt"
    git -C "$repo" add file.txt

    set +e
    output=$(PATH="$bin_dir:$PATH" git -C "$repo" commit -m "no review" 2>&1)
    local status=$?
    set -e

    if [ "$status" -eq 0 ]; then
        fail "pre-commit should block when Codex leaves no review file"
    fi
    assert_contains "$output" "did not produce" "pre-commit did not report missing review file"
    pass "pre-commit blocks when Codex produces no review"
}

test_pre_commit_blocks_failed_codex
test_pre_commit_restages_codex_fixes
test_pre_commit_blocks_dirty_worktree
test_pre_commit_allows_ignored_claude_sessions
test_pre_commit_allows_warn_verdict
test_pre_commit_blocks_oversized_diff
test_pre_commit_blocks_malformed_verdict
test_pre_commit_blocks_missing_review_file
test_pre_compaction_prompt_uses_continue
test_ccc_handles_missing_git_identity
test_ccc_installs_update_skill
test_skill_tool_whitelists
test_update_skill_contract

printf 'All tests passed.\n'
