# 📱 ỨNG DỤNG QUẢN LÝ CHI TIÊU CÁ NHÂN  

**🎓 Trường Công nghệ Thông tin – Đại học Phenikaa**  
**📘 Môn học:** Lập trình cho Thiết bị Di Động (N05)  
**👥 Nhóm:** 10  
**🧑‍🏫 GVHD:** ThS. Nguyễn Xuân Quế  

---

## 🧩 BẢNG PHÂN CÔNG NHIỆM VỤ CHI TIẾT

| **Công việc / Nhiệm vụ** | **Mô tả công việc** | **Thành viên đảm nhiệm** |
|----------------------------|----------------------|---------------------------|
| **Thu thập & Phân tích yêu cầu** |||
| **Công việc 1** | **Nhiệm vụ 1:** Viết tài liệu yêu cầu SRS | **Lê Đức Duy** |
|  | **Nhiệm vụ 2:** Tìm hiểu các nhóm chức năng | **Nguyễn Văn Trọng** |
| **Phân tích & Thiết kế hệ thống** |||
| **Công việc 2** | **Nhiệm vụ 3:** Thiết kế sơ đồ Use-case | **Lê Đức Duy** |
|  | **Nhiệm vụ 4:** Thiết kế sơ đồ tuần tự các chức năng | **Lê Đức Duy** |
|  | **Nhiệm vụ 5:** Thiết kế sơ đồ hoạt động các chức năng | **Lê Đức Duy** |
|  | **Nhiệm vụ 6:** Thiết kế giao diện | **Lê Đức Duy** |
| **Triển khai giải pháp (Xây dựng phần mềm)** |||
| **Công việc 3** | **Nhiệm vụ 7:** R1–R2 (Đăng ký, Đăng nhập, CRUD Danh mục) | **Nguyễn Văn Trọng** |
|  | **Nhiệm vụ 8:** R3–R5 (CRUD Giao dịch, Cập nhật số dư, Dashboard, Biểu đồ, Quản lý Ví) | **Lê Đức Duy** |
| **Kiểm thử & Đánh giá hệ thống** |||
| **Công việc 4** | **Nhiệm vụ 9:** Lập kế hoạch kiểm thử | **Lê Đức Duy** |
|  | **Nhiệm vụ 10:** Kiểm thử giao diện | **Lê Đức Duy** |
|  | **Nhiệm vụ 11:** Kiểm thử tích hợp & chức năng | **Nguyễn Văn Trọng** |
|  | **Nhiệm vụ 12:** Kiểm thử phi chức năng | **Nguyễn Văn Trọng** |
| **Báo cáo & Trình bày sản phẩm** |||
| **Công việc 5** | **Nhiệm vụ 13:** Chuẩn bị video demo | **Nguyễn Văn Trọng** |
|  | **Nhiệm vụ 14:** Tổng kết, viết báo cáo cuối cùng, Slide | **Lê Đức Duy** |

---

## 🧱 CẤU TRÚC THƯ MỤC DỰ ÁN VÀ HƯỚNG DẪN CHẠY ỨNG DỤNG

```text
appquanlychitieucanhan/
├── assets/
│   ├── db/
│   │   ├── schema.sql
│   │   └── seed.sql
│   └── images/
│       ├── banner_wallet.png
│       ├── change_pwd.png
│       ├── duy.png
│       ├── logo.png
│       ├── profile_banner.png
│       ├── register.png
│       ├── team_banner.png
│       ├── trong.png
│       └── user_avatar.png
│
├── lib/
│   ├── db/
│   │   ├── app_db.dart
│   │   ├── category_dao.dart
│   │   ├── transaction_dao.dart
│   │   └── wallet_dao.dart
│
│   ├── l10n/
│   │   ├── app_en.arb
│   │   ├── app_vi.arb
│   │   ├── app_localizations.dart
│   │   ├── app_localizations_en.dart
│   │   ├── app_localizations_vi.dart
│   │   └── l10n_ext.dart
│
│   ├── models/
│   │   ├── category_icon_store.dart
│   │   ├── expense_model.dart
│   │   └── wallet_model.dart
│
│   ├── screens/
│   │   ├── transaction/
│   │   │   ├── add_expense_screen.dart
│   │   │   └── add_income_screen.dart
│   │   ├── about_screen.dart
│   │   ├── change_password_screen.dart
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── register_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── statistics_screen.dart
│   │   ├── transaction_category_screen.dart
│   │   ├── transaction_entry_screen.dart
│   │   ├── transaction_list_screen.dart
│   │   └── wallet_screen.dart
│
│   ├── theme/
│   │   └── color_utils.dart
│
│   ├── widgets/
│   │   ├── balance_card.dart
│   │   ├── icon_picker.dart
│   │   ├── recent_transactions_section.dart
│   │   ├── statistics_cashflow.dart
│   │   ├── statistics_category_list.dart
│   │   ├── statistics_chart.dart
│   │   ├── statistics_search.dart
│   │   ├── statistics_summary.dart
│   │   ├── summary_card.dart
│   │   ├── transaction_list_view.dart
│   │   ├── transaction_search.dart
│   │   └── transaction_summary.dart
│
│   └── main.dart
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── pubspec.yaml
├── pubspec.lock
├── l10n.yaml
└── README.md

🚀 HƯỚNG DẪN CÀI ĐẶT & CHẠY ỨNG DỤNG
1️⃣ Cài đặt các gói phụ thuộc:
    flutter pub get
2️⃣ Chạy ứng dụng (chọn thiết bị hoặc emulator):
    flutter run
    
🙏 LỜI CẢM ƠN

Nhóm xin gửi lời cảm ơn chân thành đến ThS. Nguyễn Xuân Quế đã tận tình hướng dẫn, hỗ trợ và góp ý trong suốt quá trình thực hiện đồ án.
Nhờ có sự chỉ bảo của thầy, nhóm đã có thể hoàn thiện ứng dụng này một cách tốt nhất. 💙

📩 MỌI THẮC MẮC HÃY LIÊN HỆ

📧 Lê Đức Duy – 23010772@st.phenikaa-uni.edu.vn

💬 Rất mong nhận được phản hồi và góp ý để ứng dụng ngày càng hoàn thiện hơn!