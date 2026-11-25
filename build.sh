#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [ ! -s "$script_dir/foxchecker/foxchecker" ]; then
  echo "Missing Linux amd64 Foxchecker executable at foxchecker/foxchecker." >&2
  exit 1
fi

sh "$script_dir/update_dbip.sh"
exec docker build --platform linux/amd64 \
  -f "$script_dir/Dockerfile" -t foxchecker-singbox:latest \
  "$@" "$script_dir"
