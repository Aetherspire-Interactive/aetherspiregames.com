#!/usr/bin/env bash
set -euo pipefail
verfile="VERSION"
[[ -f $verfile ]] || { echo "VERSION file not found"; exit 1; }
read -r MA MI PA < <(awk -F. '{print $1, $2, $3}' "$verfile")

bump_semver () {
  local part="$1"
  case "$part" in
    patch) PA=$((PA+1));;
    min|minor) MI=$((MI+1)); PA=0;;
    major) MA=$((MA+1)); MI=0; PA=0;;
    *) echo "Unknown bump: $part"; exit 1;;
  esac
  echo "${MA}.${MI}.${PA}" > "$verfile"
  git add "$verfile"
  git commit -m "chore(release): $(cat $verfile)"
}

make_tag () {
  local tag="$1"
  # Optional build metadata: uncomment to append +YYYY.MM.DD
  # tag="${tag}+$(date -u +%Y.%m.%d)"
  git tag -s "v${tag}" -m "Release v${tag}"
  git push && git push --tags
  echo "Tagged v${tag}"
}

case "${1:-}" in
  patch|min|minor|major)
    bump_semver "$1"
    make_tag "$(cat $verfile)"
    ;;
  snapshot)
    kind="${2:-}"; seq="${3:-}"
    [[ -n "$kind" && -n "$seq" ]] || { echo "Usage: snapshot AS|BS|RS|GS [n_or_letter]"; exit 1; }
    case "$kind" in
      AS|BS|RS) tag="$(cat $verfile)-${kind}.${seq}" ;;
      GS)       tag="$(cat $verfile)-GS.${seq}" ;;
      *) echo "Unknown snapshot kind: $kind"; exit 1;;
    esac
    git commit --allow-empty -m "chore(snapshot): $tag"
    make_tag "$tag"
    ;;
  dayone)
    MI=$((MI+1)); PA=0
    echo "${MA}.${MI}.${PA}" > "$verfile"
    git add "$verfile"
    git commit -m "chore(release): Day One $(cat $verfile)"
    make_tag "$(cat $verfile)"
    ;;
  tag)
    raw="${2:-$(cat $verfile)}"; raw="${raw#v}"
    git commit --allow-empty -m "chore(release): $raw"
    make_tag "$raw"
    ;;
  *)
    cat <<USAGE
Usage:
  scripts/release.sh patch|min|minor|major
  scripts/release.sh snapshot AS|BS|RS|GS [n_or_letter]
  scripts/release.sh dayone
  scripts/release.sh tag [vX.Y.Z[-SUFFIX]]
USAGE
    exit 1
    ;;
esac
