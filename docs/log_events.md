# Log Events Specification

Tài liệu này chứa thông tin chi tiết của các log event mới cần được implement, cấu trúc chính xác theo các sheet trong thiết kế.

## 1. Sheet 1: Onboarding & Main Events

| Event name | Trigger | Param | Description | Value Type | Value Example | Note |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `splash_view` | New User nhìn thấy màn Splash khi vừa mở app | | | | | |
| `splash_complete` | New User hoàn tất màn Splash | `time_to_action` | Thời gian từ lúc bắt đầu vào màn đến khi hoàn tất màn Splash | Int (s) | `7.5/7.3555/...` | User hoàn tất màn khi khi user rời Splash và được điều hướng sang màn tiếp theo |
| `lfo1_view` | User nhìn thấy màn LFO1 | | | | | |
| `lfo1_complete` | User hoàn tất màn LFO1 | `time_to_action` | Thời gian từ lúc bắt đầu vào màn LFO1 đến khi hoàn tất màn LFO1 và được điều hướng sang màn LFO2 | Int (s) | `7.5/7.3555/...` | `time_to_action` = `timestamp(lfo1_complete) - timestamp(lfo1_view)` |
| `lfo2_view` | User nhìn thấy màn LFO2 | | | | | |
| `lfo2_complete` | User hoàn tất màn LFO2 | `time_to_action` | Thời gian từ lúc bắt đầu vào màn LFO2 đến khi hoàn tất màn LFO2 và được điều hướng sang màn inter | Int (s) | `7.5/7.3555/...` | `time_to_action` = `timestamp(lfo2_complete) - timestamp(lfo2_view)` |
| `onb1_view` | User nhìn thấy màn Onboarding 1 | | | | | |
| `onb1_complete` | User hoàn tất màn Onboarding 1 | `time_to_action` | Thời gian từ lúc bắt đầu vào màn Onboarding 1 đến khi hoàn tất màn Onboarding 1 và được điều hướng sang màn Onboarding 2 | Int (s) | `7.5/7.3555/...` | |
| `onb2_view` | User nhìn thấy màn Onboarding 2 | | | | | |
| `onb2_complete` | User hoàn tất màn Onboarding 2 | `time_to_action` | Thời gian từ lúc bắt đầu vào màn đến khi hoàn tất màn Onboarding 2 và được điều hướng sang màn Onboarding 3 | Int (s) | `7.5/7.3555/...` | |
| `onb3_view` | User nhìn thấy màn Onboarding 3 | | | | | |
| `onb3_complete` | User hoàn tất màn Onboarding 3 | `time_to_action` | Thời gian từ lúc bắt đầu vào màn Onboarding 3 đến khi hoàn tất màn Onboarding 3 và được điều hướng sang màn Onboarding 4 | Int (s) | `7.5/7.3555/...` | |
| `onb4_view` | User nhìn thấy màn Onboarding 4 | | | | | |
| `onb4_complete` | User hoàn tất màn Onboarding 4 | `time_to_action` | Thời gian từ lúc bắt đầu vào màn Onboarding 4 đến khi hoàn tất màn Onboarding 4 và được điều hướng sang màn Onboarding 5 | Int (s) | `7.5/7.3555/...` | |
| `scantv_view` | User nhìn thấy màn Scan TV | | | | | |
| `scantv_connect_success` | User connect TV thành công | | | | | |
| `scantv_connect_fail` | User connect TV không thành công | | | | | |
| `scantv_complete` | User hoàn tất màn ScanTV | `time_to_action` | Thời gian từ lúc bắt đầu vào màn Scan đến khi hoàn tất màn Scan và được điều hướng sang màn IAP | Int (s) | `7.5/7.3555/...` | |
| `home_view` | User nhìn thấy màn Home | | | | | |
| `remoteTV_click` | User click vào tab Remote TV ở màn Home | | | | | |
| `remoteTV_complete` | User hoàn tất sử dụng tính năng remote TV | `time_to_action` | Thời gian từ lúc bắt đầu vào màn đến khi thoát màn | Int (s) | `7.5/7.3555/...` | |
| `casttv_click` | User click vào tab Cast to TV ở màn Home | | | | | |
| `cast_photo_click` | User click vào tính năng cast photo | | | | | |
| `cast_video_click` | User click vào tính năng cast video | | | | | |
| `screen_mirroring_click` | User click vào tính năng screen mirroring | | | | | |
| `tv_connect_view` | User ở màn connect TV | | | | | |
| `tv_connect_success` | User connect thành công với TV ở in app | | | | | |
| `tv_connect_fail` | User connect fail với TV ở in app | | | | | |

---

## 2. Sheet 2: In-App Purchase (IAP)

| Event name | Trigger | Param | Description | Value Type | Value Example | Note |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `iap_view` | User nhìn thấy màn paywall | `iap_source` | Vị trí hiển thị màn paywall | String | `splash/home/remote/casttv` | `splash`: vị trí màn iap ở luồng onboarding<br>`home`: vị trí màn iap ở màn home<br>`remote`: iap hiển thị khi bấm nút tắt nguồn ở remote TV<br>`casttv`: iap hiển thị sau khi dùng hết 3 lượt free tính năng cast to TV |
| | | `iap_display_count` | Màn paywall xuất hiện lần thứ mấy | Int | `1/2/3/4/...` | |
| `iap_exit_click` | User click button exit ở paywall | `iap_source` | Vị trí hiển thị màn paywall | String | `splash/home/remote/casttv` | |
| | | `iap_display_count` | Màn paywall xuất hiện lần thứ mấy | Int | `1/2/3/4/...` | |
| `iap_cta_click` | User click button CTA | `iap_source` | Vị trí hiển thị màn paywall | String | `splash/home/remote/casttv` | |
| | | `iap_display_count` | Màn paywall xuất hiện lần thứ mấy | Int | `1/2/3/4/...` | |
| `iap_successful` | User thực hiện thanh toán thành công | `iap_source` | Vị trí hiển thị màn paywall | String | `splash/home/remote/casttv` | |
| | | `iap_display_count` | Màn paywall xuất hiện lần thứ mấy | Int | `1/2/3/4/...` | |
| `iap_paydone_[gói giá]` | User mua gói IAP thành công | `subscription` | Gói giá IAP | String | `weekly, yearly` | |
