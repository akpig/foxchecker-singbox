#!/bin/sh
set -eu

url=https://dbip.mirror.framasoft.org/files/dbip-country-lite-latest.mmdb.gz
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cache="$script_dir/geoip"
output="$cache/country.mmdb"
state="$cache/current.sha512"

mkdir -p "$cache"
stage=$(mktemp -d "$cache/.refresh.XXXXXXXX")
trap 'rm -rf "$stage"' EXIT
trap 'exit 1' HUP INT TERM

download() {
  curl --proto '=https' --proto-redir '=https' -fsSL \
    --connect-timeout 15 --max-time 120 --retry 3 --retry-max-time 180 "$@"
}

read_hash() {
  LC_ALL=C awk '
    NR == 1 { hash = $1 }
    END {
      if (NR != 1 || length(hash) != 128 || hash ~ /[^[:xdigit:]]/) exit 1
      print tolower(hash)
    }
  ' "$1"
}

unpack_verified() {
  if command -v sha512sum >/dev/null 2>&1; then
    printf '%s  %s\n' "$1" "$2" | sha512sum -c - || return 1
  else
    printf '%s  %s\n' "$1" "$2" | shasum -a 512 -c - || return 1
  fi
  gzip -dc "$2" > "$3"
}

read_cached() {
  [ -f "$1/current.sha512" ] &&
    digest=$(read_hash "$1/current.sha512") &&
    [ -f "$1/$digest.mmdb.gz" ] &&
    unpack_verified "$digest" "$1/$digest.mmdb.gz" "$2" >&2 &&
    printf '%s\n' "$digest"
}

cached_hash=$(read_cached "$cache" "$stage/cached.mmdb") || cached_hash=

if download "$url.sha512sum" -o "$stage/SHA512SUMS" &&
    latest_hash=$(read_hash "$stage/SHA512SUMS"); then
  if [ "$latest_hash" = "$cached_hash" ]; then
    touch "$state"
    echo "GeoIP cache is up to date."
    install -m 0644 "$stage/cached.mmdb" "$output"
    exit 0
  fi
  if download "$url" -o "$stage/country.mmdb.gz" &&
      unpack_verified "$latest_hash" "$stage/country.mmdb.gz" "$stage/latest.mmdb"; then
    mv -f "$stage/country.mmdb.gz" "$cache/$latest_hash.mmdb.gz"
    printf '%s\n' "$latest_hash" > "$stage/current.sha512"
    mv -f "$stage/current.sha512" "$state"
    install -m 0644 "$stage/latest.mmdb" "$output"
    exit 0
  fi
fi

if [ -n "$cached_hash" ]; then
  echo "Could not refresh GeoIP data. Using the last verified database." >&2
  install -m 0644 "$stage/cached.mmdb" "$output"
  exit 0
fi

echo "Could not obtain a verified GeoIP database." >&2
exit 1
