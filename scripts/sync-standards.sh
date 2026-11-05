#!/usr/bin/env bash
# Sync the base standards of patchbay-standards into a consuming project, check the project's copy
# for drift, or regenerate the base: section of the project's index alone. The rule is
# base/process/standards-sync.md; this file lives in patchbay-standards and is copied into each
# project as scripts/sync-standards.sh by the sync itself, from the same commit as the tree.
#
# Usage, from the consuming project's root (the top of its git work tree):
#   scripts/sync-standards.sh [--init] [<path-to-patchbay-standards> [<ref>]]   sync
#   scripts/sync-standards.sh --index-only [<path-to-patchbay-standards>]       the base: section alone
#   scripts/sync-standards.sh --check [<path-to-patchbay-standards>]            drift check, writes nothing
# <path> defaults to ../patchbay-standards, the sibling checkout. <ref> defaults to that checkout's
# HEAD; --index-only and --check take no ref, they read the commit pinned in
# agent-os/standards/base/.version. The first sync of a project is run from the checkout's copy:
#   ../patchbay-standards/scripts/sync-standards.sh --init
#
# A sync, at the commit <ref> resolves to:
#   - exports base/, index.yml and scripts/sync-standards.sh from that commit with git archive,
#     never from the working tree, so an uncommitted edit cannot be synced
#   - replaces agent-os/standards/base/ with the exported base/ whole, so a file removed upstream
#     is removed here, and writes the commit to agent-os/standards/base/.version, the one file
#     under base/ that is not a standard
#   - replaces the base: section of agent-os/standards/index.yml with the base: section of the
#     exported index.yml, byte for byte, and leaves every other line of the project's index as it
#     was, in place and in order; --init creates the section (and the file) for a project syncing
#     for the first time, and without --init a missing section is refused
#   - verifies the result against the export (a failed verification exits 1)
#   - copies scripts/sync-standards.sh from the same commit over the project's copy, as the last
#     act, so the project carries the version of the script that produced its tree
#   - reports what changed on stderr (added, removed, changed files; old and new commit; what the
#     index and the script did) and prints one JSON object on stdout
# --check exports the pinned commit and compares: every file under agent-os/standards/base/ except
# .version, the base: section, and the script. Any difference is drift (exit 1), each named.
# --index-only regenerates the base: section from the pinned commit and touches nothing else.
#
# The base: section of an index is the line `base:` with nothing after the colon, plus every line
# after it that is indented, blank or a column-0 comment, ending at the last indented line: a
# trailing blank or comment line and the next column-0 key belong to the project. A second `base:`
# line, or one with content after the colon, is not a parseable section. --init inserts the section
# with one blank line on each side, before the first column-0 key other than `root:` that sorts
# after `base` (above the column-0 comment lines directly over that key, which stay with it), or at
# the end. The project's files are the tracked ones plus the untracked ones git
# does not ignore, as scripts/check-index.sh reads them, so an ignored stray is never drift.
#
# Exit status: 0 success; 1 a failed check (drift, or a sync whose result does not match the
# export); 2 usage or a precondition (a bad flag, not at a work-tree root, run inside
# patchbay-standards itself, <path> not a patchbay-standards checkout, <ref> not a commit, the pinned
# commit absent, no parseable base: section without --init). Needs git, tar, cmp, comm, awk, sed.
set -euo pipefail
export LC_ALL=C   # one collation for every sort, comm and awk comparison below

usage() {
  cat <<'TXT'
usage: scripts/sync-standards.sh [--init] [<path-to-patchbay-standards> [<ref>]]
       scripts/sync-standards.sh --index-only [<path-to-patchbay-standards>]
       scripts/sync-standards.sh --check [<path-to-patchbay-standards>]
Run from the consuming project's root. <path> defaults to ../patchbay-standards; <ref> to its HEAD.
TXT
}
die() { echo "FAIL  $2" >&2; exit "$1"; }   # die <status> <reason>

mode=sync; init=0; path=; ref=
while [ $# -gt 0 ]; do
  case "$1" in
    --init) init=1 ;;
    --index-only) [ "$mode" = sync ] || { usage >&2; exit 2; }; mode=index-only ;;
    --check) [ "$mode" = sync ] || { usage >&2; exit 2; }; mode=check ;;
    -h|--help) usage; exit 0 ;;
    --*) usage >&2; die 2 "unknown flag $1" ;;
    *) if [ -z "$path" ]; then path=$1
       elif [ -z "$ref" ]; then ref=$1
       else usage >&2; die 2 "too many arguments"; fi ;;
  esac
  shift
done
[ "$mode" = sync ] || [ -z "$ref" ] || { usage >&2; die 2 "--$mode takes no ref; it reads the commit in agent-os/standards/base/.version"; }
[ "$mode" = sync ] || [ "$init" -eq 0 ] || { usage >&2; die 2 "--init is a sync flag"; }
: "${path:=../patchbay-standards}"
: "${ref:=HEAD}"

root=$(pwd -P)
if ! top=$(git rev-parse --show-toplevel 2>/dev/null) || [ "$top" != "$root" ]; then
  die 2 "run from the consuming project's root, the top of its git work tree (here: $root)"
fi
base=agent-os/standards/base
idx=agent-os/standards/index.yml
script=scripts/sync-standards.sh
if [ -L "$base" ]; then
  die 2 "$base is a symlink: this is patchbay-standards itself, not a consuming project"
fi
if ! [ -d "$path" ] || ! git -C "$path" rev-parse --show-toplevel >/dev/null 2>&1; then
  die 2 "$path is not a git checkout; pass the path to a patchbay-standards checkout"
fi
up=$(cd "$path" && pwd -P)

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# The commit: <ref> for a sync, the pinned one otherwise.
if [ "$mode" = sync ]; then
  sha=$(git -C "$up" rev-parse --verify --quiet "$ref^{commit}") || die 2 "$ref is not a commit in $up"
else
  [ -f "$base/.version" ] || die 2 "$base/.version is missing; nothing is pinned (run a sync first)"
  sha=$(tr -d '[:space:]' < "$base/.version")
  printf '%s' "$sha" | grep -Eq '^[0-9a-f]{40}$' || die 2 "$base/.version does not hold a commit: $sha"
  git -C "$up" cat-file -e "$sha^{commit}" 2>/dev/null || die 2 "pinned commit $sha is not in $up (fetch it)"
fi
for p in base index.yml scripts/sync-standards.sh; do
  git -C "$up" cat-file -e "$sha:$p" 2>/dev/null ||
    die 2 "$up is not a patchbay-standards checkout at $sha: $p is missing from that commit"
done

export_commit() {  # the committed base/, index.yml and script, under $tmp/export; never the work tree
  rm -rf "$tmp/export"; mkdir "$tmp/export"
  git -C "$up" archive --format=tar "$sha" base index.yml scripts/sync-standards.sh | tar -x -C "$tmp/export"
}

# base_section <file>: the base: section per the rule in the header, or nothing.
base_section() {
  awk '
    !inbase && /^base:[[:space:]]*$/ { inbase = 1; print; next }
    inbase && /^[^[:space:]#]/       { exit }
    inbase && /^[[:space:]]*$/       { pending = pending $0 "\n"; next }
    inbase && /^#/                   { pending = pending $0 "\n"; next }
    inbase                           { printf "%s", pending; pending = ""; print }
  ' "$1"
}
# section_bounds <file>: "<first line> <last line>" of the section, or nothing.
section_bounds() {
  awk '
    !inbase && /^base:[[:space:]]*$/ { inbase = 1; start = NR; end = NR; next }
    inbase && /^[^[:space:]#]/       { exit }
    inbase && /^[[:space:]]*$/       { next }
    inbase && /^#/                   { next }
    inbase                           { end = NR }
    END                              { if (start) print start, end }
  ' "$1"
}
# section_state <file>: "none", "ok" or "unparseable" (a second base: line, or content after the colon)
section_state() {
  [ -f "$1" ] || { echo none; return; }
  n=$(grep -c '^base:' "$1" || true)
  case "$n" in
    0) echo none ;;
    1) if [ -n "$(section_bounds "$1")" ]; then echo ok; else echo unparseable; fi ;;
    *) echo unparseable ;;
  esac
}
strip_trailing_blank() {  # stdin to stdout, with trailing blank lines dropped
  awk '/^[[:space:]]*$/ { blank = blank $0 "\n"; next } { printf "%s", blank; blank = ""; print }'
}
# regen_index: replace (or with --init, create) the base: section from the export; sets index_status
regen_index() {
  base_section "$tmp/export/index.yml" > "$tmp/section.new"
  [ -s "$tmp/section.new" ] || die 1 "the exported index.yml at $sha has no base: section"
  case "$(section_state "$idx")" in
    ok)
      base_section "$idx" > "$tmp/section.old"
      if cmp -s "$tmp/section.old" "$tmp/section.new"; then index_status=unchanged; return; fi
      bounds=$(section_bounds "$idx"); start=${bounds% *}; end=${bounds#* }
      { head -n "$((start - 1))" "$idx"; cat "$tmp/section.new"; tail -n "+$((end + 1))" "$idx"; } > "$tmp/index.new"
      index_status=replaced ;;
    none)
      [ "$init" -eq 1 ] || die 2 "$idx has no base: section; a first sync passes --init to create it"
      if [ -f "$idx" ]; then
        at=$(awk '
          /^#/            { if (!run) run = NR; next }
          /^[^[:space:]]/ { key = $0; sub(/:.*$/, "", key)
                            if (key != "root" && key > "base") { print (run ? run : NR); exit }
                            run = 0; next }
                          { run = 0 }
        ' "$idx")
        if [ -n "$at" ]; then
          { head -n "$((at - 1))" "$idx" | strip_trailing_blank; [ "$at" -gt 1 ] && echo; cat "$tmp/section.new"; echo; tail -n "+$at" "$idx"; } > "$tmp/index.new"
        else
          { strip_trailing_blank < "$idx"; [ -s "$idx" ] && echo; cat "$tmp/section.new"; } > "$tmp/index.new"
        fi
      else
        mkdir -p "$(dirname "$idx")"; cp "$tmp/section.new" "$tmp/index.new"
      fi
      index_status=created ;;
    *) die 2 "$idx has a base: line that is not a parseable section (a second base: line, or content after the colon)" ;;
  esac
  cat "$tmp/index.new" > "$idx"
}

# project_files: paths under $base relative to it, tracked or untracked-not-ignored, on disk, minus .version
project_files() {
  [ -d "$base" ] || return 0
  { git -c core.quotePath=false ls-files -- "$base"
    git -c core.quotePath=false ls-files --others --exclude-standard -- "$base"; } | sort -u |
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    f=${f#"$base"/}; [ "$f" = .version ] && continue
    printf '%s\n' "$f"
  done
}
# compare: the project's base/ against the export; writes $tmp/{added,removed,changed}
# (added = in the export, not the project; removed = in the project, not the export)
compare() {
  project_files | sort > "$tmp/have"
  (cd "$tmp/export/base" && find . -type f | sed 's#^\./##') | sort > "$tmp/want"
  for l in have want; do sort -c "$tmp/$l" 2>/dev/null || die 1 "internal: the $l list is not sorted"; done
  comm -13 "$tmp/have" "$tmp/want" > "$tmp/added" || die 1 "internal: comm could not compare the lists"
  comm -23 "$tmp/have" "$tmp/want" > "$tmp/removed" || die 1 "internal: comm could not compare the lists"
  comm -12 "$tmp/have" "$tmp/want" > "$tmp/common" || die 1 "internal: comm could not compare the lists"
  : > "$tmp/changed"
  while IFS= read -r f; do cmp -s "$base/$f" "$tmp/export/base/$f" || printf '%s\n' "$f"; done < "$tmp/common" > "$tmp/changed"
}
section_differs() {  # 0 when the project's base: section differs from the export's
  base_section "$idx" > "$tmp/section.have" 2>/dev/null || :
  base_section "$tmp/export/index.yml" > "$tmp/section.want"
  ! cmp -s "$tmp/section.have" "$tmp/section.want"
}

json_str() { printf '"%s"' "$(printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g')"; }
json_list() {  # json_list <file>: one JSON array of its lines
  local first=1 out="["
  while IFS= read -r f; do
    [ "$first" -eq 1 ] || out="$out,"; first=0; out="$out$(json_str "$f")"
  done < "$1"
  printf '%s]' "$out"
}
report_files() {  # report_files <label> <file>: one stderr line per path
  while IFS= read -r f; do printf '  %-8s %s\n' "$1" "$f" >&2; done < "$2"
}
entries() { grep -c '^  [^[:space:]#]' "$1" || true; }

export_commit
case "$mode" in
check)
  state=$(section_state "$idx")
  [ "$state" = ok ] || die 2 "$idx has no parseable base: section (state: $state)"
  compare
  if section_differs; then index_status=differs; else index_status=identical; fi
  if ! [ -f "$script" ]; then script_status=missing
  elif cmp -s "$script" "$tmp/export/scripts/sync-standards.sh"; then script_status=matches
  else script_status=differs; fi
  ok=true
  { [ -s "$tmp/added" ] || [ -s "$tmp/removed" ] || [ -s "$tmp/changed" ]; } && ok=false
  [ "$index_status" = identical ] || ok=false
  [ "$script_status" = matches ] || ok=false
  echo "check base standards against $sha  ($up)" >&2
  report_files missing "$tmp/added"
  report_files extra "$tmp/removed"
  report_files changed "$tmp/changed"
  echo "  index    base: section $index_status" >&2
  echo "  script   $script $script_status" >&2
  printf '{"mode":"check","upstream":%s,"commit":"%s","missing":%s,"extra":%s,"changed":%s,"index":"%s","script":"%s","ok":%s}\n' \
    "$(json_str "$up")" "$sha" "$(json_list "$tmp/added")" "$(json_list "$tmp/removed")" "$(json_list "$tmp/changed")" \
    "$index_status" "$script_status" "$ok"
  if [ "$ok" = true ]; then
    echo "ok   $base and the base: section of $idx match patchbay-standards at $sha" >&2; exit 0
  fi
  echo "FAIL  drift from patchbay-standards at $sha (see above)" >&2; exit 1 ;;
index-only)
  state=$(section_state "$idx")
  [ "$state" = ok ] || die 2 "$idx has no parseable base: section (state: $state)"
  regen_index
  echo "regenerate the base: section of $idx from $sha  ($up)" >&2
  echo "  index    base: section $index_status ($(entries "$tmp/section.new") entries)" >&2
  printf '{"mode":"index-only","upstream":%s,"commit":"%s","index":"%s"}\n' "$(json_str "$up")" "$sha" "$index_status"
  exit 0 ;;
esac

# sync
state=$(section_state "$idx")
case "$state" in
  ok) ;;
  none) [ "$init" -eq 1 ] || die 2 "$idx has no base: section; a first sync passes --init to create it" ;;
  *) die 2 "$idx has a base: line that is not a parseable section (a second base: line, or content after the colon)" ;;
esac
old=none; [ -f "$base/.version" ] && old=$(tr -d '[:space:]' < "$base/.version")
compare
for l in added removed changed; do mv "$tmp/$l" "$tmp/$l.pre"; done   # what this sync changes
mkdir -p "$(dirname "$base")"
rm -rf "$base"
mv "$tmp/export/base" "$base"
printf '%s\n' "$sha" > "$base/.version"
regen_index
# Verify the result against a fresh export before touching the script.
export_commit
compare
if [ -s "$tmp/added" ] || [ -s "$tmp/removed" ] || [ -s "$tmp/changed" ] || section_differs; then
  die 1 "the synced $base or the base: section of $idx does not match the export at $sha"
fi
if ! [ -f "$script" ]; then script_status=installed
elif cmp -s "$script" "$tmp/export/scripts/sync-standards.sh"; then script_status=unchanged
else script_status=updated; fi
echo "sync base standards: $old -> $sha  ($up, ref $ref)" >&2
report_files added "$tmp/added.pre"
report_files removed "$tmp/removed.pre"
report_files changed "$tmp/changed.pre"
echo "  index    base: section $index_status ($(entries "$tmp/section.new") entries)" >&2
echo "  script   $script $script_status" >&2
printf '{"mode":"sync","upstream":%s,"ref":%s,"old":%s,"new":"%s","added":%s,"removed":%s,"changed":%s,"index":"%s","script":"%s"}\n' \
  "$(json_str "$up")" "$(json_str "$ref")" "$([ "$old" = none ] && echo null || json_str "$old")" "$sha" \
  "$(json_list "$tmp/added.pre")" "$(json_list "$tmp/removed.pre")" "$(json_list "$tmp/changed.pre")" "$index_status" "$script_status"
if [ "$script_status" != unchanged ]; then
  mkdir -p scripts
  cp "$tmp/export/scripts/sync-standards.sh" "$script.new"; chmod +x "$script.new"
  mv "$script.new" "$script"   # last act: the running bash keeps its own inode open
fi
echo "ok   synced to $sha" >&2
