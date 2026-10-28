# LocaShot GPS – Bộ prompt thiết kế lại UI cho Stitch AI (mỗi màn 1 prompt)

## Cách dùng
1. Dán prompt của **từng màn** vào Stitch (mỗi lần 1 màn, thiết bị: Mobile/iOS).
2. Mỗi prompt đã kèm sẵn đoạn **[DS]** (design system) để các màn đồng bộ, không cần dán riêng.
3. Nếu Stitch cho upload ảnh tham chiếu: dùng màn Home làm chuẩn phong cách cho các màn sau.

## Design System – "Aurora Pop" (nguồn của đoạn [DS])
- **Cảm giác:** trẻ trung, năng động, du lịch/khám phá, Gen Z; sáng, nhiều gradient, kính mờ (glassmorphism), bo góc lớn, đổ bóng màu mềm.
- **Màu:** Primary Electric Violet `#7C3AED`; Secondary Hot Pink `#FF4D8D`; Accent Aqua `#22D3EE`; Sunny `#FFC94D`; Mint `#2DD4BF`. Gradient chính: `#7C3AED → #FF4D8D` (135°). Gradient phụ: `#22D3EE → #7C3AED`.
- **Nền:** sáng `#F7F5FF` (thẻ trắng `#FFFFFF`); tối `#0E0B1F` (thẻ `#1A1533`). Chữ chính `#1B1535`, phụ `#6B6486`. Lỗi `#FF4757`, thành công `#22C55E`.
- **Font:** Plus Jakarta Sans (tiêu đề ExtraBold 800, body Medium 500). Tiêu đề 24–28, body 14–15.
- **Hình khối:** card bo 24, nút bo 999 (pill) hoặc 18, ô nhập bo 16, bottom sheet bo 32 phía trên. Bóng màu tím mờ `0 12 30 rgba(124,58,237,.18)`.
- **Icon:** bộ rounded 2px stroke, nền icon là ô tròn/squircle pastel. Thêm sticker/emoji nhỏ cho vui mắt.
- **Hiệu ứng:** glass blur 20 trên overlay, blob gradient mờ ở nền, viền sáng 1px trắng 40%, micro-animation (scale khi nhấn, fade-slide khi vào, shimmer khi load).

---

# PHẦN A – KHỞI ĐỘNG & ONBOARDING

## 1. Splash
```
Design a mobile splash screen for "LocaShot GPS", a photo/video app that stamps location, time and coordinates on pictures. Style "Aurora Pop": young, vibrant, playful.
Background: full-screen soft gradient from #F7F5FF to #EDE4FF with two large blurred blobs (violet #7C3AED at top-left, hot pink #FF4D8D at bottom-right, 30% opacity).
Center: a rounded-square app logo (128px, radius 36) with violet→pink gradient, a white camera-lens icon with a small location pin on its corner, soft violet glow shadow, and 3 tiny floating sparkles/pins around it.
Below the logo: app name "LocaShot GPS" in Plus Jakarta Sans ExtraBold 26, color #1B1535, with "GPS" in gradient text. Tagline under it: "Stamp every moment with where it happened" 14px, #6B6486.
Bottom: a thin 6px rounded progress bar (track #E6DEFF, fill violet→pink gradient, about 60% filled) and a small caption "This action can contain ads" 11px #9A93B5.
Include subtle animation notes: logo pops with scale 0.8→1 and gentle floating, progress bar fills in 2.5s.
Design tokens: card radius 24, pill buttons, font Plus Jakarta Sans.
```

## 2. Chọn ngôn ngữ (lần đầu)
```
Design a first-launch "Choose language" screen for the mobile app "LocaShot GPS". Style "Aurora Pop": young, vibrant, glassy, rounded.
Background #F7F5FF with blurred violet (#7C3AED) and aqua (#22D3EE) blobs at the corners.
Header: a cute 3D-style globe emoji in a gradient circle, title "What's your language?" (Plus Jakarta Sans ExtraBold 26, #1B1535), subtitle "Pick one to personalise your experience" 14px #6B6486.
Body: 2-column grid of language cards (English, Tiếng Việt, 日本語, 한국어, 中文, Português, العربية, हिन्दी). Each card: white, radius 22, soft violet shadow, big round flag (36px) on the left, language name bold 15 and native name 12 grey. Selected card: violet→pink gradient border 2px, light violet fill #F3EBFF, small gradient check badge at the top-right corner, slight scale-up. Show "English" selected.
Bottom (above a native-ad slot placeholder of about 120px height, dashed light border labeled "Ad"): a full-width pill button "Continue →" 56px high with violet→pink gradient, white bold text, glow shadow. (Disabled variant would be #E6E2F2 with grey text.)
Font Plus Jakarta Sans, radius 24 cards, pill button, glass feel.
```

## 3. Dialog "Please Select a Language"
```
Design a small alert dialog over a dimmed and blurred language-selection screen for the app "LocaShot GPS". Style "Aurora Pop".
Dialog: white card, radius 28, width 300, centered, violet soft shadow. Top: a 72px circle with sunny gradient (#FFC94D→#FF9F43) holding a white translate/language icon, with tiny confetti sparkles.
Title "Please Select a Language" ExtraBold 20 #1B1535, centered. Subtitle "Choose a language to continue" 14px #6B6486.
Button: full-width pill "OK" 52px, violet→pink gradient, white bold text.
Backdrop: black 40% with blur 12. Font Plus Jakarta Sans.
```

## 4. Intro / Onboarding (1 màn – slide đang hiển thị, mô tả cả trạng thái slide)
```
Design an onboarding slide screen for "LocaShot GPS" (4-slide pager; design slide 1 "GPS Camera & Timestamp"). Style "Aurora Pop": young, vibrant.
Background: #F7F5FF with a large soft gradient blob (violet→pink) behind the illustration.
Top-right: "Skip" text button, grey. Top: title "GPS Camera & Timestamp" ExtraBold 24 #1B1535 centered, description "Stamp every photo with its location, date and time." 14px #6B6486 centered (max 2 lines).
Center: hero illustration in a rounded card (radius 32, 300px tall): a tilted smartphone showing a travel photo with a translucent glass stamp at the bottom (pin icon, "21.0285, 105.8542", "Hanoi, Vietnam", date/time), floating sticker chips around it (📍, 🕒, ✨) with gentle float animation.
Below: page dots — active dot is a 28px pill with violet→pink gradient, inactive dots 8px #D9D0F5.
Bottom: an ad slot placeholder (about 25% of height, dashed border, "Ad") and a full-width pill button "Continue" (last slide says "Get Started") 56px, violet→pink gradient, white text, glow.
Font Plus Jakarta Sans, radius 24, glassmorphism accents.
```

## 5. Đăng nhập / Đăng ký
```
Design a Sign in / Register screen for "LocaShot GPS". Style "Aurora Pop": young, vibrant, friendly.
Background #F7F5FF with a top header area filled with a violet→pink gradient blob shape (curved bottom) and floating pin/camera stickers.
Top-left: circular white back button 44px with soft shadow. Header text on the gradient: "Sign in" ExtraBold 28 white, subtitle "Welcome back! Capture your journey." 14px white 85%.
Form card (white, radius 28, overlapping the header, violet shadow): fields with icons and radius 16, fill #F7F5FF, focus border violet 2px — Email (mail icon), Password (lock icon, eye toggle). For Register mode add Username (user icon) at top. "Forgot password?" small link in violet on the right.
Primary pill button "Sign in" 56px, violet→pink gradient, glow. Under it: toggle text "Need an account? **Register**" (bold violet).
Divider "or continue with" with lines; two side-by-side outlined pill buttons with Google and Apple logos (white fill, 1px border #E6DEFF, height 52).
Font Plus Jakarta Sans, radius 24.
```

## 6. Thiết lập Username
```
Design a "Choose your username" screen for "LocaShot GPS". Style "Aurora Pop".
Background #F7F5FF with a soft aqua/violet blob top-right. Top: circular back button. Center-top: a large avatar placeholder circle (96px) with violet→pink gradient ring and a camera badge, emoji sparkles.
Title "Pick a username" ExtraBold 26, hint "Friends will find you with this name. 3–20 letters, numbers or _" 14px grey.
Input: large field radius 18, white, with an "@" prefix in a violet circle, live validation row below (green check "Available" state shown). Character counter on the right.
Bottom pill button "Save" 56px violet→pink gradient (disabled variant #E6E2F2).
Font Plus Jakarta Sans.
```

---

# PHẦN B – TAB CHÍNH

## 7. Home
```
Design the Home tab of "LocaShot GPS" (photo/video GPS stamp, street view, traffic, nearby places, destinations). Style "Aurora Pop": young, vibrant, glassy. Background #F7F5FF with faint blurred blobs.
Top bar: left greeting "Hello, explorer 👋" 13px grey and app title "GPS Camera" ExtraBold 24 (GPS in violet→pink gradient text). Right: a white circular bell button with a pink notification badge.
Hero banner (radius 32, height ~200): violet→pink gradient with glowing circles, 3D-style camera + map-pin illustration on the right, text "Capture Every Journey" ExtraBold 22 white and "GPS stamped photos with location info" 13px white 85%, and a white pill button "📷 Capture Now" with gradient text and soft glow.
Quick actions: 3 squircle cards in a row (white, radius 24, shadow) each with a pastel gradient icon tile: "GPS Video" (aqua), "Street View" (sunny), "Traffic Map" (mint), label bold 12.
Section "Location nearby you" + "View all" violet link; horizontal scroll of pill chips with emoji icons: ⛽ Petrol, 🏧 ATM, ☕ Cafe, 🏨 Hotel, each a different pastel color.
Section "Popular Destination" + "View all": large swipeable cards (radius 28, 220px tall, photo with dark-to-transparent gradient), rating chip ★ 4.8 glass, country with pin, name ExtraBold 20 white, dots indicator with gradient active pill.
Ad slot placeholder below. Floating bottom navigation bar visible (glass pill, 4 tabs: Home active, Gallery, Friends, Settings).
Font Plus Jakarta Sans.
```

## 8. Thanh điều hướng dưới (component, hiển thị trên nền)
```
Design a floating bottom navigation bar component for the mobile app "LocaShot GPS", shown on a #F7F5FF screen. Style "Aurora Pop".
Floating glass pill, 68px high, radius 34, margin 16 from sides and 12 from bottom, white 80% with blur, 1px white border, violet shadow.
4 tabs: Home, Gallery, Friends, Settings. Active tab: a violet→pink gradient rounded pill capsule behind the icon with a white filled icon and label slides in next to it (bold 12); inactive: outline icon in #9A93B5, no label. Show a small pink dot badge on Friends.
Also include a raised circular gradient camera FAB (64px) centered above the bar as an optional variant.
Font Plus Jakarta Sans.
```

## 9. Gallery – dạng lưới
```
Design the Gallery tab (grid mode) of "LocaShot GPS". Style "Aurora Pop": young, vibrant.
Background #F7F5FF. Header: title "Gallery" ExtraBold 26 and on the right a gradient pill toggle "🗺 Show on Map" (violet→pink, white text, 40px high).
Filter row: scrolling chips "All" (selected: gradient fill white text), "Photos", "Videos" (white fill, border #E6DEFF), and a circular sort button opening a menu.
Body: 3-column masonry-like grid with 8px gaps, thumbnails radius 18 of travel photos; small glass badge bottom-left with pin + city, video items have a white play badge and duration, friends' media have a tiny avatar ring in the top-right corner (gradient ring). Pull-to-refresh indicator style with a small gradient spinner.
Ad slot placeholder at the bottom of the list. Floating glass bottom nav with Gallery active.
Font Plus Jakarta Sans, radius 24.
```

## 10. Gallery – trạng thái trống
```
Design the empty state of the Gallery tab in "LocaShot GPS". Style "Aurora Pop".
Background #F7F5FF, header "Gallery" with the toggle pill on the right, filter chips row.
Center: a friendly illustration — a big gradient camera with polaroid photos and a map pin flying out, soft blobs behind. Title "No Photos Yet" ExtraBold 22, subtitle "Take your first photo with GPS coordinates" 14px grey centered.
CTA pill button "📷 Take a photo" 52px violet→pink gradient. Also an optional red-tinted error banner variant (#FFF0F3 with #FF4757 text and refresh icon) shown on top: "Couldn't load friends' media".
Floating glass bottom nav, Gallery active. Font Plus Jakarta Sans.
```

## 11. Friends
```
Design the Friends tab of "LocaShot GPS". Style "Aurora Pop": young, social, fun.
Background #F7F5FF. Header: "Friends" ExtraBold 26 and a circular gradient button with a person-plus icon on the right.
Section "Received locations" with orange-pink pin icon and "View all" link: horizontal cards (glass white, radius 24) with avatar, "Shared by Linh", location name, time ago, small "Open map" pill.
Friends list: cards radius 24 white with shadow, avatar (52px, gradient ring if online), name bold, last location grey with pin, right side two small pills: "View" (outlined violet) and "Send" (gradient fill; alternate state "Sent ✓" mint). Show swipe-to-delete revealing a red rounded action.
Include a mini empty-state variant note: illustration of friends group with "Add friend" gradient button.
Floating glass bottom nav, Friends active. Font Plus Jakarta Sans.
```

## 12. Settings
```
Design the Settings tab of "LocaShot GPS". Style "Aurora Pop".
Background #F7F5FF. Title "Settings" ExtraBold 26.
Top account card (radius 28, violet→pink gradient, glass shine): avatar 64px with white ring, name, email, chevron in white. (Signed-out variant: app logo and a white pill "Sign in".)
Optional Premium banner card (sunny gradient #FFC94D→#FF9F43, crown icon, "Upgrade Pro – Ad-free · 4K · GPS Photo Export", arrow) .
Section "General": rounded white group card with row "Language" (squircle aqua icon, current language "English", chevron).
Section "About": rows "Privacy Policy" (squircle violet icon) and "Share App" (squircle pink icon); row height 60, dividers inset.
Bottom: full-width soft pill button "Sign out" (#FFE9EE fill, #FF4757 text), and "v1.0.1" caption centered grey.
Floating glass bottom nav, Settings active. Font Plus Jakarta Sans.
```

---

# PHẦN C – CAMERA

## 13. Camera ảnh (live)
```
Design the live photo camera screen of "LocaShot GPS" that stamps location, coordinates and time on photos. Style "Aurora Pop" over a full-screen camera viewfinder (use a scenic travel photo as the preview).
Top row over the preview: circular glass back button (44px, blur, white icon) on the left; on the right a glass flash button (⚡) and a switch-camera button.
Bottom overlay: dark-to-transparent gradient with a frosted glass "stamp card" (radius 24) showing: pin icon + address "12 Nguyen Trai, Hanoi, Vietnam" bold white 14; a row with a target icon "Lat 21.02851 · Lon 105.85420"; a row with a clock icon "2026-09-30 14:32:10" monospace. Include a small amber tappable chip variant "📍 Enable location".
Capture control: 84px white ring with inner violet→pink gradient circle, glow, small gallery thumbnail on the left and a mode toggle (Photo / Video) pill on the right.
Optional rule-of-thirds grid at 15% opacity. Font Plus Jakarta Sans.
```

## 14. Xem trước ảnh sau khi chụp
```
Design the photo preview screen right after capture in "LocaShot GPS". Style "Aurora Pop".
Full-screen dark background #0E0B1F with the captured photo fitted, showing a stamped black glass band at the bottom of the image (3 white lines: date-time, "Lat/Lon", address).
Top-left: circular glass close (X) button. Top-right: small glass chip "Stamped ✓" mint.
Bottom bar (glass, radius 32 top, blur): two buttons side by side — "↻ Retake" outlined white pill, "✓ Save" violet→pink gradient pill with glow, both 56px high.
Include a success state variant: a toast pill "Photo saved to library ✓" in mint at the top with confetti sparkle. Font Plus Jakarta Sans.
```

## 15. Camera – chưa cấp quyền
```
Design a "camera access not enabled" state screen for "LocaShot GPS". Style "Aurora Pop".
Background #F7F5FF with blurred violet/pink blobs. Center: illustration of a cute camera with a locked padlock in a gradient circle (120px). Title "Camera access is not enabled" ExtraBold 22 centered, hint "Allow camera and location so we can stamp your photos." 14px grey.
Buttons: primary pill "Open Settings" 56px violet→pink gradient; secondary text button "Not now".
Top-left circular back button. Font Plus Jakarta Sans.
```

## 16. Dialog quyền vị trí
```
Design a location-permission dialog for "LocaShot GPS" over a dimmed, blurred home screen. Style "Aurora Pop".
White card radius 28, top has a 76px gradient circle (aqua→violet) with a white location-off icon and small pulse rings. Title "Location is turned off" ExtraBold 20, body "Turn on location to add coordinates and address to your photos." 14 grey centered.
Two buttons stacked: "Open Settings" gradient pill 52px, "Cancel" text button grey. Font Plus Jakarta Sans.
```

## 17. Camera video (đang quay)
```
Design the video recording screen of "LocaShot GPS" with a live GPS overlay. Style "Aurora Pop" over a full-screen viewfinder photo.
Top: circular glass close (X) at left; center a glass pill with a pulsing red dot "REC" and countdown "00:24 / 01:00"; at right a flash button. Below the top row a thin gradient progress line for recording length.
Overlay bottom-left glass stamp card: pin + address, coordinates, live timestamp.
Bottom controls: gallery shortcut (rounded thumbnail 48px) on the left, big record button 84px (white ring with red-pink gradient square/circle inside; recording state shows rounded stop square), flip-camera glass button on the right.
Hint under: "Max 60 seconds" small white 70%. Font Plus Jakarta Sans.
```

## 18. Xem trước video
```
Design the video preview screen (after recording) of "LocaShot GPS". Style "Aurora Pop".
Dark #0E0B1F background, video fitted in the center with rounded corners 24, a big glass play button in the middle, a scrubber bar with gradient progress and times 00:00 / 00:24.
Top-left circular close button. Bottom: two buttons — "✕ Cancel" outlined white pill and "✓ Save" violet→pink gradient pill, 56px high. Font Plus Jakarta Sans.
```

## 19. Thư viện video
```
Design the Video Gallery screen of "LocaShot GPS". Style "Aurora Pop".
Background #F7F5FF. Top: circular back button, title "Video Gallery" ExtraBold 22.
Body: 2-column grid of video cards (radius 24, white, shadow): thumbnail, center glass play button, duration chip bottom-right, below the thumbnail city name with pin and date in grey.
Add an empty-state variant: illustration of a clapperboard with pin, text "No videos yet", button "Record a video" gradient pill. Font Plus Jakarta Sans.
```

## 20. Chi tiết video
```
Design the Video Detail (player) screen of "LocaShot GPS". Style "Aurora Pop".
Dark #0E0B1F background. Top: back button and glass action icons (street view, share, delete). Center: video player radius 24 with play/pause overlay and gradient scrubber.
Below: info card (glass dark, radius 24) with address, coordinates and date-time rows with pastel icon tiles, and a "View Street View" gradient pill button.
Include a delete confirmation dialog variant: white card radius 28, red trash icon circle, "Delete video?" with "Cancel" and red "Delete" buttons. Font Plus Jakarta Sans.
```

---

# PHẦN D – ẢNH & BẢN ĐỒ

## 21. Gallery – chế độ bản đồ
```
Design the Gallery tab in map mode for "LocaShot GPS". Style "Aurora Pop".
Full map background (clean light map with soft pastel tones) with clustered photo markers: round thumbnails 48px with white ring and gradient border, cluster bubbles with count (violet→pink gradient, white bold number), video marker with a play badge.
Top glass overlay: title "Gallery" and gradient pill toggle "▦ Show Grid". Below: filter chips row (All, Photos, Videos, Mine, Friends) glass style, selected = gradient. A glass badge "128 photos" and friends' avatar strip to jump to their location.
Bottom-right circular gradient filter FAB (calendar/filter icon) and a date-range chip with an X. Floating glass bottom nav (Gallery active). Font Plus Jakarta Sans.
```

## 22. Bottom sheet ảnh/video trên bản đồ
```
Design a media bottom sheet that opens over the map in "LocaShot GPS". Style "Aurora Pop".
Sheet: white, top radius 32, drag handle, over a dimmed map. Content: large thumbnail (radius 24, 180px tall) with optional play overlay, "Shared by Linh" chip with avatar for friends' media, address bold 15 with pin, time grey.
Actions row: wide gradient pill "View detail" (52px), then two square 52px icon buttons: street view (aqua tint) and delete (red tint #FFF0F3) — delete only for own media.
Font Plus Jakarta Sans.
```

## 23. Chi tiết ảnh
```
Design the Photo Detail screen of "LocaShot GPS". Style "Aurora Pop".
Top: hero photo (full width, ~55% height, radius 0 with bottom radius 32) that collapses on scroll; overlaid circular glass back button and glass share button.
Below overlapping card (white, radius 32): address row with gradient pin tile and address bold 16. Three info tiles in a row (pastel): Date (calendar, violet), Time (clock, pink), Coordinates (target, aqua) with values.
Section "Location on map": rounded 24 mini map with a gradient pin marker.
Bottom action bar (glass floating): Share, Open in Map, Street View, Delete (red tint), each icon in a squircle with a small label.
Include "Photo not found" state note and delete confirmation dialog variant (radius 28, "Delete photo?"). Font Plus Jakarta Sans.
```

## 24. Map gallery (toàn màn hình)
```
Design the full-screen Map Gallery screen (opened from a photo or notification) in "LocaShot GPS". Style "Aurora Pop".
Full-screen pastel map with clustered thumbnail markers and count bubbles (violet→pink gradient). Top-left circular glass back button. Filter chips (All, Photos, Videos, Mine, Friends) in a glass row, date-range chip with X, photo-count glass badge.
Bottom-right: circular gradient filter FAB. A selected marker enlarged with a pulse ring and callout preview card (thumbnail + address) above it. Font Plus Jakarta Sans.
```

## 25. Lịch sử GPS
```
Design the GPS History screen of "LocaShot GPS". Style "Aurora Pop".
Background #F7F5FF. App bar: back button, title "GPS History", refresh icon button (circular).
Top: route map card (radius 28, 220px) showing a dotted gradient violet→pink path with start (mint) and end (pink) markers and small glass stats chips ("12.4 km", "8 places").
Below: vertical timeline: gradient line on the left with dot nodes; each entry a white card radius 20 with time chip, place name bold, address grey, tiny thumbnail if any; date group headers ("Today", "Yesterday") as pill labels.
Empty-state variant: timeline illustration, "No history yet", description. Font Plus Jakarta Sans.
```

---

# PHẦN E – KHÁM PHÁ

## 26. Explore nearby
```
Design the "Explore nearby" screen of "LocaShot GPS". Style "Aurora Pop".
Background #F7F5FF. Top: circular back button, title "Explore nearby" ExtraBold 24, hint "Tap a category to open it in Maps" grey.
Body: 2-column grid of category cards (radius 24, white, shadow), each with a big pastel gradient circle holding a colorful 3D-style icon and a bold label: Petrol, Hospital, School, Restaurant, Cafe, Hotel, Supermarket, Bank, Police, Stadium. Each card has a distinct pastel tint and a small arrow-up-right chip. Press state slightly scaled.
Font Plus Jakarta Sans.
```

## 27. Tất cả điểm đến
```
Design the "Popular Destinations" list screen of "LocaShot GPS". Style "Aurora Pop".
Header: back button, title "Popular Destinations" ExtraBold 24, subtitle "48 places to explore" grey.
Region filter chips: All (gradient selected), Asia, Europe, Americas, Africa, Oceania.
List: big cards (radius 28, 150px tall) with photo on the left half or full-bleed with dark gradient, rating chip ★, country with pin, name ExtraBold 18, short tags; heart button glass. Empty-state variant: "No destinations". Font Plus Jakarta Sans.
```

## 28. Chi tiết điểm đến
```
Design a Destination Detail screen (e.g., "Ha Long Bay, Vietnam") in "LocaShot GPS". Style "Aurora Pop".
Hero image top 45% with circular glass back and heart buttons and page indicator. Overlapping white sheet (top radius 32): title ExtraBold 24, country with pin, rating chip; expandable "About" text with "Read more" violet.
Photo gallery horizontal strip (radius 18); prominent "360° View" gradient pill button. Two info tiles: Best Time (sun icon, sunny tint), Climate (cloud, aqua tint). "Top Highlights" chips/list with numbered gradient badges. GPS Coordinates card with mini map.
Sticky bottom glass bar: Street View (icon button), Earth 3D (icon button), and large gradient "Directions" pill. Font Plus Jakarta Sans.
```

## 29. La bàn / Chỉ đường
```
Design a "Direction" screen with a compass for "LocaShot GPS". Style "Aurora Pop".
Background: soft violet→#F7F5FF gradient. Top: back button and destination name.
Center: a large glassy compass (280px) with a violet→pink ring, tick marks, an arrow pointing to the destination glowing pink, N/E/S/W labels. Below: info card (radius 28) with bearing "128° SE" and distance "2,450 km" in large ExtraBold numerals with icon tiles.
Bottom: gradient pill "Go to map". Font Plus Jakarta Sans.
```

## 30. Panorama 360°
```
Design the 360° View (panorama) screen of "LocaShot GPS". Style "Aurora Pop" dark.
Full-screen immersive panorama photo. Top: glass app bar with back button, title "360° View", and an "open in Street View" glass icon. Bottom-center: glass hint pill "Drag to look around ↔" with a small rotating-360 icon. Loading state: gradient circular spinner over a dark blurred photo; unavailable state: illustration and text "360° not available here". Font Plus Jakarta Sans.
```

## 31. Street View search
```
Design the Street View search screen of "LocaShot GPS". Style "Aurora Pop".
Full map background (pastel). Top: circular glass back button and a large white search field (radius 22, shadow) with search icon, hint "Search a place for Street View", clear (x) button. Under it a results card list (white radius 24): each row with aqua pin tile, place name bold, address grey; states "Searching…" (shimmer) and "No results".
Map center marker: gradient pin with pulse ring. Bottom glass panel: hint "Tap the map to choose a spot" and gradient pill "Open Street View" with street-view icon. Font Plus Jakarta Sans.
```

## 32. Traffic Map
```
Design the Traffic Map screen of "LocaShot GPS". Style "Aurora Pop".
Full map with vivid traffic lines (green, orange, red, dark red). Top: circular glass back button and a glass title card "Traffic Map" with subtitle "Live traffic near you".
Bottom-left glass legend card (radius 20): dots Free (green), Slow (orange), Heavy (red), Jam (dark red). Bottom-right circular gradient "my location" FAB. Warning banner variant (amber #FFF6DA, warning icon, "API key missing"). Loading variant: gradient spinner. Font Plus Jakarta Sans.
```

---

# PHẦN F – BẠN BÈ & THÔNG BÁO

## 33. Thêm bạn
```
Design the "Add friend" screen of "LocaShot GPS". Style "Aurora Pop".
Header: back button, title "Add friend" ExtraBold 24. Search field (radius 22, white, shadow) with search icon, hint "Search by username", clear button.
Result card (radius 24): avatar, @username bold, mutual info, gradient pill "Add" (states: "Requested" grey, and for received requests two buttons "Accept" gradient and "Delete" outlined red). "Not found" state with a cute magnifier illustration. Font Plus Jakarta Sans.
```

## 34. Bản đồ vị trí bạn bè
```
Design the Friend Map screen of "LocaShot GPS". Style "Aurora Pop".
Pastel full-screen map with a large friend avatar marker (gradient ring, pulse) at the shared location; top glass app bar with back button and title "See on map"; bottom-right gradient my-location FAB.
Bottom sheet (white, radius 32): avatar, "Linh shared a location", place name, address, time "2 min ago", buttons "Directions" gradient pill and "Street View" outlined pill. Font Plus Jakarta Sans.
```

## 35. Vị trí được chia sẻ
```
Design the "Shared locations" list screen of "LocaShot GPS". Style "Aurora Pop".
Header: back button, title "Shared locations". List of cards (radius 24, white, shadow): avatar, "Shared by Linh", place name, and a countdown chip "Expires in 3h" (sunny) / "Expires soon" (pink); trailing delete icon in red tint; mini map thumbnail on the right.
Empty-state variant: pin-with-paper-plane illustration, "No shared locations yet". Delete confirmation dialog variant. Font Plus Jakarta Sans.
```

## 36. Thông báo
```
Design the Notifications screen of "LocaShot GPS". Style "Aurora Pop".
Header: back button, title "Notifications", right action "Mark all read" (double-check icon, violet). Group labels "Today", "Earlier".
Tiles (radius 22): leading icon tile by type — friend request (violet), request accepted (mint), shared photo/video (pink), shared location (aqua); text lines and time; unread state: light violet fill #F3EBFF with a gradient dot. Friend-request tile has two buttons "Accept" gradient pill and "Delete" outlined. Other tiles have a small "View" pill.
Empty-state variant: bell with sparkles, "You're all caught up". Font Plus Jakarta Sans.
```

## 37. Xem ảnh/video được chia sẻ
```
Design the Shared Media Viewer of "LocaShot GPS". Style "Aurora Pop" dark.
Full dark #0E0B1F viewer showing the photo (or a video with big glass play button). Top glass bar: back button, avatar + "Shared by Linh", street-view icon button. Bottom glass info card: address, coordinates, date-time; gradient pill "Open in map". Error variant: broken-image illustration with "Couldn't load media" and Retry pill. Font Plus Jakarta Sans.
```

---

# PHẦN G – TÀI KHOẢN & CÀI ĐẶT

## 38. Đổi ngôn ngữ (trong Settings)
```
Design the Language settings screen of "LocaShot GPS". Style "Aurora Pop".
Header: back button, title "Language", right "Save" gradient text button.
List of language rows in one white group card (radius 28): round flag 36px, language name bold + native name grey. Selected row: light violet fill #F3EBFF, gradient border 2px, gradient check circle. Font Plus Jakarta Sans.
```

## 39. Thông tin cá nhân
```
Design the Personal Information screen of "LocaShot GPS". Style "Aurora Pop".
Top: back button, title. Center: big avatar 120px with gradient ring and camera badge, decorative blobs behind.
Info card (radius 28): row "Username @linh.nguyen" with edit pencil in a violet tile; row "Email".
Bottom: red-tint pill button "Delete account" (#FFE9EE fill, #FF4757 text, trash icon).
Include the edit-username dialog variant (radius 28, input, gradient "Save" pill). Font Plus Jakarta Sans.
```

## 40. Xoá tài khoản (dialog xác nhận)
```
Design the "Delete account" confirmation dialog of "LocaShot GPS" over a dimmed blurred screen. Style "Aurora Pop".
White card radius 28: red-tint circle with warning triangle, title "Delete your account?", warning text listing what will be lost (photos, friends, history), a field "Type DELETE to confirm" with red focus border, buttons "Cancel" outlined and "Delete" solid #FF4757 pill (disabled until typed). Add second variant: non-dismissible progress dialog with gradient spinner "Deleting account…". Font Plus Jakarta Sans.
```

---

## Ghi chú triển khai (sau khi Stitch ra thiết kế)
- Đổi token trong `lib/core/constants/app_constants.dart` và `lib/core/theme/app_theme.dart` (primary → `#7C3AED`, gradient CTA, font Plus Jakarta Sans qua `google_fonts`); thay các màu hard-code trong màn hình.
- `GradientButton`, `AppCard`, `CircleIconButton`, `app_bottom_nav.dart` là các widget dùng chung cần cập nhật trước.
- Hiện app chưa có Paywall/Template stamp/Onboarding quyền: không có prompt cho các màn này.

