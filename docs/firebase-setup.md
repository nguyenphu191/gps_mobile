# Cấu hình Firebase & dịch vụ ngoài

Những việc **không nằm trong code** mà phải làm trên console thì app mới chạy đủ chức năng.
Dự án hiện tại: **TR397-GPSCamera**.

Làm đúng theo thứ tự dưới đây — bước sau phụ thuộc bước trước.

---

## Bước 0 — Tạo dữ liệu mẫu trước (bắt buộc)

Firestore chỉ tạo collection khi có document đầu tiên. Nếu chưa ai gửi vị trí thì
`location_shares` **không tồn tại**. Cần có dữ liệu thật để kiểm chứng rules ở Bước 1 và index ở Bước 2.

Trên máy đã đăng nhập: **Friends → nút 📍 bên cạnh một người bạn đã kết bạn → gửi vị trí.**

Xong bước này, tab **Data** phải thấy đủ 4 collection: `friends`, `location_shares`, `shared_media`, `users`.

---

## Bước 1 — Security rules

Nguồn chuẩn là [`firestore.rules`](../firestore.rules) ở gốc repo — sửa ở đó rồi deploy, đừng chỉ sửa
trong console (sẽ lệch nhau).

```bash
firebase deploy --only firestore:rules
```

Hoặc mở file đó, copy toàn bộ, dán vào Firebase Console → Firestore Database → tab **Rules** → **Publish**.

### Vì sao `users` mở cho mọi người đã đăng nhập đọc

Đây là chủ ý, **không phải sơ suất** — siết lại sẽ làm gãy ba luồng:

- `checkUsernameExists` / `searchUserByUsername` query cả collection theo `username`; cái đầu chạy ngay
  trong lúc đăng ký, khi chưa có hồ sơ nào để đối chiếu quyền.
- `friendProfilesProvider` đọc hồ sơ bạn bè bằng `whereIn` trên document id — rules **không nhìn thấy**
  quan hệ bạn bè nên không thể ràng buộc theo nó.
- `sendLocation` đọc `fcmTokens` của người nhận để gửi push.

Quyền **ghi** thì vẫn khoá chặt: chỉ sửa được document của chính mình.

### Những gì rules KHÔNG bảo vệ được

Ghi ra đây để sau này không ai tưởng đã kín:

- **`fcmTokens` đọc được bởi mọi tài khoản đã đăng nhập.** Muốn kín phải chuyển sang subcollection
  `users/{uid}/private/...` và đổi luồng gửi push (đẩy việc tra token sang Worker).
- **`shared_media` đọc được bởi mọi tài khoản đã đăng nhập**, không chỉ bạn bè. Muốn kín phải ghi thêm
  mảng `sharedWith` (danh sách uid bạn bè lúc upload) rồi ràng buộc
  `request.auth.uid in resource.data.sharedWith` — đổi lại là danh sách bạn bè đóng băng tại thời điểm
  upload, và cần ghi đè lại khi kết bạn mới.
- Cloudinary vẫn tải được nếu ai đó có URL: Cloudinary không kiểm tra đăng nhập.

---

## Bước 2 — Composite index

Query `receivedLocationsStream()` lọc theo `toUid` **và** sắp xếp theo `createdAt`, nên Firestore đòi
composite index.

**Cách nhanh nhất:** chạy app, mở trang "Vị trí được chia sẻ". Log sẽ in
`[cloud_firestore/failed-precondition] The query requires an index. You can create it here: https://...`
— bấm vào link đó, Firebase điền sẵn mọi thứ, chỉ cần bấm **Create index**.

**Cách thủ công:** tab **Indexes** → **Create index**
- Collection ID: `location_shares`
- Field 1: `toUid` — Ascending
- Field 2: `createdAt` — Descending
- Query scope: Collection

Index cần vài phút để chuyển từ *Building* sang *Enabled*. Định nghĩa này cũng nằm sẵn trong
[`firestore.indexes.json`](../firestore.indexes.json) nếu bạn dùng `firebase deploy --only firestore:indexes`.

---

## Bước 3 — Tự xoá sau 24 giờ

> **TTL policy của Firestore đòi gói Blaze.** Trên gói Spark, tạo policy sẽ báo
> `403: Project ... has billing disabled`. Đã thử và không dùng được.

Vì vậy việc dọn dẹp **hoàn toàn nằm ở phía app**, không cần cấu hình gì trên console:

- `receivedLocationsStream()` lọc bỏ mọi share quá 24 giờ → người dùng không bao giờ thấy bản ghi hết hạn.
- `purgeExpiredLocationShares()` xoá hẳn khỏi Firestore, quét **cả hai chiều** (`toUid` và `fromUid`) nên
  bên nào mở app trước thì bên đó dọn. Chạy khi đăng nhập ([`main.dart`](../lib/main.dart)) và khi mở
  trang "Vị trí được chia sẻ".

Cả hai đều ở [`friend_service.dart`](../lib/features/friends/services/friend_service.dart).

**Hệ quả cần chấp nhận:** nếu cả người gửi lẫn người nhận đều không mở app, document nằm lại trên
Firestore quá 24 giờ. Nó vẫn không hiện ra ở đâu, chỉ là chưa bị xoá.

Muốn xoá thật sự tự động mà không nâng Blaze, có một đường: thêm **cron trigger** vào Cloudflare Worker
đang dùng cho push ([`server/push-worker`](../server/push-worker/README.md)) — Worker đã giữ service
account nên gọi được Firestore REST API để xoá các doc `expiresAt < now`. Chưa làm.

Trường `expiresAt` (kiểu Timestamp, = thời điểm gửi + 24 giờ) vẫn được ghi trong
[`location_share_model.dart`](../lib/features/friends/models/location_share_model.dart) — giữ lại để bật
TTL được ngay nếu sau này lên Blaze, và để script dọn dẹp bên ngoài có mốc mà lọc.

---

## Bước 4 — Checklist dịch vụ ngoài

| Hạng mục | Nơi cấu hình | Trạng thái hiện tại |
|---|---|---|
| **Cloudinary cloud name** | [`app_constants.dart`](../lib/core/constants/app_constants.dart) | ✅ `hyqcgkdz` |
| **Cloudinary upload preset** | Cloudinary → Settings → Upload → Upload presets | ⚠️ preset `shared_media` đang là **Signed** → phải đổi sang **Unsigned**, nếu không mọi upload đều bị từ chối |
| **Cloudinary folder** | preset | `shared_media` cho ảnh/video, `avatars` cho ảnh đại diện — preset không được **ép** cứng folder, nếu không avatar sẽ rơi nhầm chỗ |
| **Push endpoint** | [`app_constants.dart`](../lib/core/constants/app_constants.dart) → `pushEndpoint` | ⚠️ đang rỗng → push bị bỏ qua (app vẫn chạy bình thường). Xem [`server/push-worker/README.md`](../server/push-worker/README.md) để deploy |
| **Media delete endpoint** | [`app_constants.dart`](../lib/core/constants/app_constants.dart) → `mediaDeleteEndpoint` | ⚠️ đang rỗng → xoá ảnh/video **không** xoá file trên Cloudinary. Cùng Worker với push |
| **APNs key (iOS)** | Firebase Console → Project settings → Cloud Messaging | Cần upload thì push mới tới được iPhone |
| **Cloud Storage** | — | ❌ Không dùng. Đã chuyển hẳn sang Cloudinary để khỏi phải nâng gói Blaze |

---

## Rác trên Cloudinary

Xoá ảnh/video trong app **có xoá luôn file trên Cloudinary** — đi qua endpoint `/delete` của
[Cloudflare Worker](../server/push-worker/README.md), vì Cloudinary đòi chữ ký bằng `api_secret` mà khoá
đó không được nhúng vào app.

Điều kiện: đã deploy Worker và điền `mediaDeleteEndpoint`. Chưa có thì xoá vẫn xoá khỏi app và khỏi bản đồ
bạn bè, chỉ là file nằm lại trên Cloudinary.

Vẫn có thể sót file trong hai trường hợp: xoá lúc mất mạng, hoặc Worker lỗi. App **không** thử lại (không
đáng phức tạp) mà chỉ ghi log `asset ... left on Cloudinary`. Dọn định kỳ bằng cách liệt kê `public_id`
trong folder `shared_media` rồi so với collection `shared_media` — phần không có document tương ứng thì
xoá, làm tay ở Media Library hoặc bằng script Node chạy trên máy (dùng `api_secret`, **không** commit).
