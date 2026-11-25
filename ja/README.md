# foxchecker-singbox

[English](../README.md) · [简体中文](../zh-cn/README.md) · [繁體中文](../zh-hant/README.md) · **日本語** · [Русский](../ru-ru/README.md) · [Türkçe](../tr-tr/README.md) · [Tiếng Việt](../vi-vn/README.md) · [العربية](../ar/README.md) · [فارسی](../fa-ir/README.md) · [اردو](../ur-pk/README.md)

Foxchecker は sing-box コアを使い、共有リンクやサブスクリプションに含まれるプロキシノードを確認します。レポートには HTTPS 接続の可否、入口 IP、実測した出口 IP、GeoIP による国・地域、UDP4 と UDP6 それぞれの結果が含まれます。スクリプトはビルド済みのイメージを使用し、実行には Docker の起動が必要です。 [Docker Hub イメージ](https://hub.docker.com/r/akpig/foxchecker-singbox)

## クイックスタート

Bash、Linux コンテナを実行できる Docker エンジン、書き込み可能なレポート保存先が必要です。イメージは `linux/amd64` 用です。ARM ホスト上の Docker では amd64 コンテナの実行に対応している必要があります。Docker エンジンからホストのレポート保存先とローカルのサブスクリプションファイルにアクセスできるようにしてください。

### GitHub から直接実行

レポートを保存したいディレクトリで実行します。コマンドは GitHub リポジトリの既定ブランチから `singbox-checker.sh` をダウンロードし、`bash -s --` 以降の引数をスクリプトに渡します。

```bash
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- 'vmess://…'
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- -s 'https://sub.foxdetector.com/ja/top500/sing-box.json'
```

### ローカルで実行

リポジトリのディレクトリで以下のコマンドを実行し、必要に応じて入力例を置き換えてください。別の場所にレポートを保存するには、そのディレクトリへ移動してスクリプトを絶対パスで実行します。

#### 共有リンクを 1 件確認する

```bash
./singbox-checker.sh 'vmess://…'
```

対応するリンクのスキームは `vmess://`, `vless://`, `trojan://`, `ss://`, `hysteria2://` (`hy2://`), `tuic://`, `anytls://` です。利用可能なトランスポートは、sing-box がノードの設定に対応しているかどうかによって異なります。

#### サブスクリプションを確認する

```bash
./singbox-checker.sh -s 'https://sub.foxdetector.com/ja/top500/sing-box.json'
./singbox-checker.sh -s './sing-box.json' --format sing-box -c 8 --timeout 15s
```

`-s` には公開 HTTPS URL またはローカルファイルを指定します。相対パスはコマンドを実行したディレクトリを基準に解決されます。形式は自動判定され、ノードを直接記述した Clash YAML、平文または Base64 の V2Ray リンク一覧、sing-box JSON に対応しています。

| オプション | 用途 |
| --- | --- |
| `-s`, `--subscription` | サブスクリプションの URL またはローカルファイルを指定 |
| `-c`, `--concurrent` | サブスクリプション確認時の最大並列数。既定値は `16` |
| `--format` | サブスクリプション形式。既定値は `auto`。`clash`、`v2ray`、sing-box を指定可能 |
| `--timeout` | 各ノードの確認にかける時間の上限。既定値は `10s`。単一リンクとサブスクリプションの両方に適用 |
| `-h`, `--help` | ヘルプを表示 |

## 結果を確認する

スクリプトはカレントディレクトリに `result.json` を書き込み、新しいレポートを生成するたびに同名ファイルを置き換えます。単一リンクではノードの結果が直接記録され、サブスクリプションでは `results` に入力順で並びます。失敗時は `error.code` と `https.reason` を参照してください。UDP の値が `null` の場合は判定不能です。詳細は `udp4_reason` または `udp6_reason` を参照してください。

スクリプトは `akpig/foxchecker-singbox:latest` を使用します。イメージがローカルにない場合は Docker が取得します。確認が完了または中断すると、スクリプトはコンテナを削除します。失敗時は非ゼロの終了コードを返し、レポートを作成できる場合は失敗理由を記録します。Docker が起動できない場合やコマンドの指定が無効な場合は、以前の `result.json` が残ることがあります。終了コードと端末出力を確認してください。

## イメージをローカルでビルド

Linux amd64 用の Foxchecker 実行ファイルを `foxchecker/foxchecker` に配置し、リポジトリのディレクトリで以下のコマンドを実行します。

```bash
./build.sh
```

ビルドスクリプトは GeoIP データを更新・検証し、ローカルに `foxchecker-singbox:latest` イメージを作成します。確認用スクリプトは上記の Docker Hub イメージを使用します。GeoIP データの帰属表示は [geoip/NOTICE](../geoip/NOTICE) を参照してください。
