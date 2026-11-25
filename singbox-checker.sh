#!/usr/bin/env bash
set -e

image=akpig/foxchecker-singbox:latest

usage() {
  cat <<'EOF'
Usage:
  singbox-checker.sh [--timeout DURATION] 'SHARE_LINK'
  singbox-checker.sh [OPTIONS] -s 'HTTPS_URL_OR_LOCAL_FILE'

  -s, --subscription   Check a subscription
  -c, --concurrent     Maximum concurrent checks (default: 16)
      --format         Subscription format: auto (default), clash, v2ray, or sing-box
      --timeout        Per-node timeout (default: 10s)
  -h, --help           Show help

Uses a Linux/amd64 Docker image. Each new report replaces result.json in the current directory.
EOF
}

die() {
  local status=$1
  shift
  printf '%s\n' "$*" >&2
  exit "$status"
}

# The --mount argument is CSV, so quote the whole source field.
bind_mount() {
  local source=${1//\"/\"\"}
  printf 'type=bind,"source=%s",target=%s' "$source" "$2"
}

share_link=
subscription=
checker_args=()
while (( $# )); do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -s|--subscription|-c|--concurrent|--format|--timeout)
      (( $# >= 2 )) || die 2 "Missing value for $1."
      option=$1
      value=$2
      shift 2
      ;;
    --subscription=*|--concurrent=*|--format=*|--timeout=*)
      option=${1%%=*}
      value=${1#*=}
      shift
      ;;
    -*)
      die 2 'Unknown option. See --help.'
      ;;
    *)
      [[ -z "$share_link" && -n "$1" ]] || die 2 'Provide exactly one nonempty share link.'
      share_link=$1
      shift
      continue
      ;;
  esac
  [[ -n "$value" ]] || die 2 "Missing value for $option."
  case "$option" in
    -s|--subscription)
      [[ -z "$subscription" ]] || die 2 'Provide only one subscription.'
      subscription=$value
      ;;
    *)
      checker_args+=("$option" "$value")
      ;;
  esac
done

if [[ -n "$share_link" && -n "$subscription" || -z "$share_link" && -z "$subscription" ]]; then
  usage >&2
  die 2 'Provide one share link or use --subscription to specify a subscription.'
fi

output_dir=$(pwd -P)
mounts=(--mount "$(bind_mount "$output_dir" /output)")
case "$subscription" in
  '') checker_args+=(-- "$share_link") ;;
  https://*) checker_args+=(--subscription "$subscription") ;;
  *://*) die 2 'Remote subscriptions must use HTTPS.' ;;
  *)
    [[ "$subscription" = /* ]] || subscription="$output_dir/$subscription"
    [[ -f "$subscription" && -r "$subscription" ]] || die 2 'The local subscription must be a readable regular file.'
    [[ ! "$subscription" -ef "$output_dir/result.json" ]] || die 2 'Choose a subscription file other than the output file result.json.'
    subscription_dir=${subscription%/*}
    subscription_dir=$(cd "${subscription_dir:-/}" && pwd -P) || die 2 'Could not access the local subscription directory.'
    subscription="${subscription_dir%/}/${subscription##*/}"
    mounts+=(--mount "$(bind_mount "$subscription" /tmp/foxchecker-subscription),readonly")
    checker_args+=(--subscription /tmp/foxchecker-subscription)
    ;;
esac

command -v docker >/dev/null 2>&1 || die 3 'Docker CLI is unavailable. Install Docker first.'
engine_os=$(docker info --format '{{.OSType}}') || die 3 'Could not connect to Docker. Check that Docker is running and your account can access it.'
[[ "$engine_os" = linux ]] || die 3 'This image requires Docker in Linux container mode.'
[[ -w "$output_dir" ]] || die 3 'The current directory is not writable.'

container_id=
cleanup() {
  local status=$?
  trap '' HUP INT TERM
  if [[ -n "$container_id" ]] && ! docker rm -f "$container_id" >/dev/null; then
    printf 'Could not remove check container %s.\n' "$container_id" >&2
    if (( status == 0 )); then
      status=3
    fi
  fi
  exit "$status"
}

trap cleanup EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

container_id=$(docker create --platform linux/amd64 --user "$(id -u):$(id -g)" \
  "${mounts[@]}" "$image" "${checker_args[@]}") || die 3 'Could not create the sing-box check container.'

# Waiting for an attached child lets the shell run its signal traps promptly.
docker start --attach "$container_id" &
wait "$!"
