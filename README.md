# foxchecker-singbox

**English** · [简体中文](zh-cn/README.md) · [繁體中文](zh-hant/README.md) · [日本語](ja/README.md) · [Русский](ru-ru/README.md) · [Türkçe](tr-tr/README.md) · [Tiếng Việt](vi-vn/README.md) · [العربية](ar/README.md) · [فارسی](fa-ir/README.md) · [اردو](ur-pk/README.md)

Foxchecker uses the sing-box core to check proxy nodes from share links and subscriptions. Reports include HTTPS connectivity, ingress IP, observed egress IP, GeoIP country or region, and separate UDP4 and UDP6 results. The script uses a prebuilt image and requires a running Docker engine. [Docker Hub image](https://hub.docker.com/r/akpig/foxchecker-singbox)

## Quick start

You need Bash, access to a Docker engine running Linux containers, and a writable report directory. The image targets `linux/amd64`. Docker on ARM must support running amd64 containers. The engine must be able to access the host's report directory and local subscription file.

### Run directly from GitHub

Run these commands in the directory where you want to save the report. They download `singbox-checker.sh` from the GitHub repository's default branch. Arguments after `bash -s --` are passed to the script.

```bash
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- 'vmess://…'
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- -s 'https://sub.foxdetector.com/en/top500/sing-box.json'
```

### Run a local copy

Run these commands from the repository directory and replace the example inputs as needed. To save reports elsewhere, change to that directory and invoke the script by its absolute path.

#### Check a single share link

```bash
./singbox-checker.sh 'vmess://…'
```

Supported link schemes are `vmess://`, `vless://`, `trojan://`, `ss://`, `hysteria2://` (`hy2://`), `tuic://`, and `anytls://`. Available transports depend on sing-box's support for the node configuration.

#### Check a subscription

```bash
./singbox-checker.sh -s 'https://sub.foxdetector.com/en/top500/sing-box.json'
./singbox-checker.sh -s './sing-box.json' --format sing-box -c 8 --timeout 15s
```

The `-s` option accepts a public HTTPS URL or a local file. Relative paths are resolved from your current directory. The format is detected automatically and can be Clash YAML with inline nodes, plain-text or Base64 V2Ray link lists, or sing-box JSON.

| Option | Purpose |
| --- | --- |
| `-s`, `--subscription` | Specify a subscription URL or local file |
| `-c`, `--concurrent` | Maximum concurrent subscription checks. Default is `16`. |
| `--format` | Subscription format. Defaults to `auto`. Supported values include `clash`, `v2ray`, and `sing-box`. |
| `--timeout` | Per-node timeout. Defaults to `10s` and applies to share links and subscriptions. |
| `-h`, `--help` | Show help |

## Read the results

The script writes `result.json` in the current directory and replaces it whenever a new report is generated. A single-link report contains the node result directly. A subscription report lists node results in input order under `results`. For failed checks, see `error.code` and `https.reason`. A UDP value of `null` means the check was inconclusive. See `udp4_reason` or `udp6_reason` for details.

The script uses `akpig/foxchecker-singbox:latest`. Docker pulls it if it is missing locally. The script removes the container when the check ends or is interrupted. A failed check returns a nonzero exit status and records the failure reason when it can generate a report. If Docker cannot start or the command usage is invalid, an earlier `result.json` may still be present. Check the exit status and terminal output.

## Build the image locally

Place the Linux amd64 Foxchecker executable at `foxchecker/foxchecker`, then run this command from the repository directory.

```bash
./build.sh
```

The build script updates and verifies the GeoIP data and creates the local `foxchecker-singbox:latest` image. The checker script uses the Docker Hub image linked above. See [geoip/NOTICE](geoip/NOTICE) for GeoIP attribution.
