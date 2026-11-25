# foxchecker-singbox

[English](../README.md) · [简体中文](../zh-cn/README.md) · **繁體中文** · [日本語](../ja/README.md) · [Русский](../ru-ru/README.md) · [Türkçe](../tr-tr/README.md) · [Tiếng Việt](../vi-vn/README.md) · [العربية](../ar/README.md) · [فارسی](../fa-ir/README.md) · [اردو](../ur-pk/README.md)

Foxchecker 使用 sing-box 核心檢查代理分享連結和訂閱中的節點。報告包含 HTTPS 連線狀態、節點入口 IP、實測出口 IP、GeoIP 國家或地區，以及獨立的 UDP4 和 UDP6 結果。這個指令碼使用預先建置的映像檔，安裝並啟動 Docker 即可執行。 [Docker Hub 映像檔](https://hub.docker.com/r/akpig/foxchecker-singbox)

## 快速開始

需要 Bash、可存取的 Docker Linux 容器引擎和可寫入的報告目錄。映像檔平台為 `linux/amd64`。ARM 主機的 Docker 必須能執行 amd64 容器。Docker 引擎也必須能存取主機的報告目錄和本機訂閱檔案。

### 直接從 GitHub 執行

請在要儲存報告的目錄執行。指令會從 GitHub 儲存庫的預設分支下載 `singbox-checker.sh`，並把 `bash -s --` 後面的引數傳給指令碼。

```bash
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- 'vmess://…'
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- -s 'https://sub.foxdetector.com/zh-hant/top500/sing-box.json'
```

### 在本機執行

請在儲存庫目錄執行下列指令，並視需要替換範例輸入。若要將報告寫到其他目錄，先切換到該目錄，再以絕對路徑執行指令碼。

#### 檢查單一分享連結

```bash
./singbox-checker.sh 'vmess://…'
```

支援 `vmess://`, `vless://`, `trojan://`, `ss://`, `hysteria2://` (`hy2://`), `tuic://`, `anytls://`。可用的傳輸方式取決於 sing-box 是否支援該節點設定。

#### 檢查訂閱

```bash
./singbox-checker.sh -s 'https://sub.foxdetector.com/zh-hant/top500/sing-box.json'
./singbox-checker.sh -s './sing-box.json' --format sing-box -c 8 --timeout 15s
```

`-s` 接受公開的 HTTPS 網址或本機檔案。相對路徑以執行指令時的目錄為準。預設自動偵測格式，支援內含節點的 Clash YAML、V2Ray 純文字或 Base64 連結清單，以及 sing-box JSON。

| 選項 | 用途 |
| --- | --- |
| `-s`, `--subscription` | 指定訂閱網址或本機檔案 |
| `-c`, `--concurrent` | 訂閱檢查的並行上限，預設為 `16` |
| `--format` | 訂閱格式，預設為 `auto`，也可指定 `clash`、`v2ray` 或 sing-box |
| `--timeout` | 單一節點的檢查時限，預設為 `10s`。適用於單一連結與訂閱 |
| `-h`, `--help` | 顯示說明 |

## 查看結果

指令碼會在目前目錄產生 `result.json`，每次產生新報告時都會覆寫同名檔案。單一連結的報告直接記錄節點結果，訂閱報告則在 `results` 中按輸入順序列出結果。檢查失敗時請查看 `error.code` 和 `https.reason`。UDP 欄位為 `null` 時表示無法判定，詳細原因請查看 `udp4_reason` 或 `udp6_reason`。

指令碼使用 `akpig/foxchecker-singbox:latest`。本機缺少映像檔時，Docker 會拉取映像檔。檢查結束或中斷時，指令碼會移除本次容器。檢查失敗時會傳回非零結束狀態，並在能產生報告時記錄失敗原因。若 Docker 無法啟動或指令用法有誤，目錄中可能仍有舊報告，請查看這次的結束狀態和終端機輸出。

## 在本機建置映像檔

將 Linux amd64 版的 Foxchecker 執行檔放在 `foxchecker/foxchecker`，然後從儲存庫目錄執行下列指令。

```bash
./build.sh
```

建置指令碼會更新並驗證 GeoIP 資料，並產生本機的 `foxchecker-singbox:latest` 映像檔。檢查指令碼使用上方連結中的 Docker Hub 映像檔。GeoIP 資料的署名請見 [geoip/NOTICE](../geoip/NOTICE)。
