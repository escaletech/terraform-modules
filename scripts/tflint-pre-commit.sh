#!/usr/bin/env bash
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
config="$root/.tflint.hcl"
dirs=""

for f in "$@"; do
  case "$f" in
    *.tf)
      d="$(dirname "$f")"
      while [ "$d" != "." ] && [ "$d" != "/" ]; do
        parent="$(dirname "$d")"
        if [ "$(basename "$parent")" = "modules" ]; then
          dirs="$dirs
$d"
          break
        fi
        d="$parent"
      done
      ;;
  esac
done

dirs="$(printf '%s\n' "$dirs" | sed '/^$/d' | sort -u)"
if [ -z "$dirs" ]; then
  exit 0
fi

printf '%s\n' "$dirs" | while IFS= read -r d; do
  echo "tflint --chdir=$d"
  tflint --chdir="$d" --config="$config" --call-module-type=all
done
