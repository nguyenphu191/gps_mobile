# Worker (Cloudflare) — push + xoá Cloudinary

Worker này giữ hai khoá **không được phép nằm trong app** (ai cũng dịch ngược APK
lấy được) và chỉ làm hai việc:

| Endpoint | Việc | Vì sao cần server |
|---|---|---|
| `POST /` hoặc `/push` | Gửi FCM push | FCM v1 đòi request ký bằng **service account** |
| `POST /delete` | Xoá một asset Cloudinary | Cloudinary destroy đòi chữ ký bằng **api_secret** |

Chạy trên Cloudflare Workers **free tier** (100k request/ngày, không cần thẻ) —
thay cho Cloud Functions vốn đòi gói Blaze.

## Deploy

```bash
npm install -g wrangler
wrangler login
cd server/push-worker
wrangler deploy
```

`wrangler.toml`:

```toml
name = "gpscamerastamp-push"
main = "worker.js"
compatibility_date = "2024-11-01"
```

## Secrets

Firebase Console → Project settings → **Service accounts** → *Generate new
private key* → mở file JSON để lấy 3 giá trị đầu:

```bash
# Từ file service-account JSON
wrangler secret put FIREBASE_PROJECT_ID    # "project_id"
wrangler secret put FIREBASE_CLIENT_EMAIL  # "client_email"
wrangler secret put FIREBASE_PRIVATE_KEY   # "private_key" (giữ nguyên cả \n)

# Firebase Console > Project settings > General > Web API Key
wrangler secret put FIREBASE_WEB_API_KEY

# Cloudinary Dashboard (Product Environment Credentials)
wrangler secret put CLOUDINARY_CLOUD_NAME  # hyqcgkdz
wrangler secret put CLOUDINARY_API_KEY
wrangler secret put CLOUDINARY_API_SECRET
```

File JSON đó **không được commit** vào repo.

## Nối vào app

Trong [app_constants.dart](../../lib/core/constants/app_constants.dart), với
`https://gpscamerastamp-push.<account>.workers.dev` là URL Worker:

```dart
static const String pushEndpoint = 'https://.../push';
static const String mediaDeleteEndpoint = 'https://.../delete';
```

Để trống endpoint nào thì tính năng đó bị bỏ qua, phần còn lại vẫn chạy bình thường:
không có `pushEndpoint` thì bạn bè không nhận thông báo; không có `mediaDeleteEndpoint`
thì xoá ảnh vẫn xoá khỏi app và khỏi bản đồ bạn bè, chỉ là file còn nằm trên Cloudinary.

## Cần làm thêm cho iOS

Push trên iOS chỉ hoạt động khi đã bật **Push Notifications** + **Background
Modes → Remote notifications** trong Xcode, và upload **APNs Auth Key** lên
Firebase Console → Cloud Messaging. Android không cần bước nào thêm.

## Bảo vệ endpoint `/delete`

Đây là endpoint nguy hiểm nhất (xoá được file), nên nó kiểm hai lớp:

1. Bắt buộc có `Authorization: Bearer <Firebase ID token>`; Worker đổi token lấy uid
   qua Identity Toolkit. Không có hoặc token sai → **401**.
2. Quyền sở hữu suy ra **từ chính `public_id`**, không tin gì ở client: chỉ xoá được
   `shared_media/<uid>/...` hoặc `avatars/<uid>`. Khác đi → **403**.

Thử nhanh:

```bash
curl -X POST https://.../delete -H 'Content-Type: application/json' \
  -d '{"publicId":"shared_media/aaa/bbb"}'          # -> 401
curl -X POST https://.../delete -H "Authorization: Bearer $ID_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"publicId":"shared_media/<uid-nguoi-khac>/x"}'  # -> 403
```

## Giới hạn đã biết

`/push` **không xác thực** — ai biết URL đều gọi được để gửi push tới một token mà họ
có sẵn. Token FCM không công khai nên rủi ro thấp; muốn siết thì áp cùng cách kiểm
ID token như `/delete`.
