# foxchecker-singbox

[English](../README.md) · [简体中文](../zh-cn/README.md) · [繁體中文](../zh-hant/README.md) · [日本語](../ja/README.md) · [Русский](../ru-ru/README.md) · **Türkçe** · [Tiếng Việt](../vi-vn/README.md) · [العربية](../ar/README.md) · [فارسی](../fa-ir/README.md) · [اردو](../ur-pk/README.md)

Foxchecker, paylaşım bağlantılarındaki ve aboneliklerdeki proxy düğümlerini denetlemek için sing-box çekirdeğini kullanır. Raporlarda HTTPS bağlantısı, giriş IP adresi, ölçülen çıkış IP adresi, GeoIP ülke veya bölgesi ve ayrı UDP4 ile UDP6 sonuçları yer alır. Betik önceden oluşturulmuş bir imaj kullanır ve Docker'ın çalışmasını gerektirir. [Docker Hub imajı](https://hub.docker.com/r/akpig/foxchecker-singbox)

## Hızlı başlangıç

Bash, Linux kapsayıcıları çalıştırabilen bir Docker motoruna erişim ve yazılabilir bir rapor dizini gerekir. İmaj `linux/amd64` içindir. ARM ana makinelerinde Docker, amd64 kapsayıcılarını çalıştırabilmelidir. Docker motoru ana makinedeki rapor dizinine ve yerel abonelik dosyasına erişebilmelidir.

### Doğrudan GitHub'dan çalıştırma

Komutları raporu kaydetmek istediğiniz dizinde çalıştırın. Komutlar, GitHub deposunun varsayılan dalından `singbox-checker.sh` dosyasını indirir. `bash -s --` sonrasındaki argümanlar betiğe iletilir.

```bash
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- 'vmess://…'
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- -s 'https://sub.foxdetector.com/tr-tr/top500/sing-box.json'
```

### Yerel kopyayı çalıştırma

Aşağıdaki komutları depo dizininde çalıştırın ve örnek girdileri gerektiğinde değiştirin. Raporu başka bir dizine kaydetmek için o dizine geçin ve betiği mutlak yoluyla çalıştırın.

#### Tek bir paylaşım bağlantısını denetleme

```bash
./singbox-checker.sh 'vmess://…'
```

Desteklenen bağlantı şemaları şunlardır: `vmess://`, `vless://`, `trojan://`, `ss://`, `hysteria2://` (`hy2://`), `tuic://`, `anytls://`. Kullanılabilir taşıma yöntemleri sing-box'nun düğüm yapılandırmasına verdiği desteğe bağlıdır.

#### Aboneliği denetleme

```bash
./singbox-checker.sh -s 'https://sub.foxdetector.com/tr-tr/top500/sing-box.json'
./singbox-checker.sh -s './sing-box.json' --format sing-box -c 8 --timeout 15s
```

`-s`, herkese açık bir HTTPS adresini veya yerel bir dosyayı kabul eder. Göreli yollar geçerli dizine göre çözülür. Biçim otomatik algılanır. Satır içi düğümler içeren Clash YAML, düz metin veya Base64 V2Ray bağlantı listeleri ve sing-box JSON desteklenir.

| Seçenek | İşlev |
| --- | --- |
| `-s`, `--subscription` | Abonelik adresini veya yerel dosyayı belirtir |
| `-c`, `--concurrent` | Abonelik denetimlerinde eşzamanlı düğüm üst sınırı. Varsayılan `16`. |
| `--format` | Abonelik biçimi. Varsayılan `auto`. `clash`, `v2ray` veya sing-box seçilebilir. |
| `--timeout` | Düğüm başına zaman aşımı. Varsayılan `10s`. Paylaşım bağlantıları ve abonelikler için geçerlidir. |
| `-h`, `--help` | Yardımı gösterir |

## Sonuçları okuma

Betik `result.json` dosyasını geçerli dizine yazar ve her yeni raporda dosyayı değiştirir. Tek bağlantı raporu düğüm sonucunu doğrudan içerir. Abonelik raporu sonuçları `results` altında girdi sırasına göre listeler. Başarısız denetimler için `error.code` ve `https.reason` alanlarına bakın. UDP değeri `null` ise kesin sonuç alınamamıştır. Ayrıntılar `udp4_reason` veya `udp6_reason` alanındadır.

Betik `akpig/foxchecker-singbox:latest` imajını kullanır. İmaj yerelde yoksa Docker onu indirir. Denetim tamamlandığında veya kesintiye uğradığında betik kapsayıcıyı kaldırır. Başarısız denetim sıfırdan farklı bir çıkış kodu döndürür ve rapor üretilebilirse başarısızlık nedenini kaydeder. Docker başlatılamazsa veya komut hatalıysa eski `result.json` yerinde kalabilir. Çıkış kodunu ve terminal çıktısını kontrol edin.

## İmajı yerelde oluşturma

Linux amd64 Foxchecker çalıştırılabilir dosyasını `foxchecker/foxchecker` yoluna yerleştirin ve depo dizininde aşağıdaki komutu çalıştırın.

```bash
./build.sh
```

Derleme betiği GeoIP verilerini günceller, doğrular ve yerel `foxchecker-singbox:latest` imajını oluşturur. Denetim betiği yukarıda bağlantısı verilen Docker Hub imajını kullanır. GeoIP kaynak bilgisi [geoip/NOTICE](../geoip/NOTICE) dosyasındadır.
