# foxchecker-singbox

[English](../README.md) · [简体中文](../zh-cn/README.md) · [繁體中文](../zh-hant/README.md) · [日本語](../ja/README.md) · [Русский](../ru-ru/README.md) · [Türkçe](../tr-tr/README.md) · **Tiếng Việt** · [العربية](../ar/README.md) · [فارسی](../fa-ir/README.md) · [اردو](../ur-pk/README.md)

Foxchecker dùng lõi sing-box để kiểm tra các nút proxy trong liên kết chia sẻ và gói đăng ký. Báo cáo gồm khả năng kết nối HTTPS, IP đầu vào, IP đầu ra đo được, quốc gia hoặc vùng theo GeoIP, cùng kết quả riêng cho UDP4 và UDP6. Tập lệnh dùng ảnh dựng sẵn và yêu cầu Docker đang chạy. [Ảnh trên Docker Hub](https://hub.docker.com/r/akpig/foxchecker-singbox)

## Bắt đầu nhanh

Bạn cần Bash, quyền truy cập vào Docker đang chạy vùng chứa Linux và thư mục có thể ghi báo cáo. Ảnh dành cho `linux/amd64`. Docker trên máy ARM phải hỗ trợ chạy vùng chứa amd64. Docker cần truy cập được thư mục báo cáo và tệp đăng ký cục bộ trên máy chủ.

### Chạy trực tiếp từ GitHub

Chạy các lệnh trong thư mục bạn muốn lưu báo cáo. Lệnh tải `singbox-checker.sh` từ nhánh mặc định của kho GitHub. Các đối số sau `bash -s --` được chuyển cho tập lệnh.

```bash
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- 'vmess://…'
curl -fsSL 'https://raw.githubusercontent.com/akpig/foxchecker-singbox/main/singbox-checker.sh' | bash -s -- -s 'https://sub.foxdetector.com/vi-vn/top500/sing-box.json'
```

### Chạy bản cục bộ

Chạy các lệnh từ thư mục kho mã và thay đầu vào mẫu khi cần. Để lưu báo cáo ở nơi khác, chuyển đến thư mục đó rồi gọi tập lệnh bằng đường dẫn tuyệt đối.

#### Kiểm tra một liên kết chia sẻ

```bash
./singbox-checker.sh 'vmess://…'
```

Các lược đồ liên kết được hỗ trợ gồm `vmess://`, `vless://`, `trojan://`, `ss://`, `hysteria2://` (`hy2://`), `tuic://`, `anytls://`. Cơ chế truyền tải khả dụng phụ thuộc vào khả năng hỗ trợ cấu hình nút của sing-box.

#### Kiểm tra gói đăng ký

```bash
./singbox-checker.sh -s 'https://sub.foxdetector.com/vi-vn/top500/sing-box.json'
./singbox-checker.sh -s './sing-box.json' --format sing-box -c 8 --timeout 15s
```

Tùy chọn `-s` nhận URL HTTPS công khai hoặc tệp cục bộ. Đường dẫn tương đối tính từ thư mục hiện tại. Định dạng được nhận diện tự động, hỗ trợ Clash YAML có nút khai báo trực tiếp, danh sách liên kết V2Ray dạng văn bản hoặc Base64 và sing-box JSON.

| Tùy chọn | Công dụng |
| --- | --- |
| `-s`, `--subscription` | Chỉ định URL đăng ký hoặc tệp cục bộ |
| `-c`, `--concurrent` | Số lượt kiểm tra đồng thời tối đa khi dùng gói đăng ký. Mặc định là `16`. |
| `--format` | Định dạng đăng ký. Mặc định là `auto`. Có thể chọn `clash`, `v2ray` hoặc sing-box. |
| `--timeout` | Thời hạn kiểm tra mỗi nút. Mặc định là `10s`, áp dụng cho cả liên kết đơn lẻ và gói đăng ký. |
| `-h`, `--help` | Hiển thị trợ giúp |

## Xem kết quả

Tập lệnh ghi `result.json` vào thư mục hiện tại và thay thế tệp mỗi khi tạo báo cáo mới. Báo cáo cho một liên kết ghi trực tiếp kết quả của nút. Báo cáo cho gói đăng ký liệt kê kết quả theo thứ tự đầu vào trong `results`. Khi kiểm tra thất bại, xem `error.code` và `https.reason`. Giá trị UDP là `null` nếu chưa thể kết luận. Xem `udp4_reason` hoặc `udp6_reason` để biết chi tiết.

Tập lệnh dùng `akpig/foxchecker-singbox:latest`. Docker sẽ tải ảnh nếu máy chưa có. Tập lệnh xóa vùng chứa khi lượt kiểm tra kết thúc hoặc bị gián đoạn. Nếu kiểm tra thất bại, tập lệnh trả mã thoát khác 0 và ghi lý do khi có thể tạo báo cáo. Nếu Docker không khởi động được hoặc lệnh không hợp lệ, `result.json` cũ có thể vẫn còn. Hãy kiểm tra mã thoát và thông báo trên thiết bị đầu cuối.

## Dựng ảnh cục bộ

Đặt tệp thực thi Foxchecker cho Linux amd64 tại `foxchecker/foxchecker`, rồi chạy lệnh sau từ thư mục kho mã.

```bash
./build.sh
```

Tập lệnh dựng cập nhật và xác minh dữ liệu GeoIP, sau đó tạo ảnh cục bộ `foxchecker-singbox:latest`. Tập lệnh kiểm tra dùng ảnh Docker Hub được liên kết ở trên. Xem [geoip/NOTICE](../geoip/NOTICE) để biết nguồn dữ liệu GeoIP.
