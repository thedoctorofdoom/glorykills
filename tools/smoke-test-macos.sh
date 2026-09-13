#!/usr/bin/env bash
#
# Headless compile smoke-test for the GloryKills addon against Project Brutality
# on macOS. Local development aid only -- not shipped content.
#
# Two passes:
#   1. compile probe  -- catches ZScript/DECORATE compile errors
#   2. MAP01 load     -- catches runtime VM aborts during actor spawning
#
# Override any path with an environment variable, e.g.
#   PB_DIR=/some/other/PB_Staging ./tools/smoke-test-macos.sh
#
set -uo pipefail

UZDOOM="${UZDOOM:-/Applications/uzdoom.app/Contents/MacOS/uzdoom}"
IWAD="${IWAD:-$HOME/Personal Dev/DOOM2.WAD}"
PB_DIR="${PB_DIR:-$HOME/Personal Dev/PB_Staging}"
SRC_DIR="${SRC_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
STAGE="${STAGE:-${TMPDIR:-/tmp}/GK_smoketest}"

for required in "$UZDOOM" "$IWAD" "$PB_DIR"; do
    if [[ ! -e "$required" ]]; then
        echo "FATAL: missing required path: $required" >&2
        exit 2
    fi
done

# Never point the engine at the repo root. These entries must not be ingested:
# VCS/agent metadata, the sibling PB checkout, gitignored audit notes, scratch
# design docs, source-only assets, and the stale packaged release.
EXCLUDES=(
    ".git" ".gitignore" ".gitattributes" ".cursor"
    "docs" "PB_Staging" "tools"
    "AGENTS.md" "README.md"
    "execution_sound_investigation.md"
    "CRUCIBLE_SWING_HANDOFF.md"
    "GloryKill-0.4.1A.pk3"
    "*.psd"
)

rsync_args=(-a --delete)
for pattern in "${EXCLUDES[@]}"; do
    rsync_args+=(--exclude "$pattern")
done

echo "=== staging addon ==="
echo "  from: $SRC_DIR"
echo "    to: $STAGE"
rm -rf "$STAGE"
mkdir -p "$STAGE"
rsync "${rsync_args[@]}" "$SRC_DIR/" "$STAGE/"

LOG_COMPILE="$STAGE/smoke.log"
LOG_MAP="$STAGE/smoke_map.log"

# Unlike the Windows build, the macOS Cocoa build writes its full startup log to
# stdout, and its +logfile console command fails outright ("Could not start log").
# So capture stdout directly rather than relying on +logfile.
FAILED=0

report_log() {
    local logfile="$1" rc="$2"
    echo "  exit code: $rc"
    if [[ ! -s "$logfile" ]]; then
        echo "  ERROR: no output captured -- engine died before printing"
        FAILED=1
        return
    fi
    echo "  log: $logfile ($(wc -l <"$logfile" | tr -d ' ') lines)"
}

# Pass 1: startup/compile only. +quit is safe here because the console batch runs
# to completion during init.
run_compile_pass() {
    local logfile="$1"
    echo "=== pass: compile probe ==="
    "$UZDOOM" -iwad "$IWAD" -file "$PB_DIR" -file "$STAGE" \
        -nosound +echo "===PROBE===" +quit >"$logfile" 2>&1
    report_log "$logfile" $?
}

# Pass 2: real gameplay tics. The +wait console command does not gate a startup
# batch, so +quit would kill the engine before the map ever loads -- run it
# untethered for a fixed wall-clock window and terminate it ourselves instead.
run_map_pass() {
    local logfile="$1" seconds="$2"
    echo "=== pass: MAP01 gameplay (${seconds}s) ==="
    "$UZDOOM" -iwad "$IWAD" -file "$PB_DIR" -file "$STAGE" \
        -nosound -warp 1 +sv_cheats 1 +god >"$logfile" 2>&1 &
    local pid=$!
    sleep "$seconds"
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    sleep 1
    report_log "$logfile" 0
}

run_compile_pass "$LOG_COMPILE"
run_map_pass "$LOG_MAP" "${GAMEPLAY_SECONDS:-20}"

echo
echo "=== progress assertions ==="
# Compile success is proven by reaching the probe echo; a compile error aborts
# before it. Map success needs separate proof, since a bad -warp/+map silently
# leaves the engine sitting on the title screen and still exits 0.
assert_log() {
    local logfile="$1" pattern="$2" description="$3"
    if [[ ! -s "$logfile" ]]; then
        echo "  FAIL $(basename "$logfile") -- no output"
        FAILED=1
        return
    fi
    if grep -qE "$pattern" "$logfile"; then
        echo "  PASS $(basename "$logfile") -- $description"
    else
        echo "  FAIL $(basename "$logfile") -- $description not reached"
        FAILED=1
    fi
}

assert_log "$LOG_COMPILE" "===PROBE===" "ZScript/DECORATE compiled"
assert_log "$LOG_MAP" "^MAP[0-9]+ - " "MAP01 loaded and ticked"

echo
echo "=== error scan ==="
# Known-noise upstream PB warnings are filtered out.
matches=$(grep -inE "Script error|Execution could not continue|VM abort|Cannot find class|Tried to define class|Unknown identifier|Unexpected|fatal error" \
    "$LOG_COMPILE" "$LOG_MAP" 2>/dev/null \
    | grep -viE "sprites/smoke/(darker|shaded)\.bak|Music \"orb\" not found")

if [[ -n "$matches" ]]; then
    echo "$matches"
    FAILED=1
else
    echo "  clean -- zero matches"
fi

echo
if [[ $FAILED -ne 0 ]]; then
    echo "RESULT: FAIL"
    exit 1
fi
echo "RESULT: PASS"
exit 0
