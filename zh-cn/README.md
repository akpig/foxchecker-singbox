# foxchecker-singbox

[English](../README.md) · **简体中文** · [繁體中文](../zh-hant/README.md) · [日本語](../ja/README.md) · [Русский](../ru-ru/README.md) · [Türkçe](../tr-tr/README.md) · [Tiếng Việt](../vi-vn/README.md) · [العربية](../ar/README.md) · [فارسی](../fa-ir/README.md) · [اردو](../ur-pk/README.md)

Foxchecker 使用 sing-box 核心检查代理分享链接和订阅中的节点。报告包含 HTTPS 连通性、节点入口 IP、实测出口 IP、GeoIP 国家或地区，以及独立的 UDP4 和 UDP6 结果。脚本使用预构建镜像，安装并启动 Docker 后即可运行。 [Docker Hub 镜像](https://hub.docker.com/r/akpig/foxchecker-singbox)

## 快速开始

需要 Bash、可访问的 Docker Linux 容器引擎，以及可写的报告目录。镜像平台为 `linux/amd64`，ARM 主机需要 Docker 支持运行 amd64 容器。Docker 引擎需要能访问宿主机上的报告目录和本地订阅文件。

### 一行运行

在希望保存报告的目录运行。命令从 GitHub 仓库的默认分支下载 `singbox-checker.sh`，`bash -s --` 后的参数会传给脚本。

```bash
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- 'vmess://…'
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- -s 'https://sub.foxdetector.com/zh-cn/top500/sing-box.json'
```

### 从本地运行

从本仓库目录运行下列命令，并替换示例输入。若要将报告写入其他目录，先切换到该目录，再用脚本的绝对路径运行。

#### 检查一条分享链接

```bash
./singbox-checker.sh 'vmess://…'
```

支持 `vmess://`, `vless://`, `trojan://`, `ss://`, `hysteria2://` (`hy2://`), `tuic://`, `anytls://`。可用的传输方式取决于 sing-box 对节点配置的支持。

#### 检查订阅

```bash
./singbox-checker.sh -s 'https://sub.foxdetector.com/zh-cn/top500/sing-box.json'
./singbox-checker.sh -s './sing-box.json' --format sing-box -c 8 --timeout 15s
```

`-s` 接受公网 HTTPS 地址或本地文件路径。相对路径以运行命令时所在的目录为基准。订阅格式默认自动识别，支持含内联节点的 Clash YAML、V2Ray 明文或 Base64 链接列表，以及 sing-box JSON。

| 参数 | 用途 |
| --- | --- |
| `-s`, `--subscription` | 指定订阅地址或本地文件 |
| `-c`, `--concurrent` | 订阅检查的最大并发数，默认 `16` |
| `--format` | 订阅格式，默认 `auto`，可指定 `clash`、`v2ray` 或 sing-box |
| `--timeout` | 每个节点的检查时限，默认 `10s`。单链接和订阅均可使用 |
| `-h`, `--help` | 显示帮助 |

## 查看结果

脚本在当前目录生成 `result.json`，每次生成报告时替换同名文件。单链接报告直接记录节点结果，订阅报告在 `results` 中按输入顺序列出节点。遇到失败时，可查看报告中的 `error.code` 和 `https.reason`。UDP 字段为 `null` 表示本次无法判定，可查看对应的 `udp4_reason` 或 `udp6_reason`。

脚本使用 `akpig/foxchecker-singbox:latest`，本地缺少镜像时由 Docker 拉取。检查结束或收到中断信号时，脚本会清理本次容器。检查失败时会返回非零退出码，并在可生成报告时写入失败原因。如果 Docker 无法启动或命令用法有误，目录里可能仍是上一次的报告，请结合本次退出码和终端输出判断。

## 本地构建镜像

将 Linux amd64 版 Foxchecker 可执行文件放到 `foxchecker/foxchecker`，然后在本仓库目录运行下列命令。

```bash
./build.sh
```

构建脚本更新并校验 GeoIP 数据，生成本地镜像 `foxchecker-singbox:latest`。检查脚本调用上文的 Docker Hub 镜像。GeoIP 数据署名见 [geoip/NOTICE](../geoip/NOTICE)。
