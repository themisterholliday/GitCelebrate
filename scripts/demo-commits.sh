#!/usr/bin/env bash
#
# demo-commits.sh — generate test commits of varied sizes/stats to demo
# GitCelebrate's reward overlays.
#
# Usage:
#   scripts/demo-commits.sh [repo_path] [--delay SECONDS] [--yes]
#
#   repo_path     Where to build the demo repo (default: ./TestRepos/DemoRepo)
#   --delay N     Seconds to wait between commits (default: 4)
#   --yes, -y     Skip the "add the repo to GitCelebrate" pause
#
# Flow:
#   1. Creates (or reuses) a git repo with a seed commit.
#   2. Pauses so you can add that repo to GitCelebrate (skipped with --yes).
#   3. Makes 10 commits of escalating size, waiting --delay between each so
#      every commit triggers its own celebration.
#
# The commit plan is tuned to GitCelebrate's scorer
# (points = min(churn,300) + min(files*8,80) + min(deletions/2,40); tiers at
# 25 / 90 / 220) so the run sweeps tiny → small → chunky → legendary.

set -euo pipefail

REPO="${PWD}/TestRepos/DemoRepo"
DELAY=4
ASSUME_YES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --delay) DELAY="${2:?--delay needs a value}"; shift 2 ;;
    --yes|-y) ASSUME_YES=1; shift ;;
    -h|--help) grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "Unknown option: $1" >&2; exit 2 ;;
    *) REPO="$1"; shift ;;
  esac
done

command -v git >/dev/null || { echo "error: git not found on PATH" >&2; exit 1; }

# "files insertions deletions | subject"
COMMITS=(
  "1 1 1|Fix typo in README"
  "2 20 5|Tweak button padding"
  "3 34 4|Add empty-state copy"
  "3 48 20|Polish overlay animations"
  "4 72 12|Implement search filter"
  "5 60 58|Refactor settings pane"
  "8 140 10|Add unit tests for scorer"
  "6 160 30|Add onboarding flow"
  "4 12 220|Remove legacy sync code"
  "14 320 110|Ship release 1.0"
)

# --- setup repo ------------------------------------------------------------
mkdir -p "$REPO"
cd "$REPO"
if [[ ! -d .git ]]; then
  git init -q
  git config user.email "demo@gitcelebrate.local"
  git config user.name "GitCelebrate Demo"
  seq 1 5000 | sed 's/^/pool line /' > pool.txt
  git add -A
  git commit -q -m "Seed demo repo"
  echo "Created demo repo at: $REPO"
fi
mkdir -p src

if [[ "$ASSUME_YES" -ne 1 ]]; then
  echo
  echo "Add this repo to GitCelebrate now:"
  echo "  $REPO"
  read -r -p "Press Enter to start the demo commits... "
fi

# --- commit helper ---------------------------------------------------------
make_commit() {
  local files="$1" ins="$2" del="$3" subject="$4"

  # Deletions: drop $del lines from the top of the shared pool file.
  if (( del > 0 )); then
    tail -n +"$((del + 1))" pool.txt > pool.tmp
    mv pool.tmp pool.txt
  fi

  # Insertions: spread across $files brand-new files (unique per commit).
  local slug stamp per rem count f
  slug="$(printf '%s' "$subject" | tr ' A-Z' '_a-z' | tr -cd 'a-z0-9_')"
  stamp="$(date +%s%N)"
  per=$(( ins / files ))
  rem=$(( ins % files ))
  for (( f = 1; f <= files; f++ )); do
    count=$per
    if (( f == files )); then count=$(( per + rem )); fi
    if (( count < 1 )); then count=1; fi
    seq 1 "$count" | sed "s/^/${slug}_f${f} /" > "src/${slug}_${stamp}_${f}.txt"
  done

  git add -A
  git commit -q -m "$subject"
}

# --- run -------------------------------------------------------------------
total=${#COMMITS[@]}
i=0
for spec in "${COMMITS[@]}"; do
  i=$((i + 1))
  stats="${spec%%|*}"
  subject="${spec#*|}"
  read -r files ins del <<< "$stats"
  make_commit "$files" "$ins" "$del" "$subject"
  printf '[%2d/%d] %-28s files~%-2s +%-3s -%s\n' "$i" "$total" "$subject" "$files" "$ins" "$del"
  if (( i < total )); then sleep "$DELAY"; fi
done

echo "Done — $total commits created in $REPO"
