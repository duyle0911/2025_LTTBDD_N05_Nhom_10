// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản lý chi tiêu cá nhân';

  @override
  String get tabHome => 'Trang chủ';

  @override
  String get tabTransactions => 'Giao dịch';

  @override
  String get tabStats => 'Thống kê';

  @override
  String get tabProfile => 'Hồ sơ';

  @override
  String get tabAbout => 'Giới thiệu';

  @override
  String get tabWallet => 'Ví tiền';

  @override
  String get homeOverviewTitle => 'Tổng quan';

  @override
  String get addIncomeUpper => 'THÊM THU';

  @override
  String get addExpenseUpper => 'THÊM CHI';

  @override
  String get recentTransactions => 'Giao dịch gần đây';

  @override
  String get viewAll => 'Xem tất cả';

  @override
  String get transactions => 'Giao dịch';

  @override
  String get transactionsTitle => 'Giao dịch';

  @override
  String get transactionsTitleShort => 'Giao dịch';

  @override
  String get transactionsCount => 'Số giao dịch';

  @override
  String get addIncomeTitle => 'Thêm khoản thu';

  @override
  String get addExpenseTitle => 'Thêm khoản chi';

  @override
  String get saveIncome => 'Lưu khoản thu';

  @override
  String get saveExpense => 'Lưu khoản chi';

  @override
  String get saveTransaction => 'Lưu giao dịch';

  @override
  String get amount => 'Số tiền';

  @override
  String get amountHint => 'Nhập số tiền';

  @override
  String get vndSuffix => 'VND';

  @override
  String get pleaseEnterAmount => 'Vui lòng nhập số tiền';

  @override
  String get amountInvalid => 'Số tiền không hợp lệ';

  @override
  String get amountMustBeGreaterThanZero => 'Số tiền phải lớn hơn 0';

  @override
  String get category => 'Danh mục';

  @override
  String get noteOptional => 'Ghi chú (không bắt buộc)';

  @override
  String get date => 'Ngày';

  @override
  String get catFood => 'Ăn uống';

  @override
  String get catEducation => 'Giáo dục';

  @override
  String get catClothes => 'Quần áo';

  @override
  String get catShopping => 'Mua sắm';

  @override
  String get catEntertainment => 'Giải trí';

  @override
  String get catTransport => 'Di chuyển';

  @override
  String get catBill => 'Hóa đơn';

  @override
  String get catRent => 'Thuê nhà';

  @override
  String get catOther => 'Khác';

  @override
  String get catSalary => 'Lương';

  @override
  String get catBonus => 'Thưởng';

  @override
  String get catAllowance => 'Phụ cấp';

  @override
  String get catInvestment => 'Đầu tư';

  @override
  String get addCategoryTitle => 'Thêm danh mục';

  @override
  String get addCategoryHint => 'Tên danh mục';

  @override
  String get addIncomeCategoryTitle => 'Thêm danh mục thu';

  @override
  String get addExpenseCategoryTitle => 'Thêm danh mục chi';

  @override
  String get categoryNameHint => 'Nhập tên danh mục';

  @override
  String get add => 'Thêm';

  @override
  String get incomeCategoriesTitle => 'Danh mục thu';

  @override
  String get expenseCategoriesTitle => 'Danh mục chi';

  @override
  String get renameCategoryTitle => 'Đổi tên danh mục';

  @override
  String get renameCategoryHint => 'Tên danh mục mới';

  @override
  String get save => 'Lưu';

  @override
  String get deleteCategoryTitle => 'Xóa danh mục';

  @override
  String get delete => 'Xóa';

  @override
  String deleteCategoryConfirm(Object name) {
    return 'Xóa danh mục “$name”?';
  }

  @override
  String get deleteDemo => 'Xóa (demo)';

  @override
  String get renameDemo => 'Đổi tên (demo)';

  @override
  String get deleteDemoNotice => 'Bản demo — thao tác xóa đã bị vô hiệu.';

  @override
  String categoryExists(Object name) {
    return 'Danh mục “$name” đã tồn tại';
  }

  @override
  String categoryAdded(Object name) {
    return 'Đã thêm “$name”';
  }

  @override
  String get addCategoryFAB => 'Thêm danh mục';

  @override
  String get searchCategoryHint => 'Tìm kiếm danh mục…';

  @override
  String get noCategoryMatch => 'Không có danh mục phù hợp';

  @override
  String get incomeFull => 'Thu';

  @override
  String get expenseFull => 'Chi';

  @override
  String get alreadyIncome => 'Đã thu';

  @override
  String get alreadyExpense => 'Đã chi';

  @override
  String get noTransactionsYet => 'Chưa có giao dịch';

  @override
  String get pickDateRange => 'Chọn khoảng ngày';

  @override
  String get quickFilters => 'Bộ lọc nhanh';

  @override
  String get filterAll => 'Tất cả';

  @override
  String get filterToday => 'Hôm nay';

  @override
  String get filterThisMonth => 'Tháng này';

  @override
  String get filterCustom => 'Tùy chọn…';

  @override
  String get filterCustomEllipsis => 'Tùy chọn…';

  @override
  String get rangeLabel => 'Khoảng';

  @override
  String get incomeShort => 'Thu';

  @override
  String get expenseShort => 'Chi';

  @override
  String get totalIncomeLabel => 'Tổng thu';

  @override
  String get totalExpenseLabel => 'Tổng chi';

  @override
  String get noIncomeDataForFilter =>
      'Không có dữ liệu thu cho bộ lọc hiện tại.';

  @override
  String get noExpenseDataForFilter =>
      'Không có dữ liệu chi cho bộ lọc hiện tại.';

  @override
  String get logoutTitle => 'Đăng xuất';

  @override
  String get logoutConfirm => 'Bạn có chắc muốn đăng xuất?';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get cancel => 'Hủy';

  @override
  String get userDefaultName => 'Khách';

  @override
  String get appTagline => 'Quản lý tiền bạc thông minh';

  @override
  String get totalIncome => 'Tổng thu';

  @override
  String get totalExpense => 'Tổng chi';

  @override
  String get currentBalance => 'Số dư hiện tại';

  @override
  String get incomeMinusExpense => 'Thu trừ chi';

  @override
  String get settings => 'Cài đặt';

  @override
  String get changePassword => 'Đổi mật khẩu';

  @override
  String get changePasswordSubtitle => 'Cập nhật mật khẩu tài khoản';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get forgotPasswordDemo => 'Quên mật khẩu chỉ là bản demo.';

  @override
  String get invalidCredentials => 'Sai tên đăng nhập hoặc mật khẩu.';

  @override
  String get loginTitle => 'Đăng nhập';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get rememberMe => 'Ghi nhớ tôi';

  @override
  String get forgotPasswordQ => 'Quên mật khẩu?';

  @override
  String get noAccount => 'Chưa có tài khoản?';

  @override
  String get registerNow => 'Đăng ký ngay';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get haveAccount => 'Đã có tài khoản?';

  @override
  String get username => 'Tên đăng nhập';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get showPassword => 'Hiện mật khẩu';

  @override
  String get hidePassword => 'Ẩn mật khẩu';

  @override
  String get pleaseEnterUsername => 'Vui lòng nhập tên đăng nhập';

  @override
  String get usernameMinLen => 'Tên đăng nhập tối thiểu 3 ký tự';

  @override
  String get usernameRules =>
      'Chỉ dùng chữ, số, dấu chấm, gạch dưới, gạch ngang';

  @override
  String get pleaseEnterPassword => 'Vui lòng nhập mật khẩu';

  @override
  String get passwordMinLen => 'Mật khẩu tối thiểu 6 ký tự';

  @override
  String get passwordRecommendLettersDigits =>
      'Nên dùng cả chữ và số để mạnh hơn';

  @override
  String get pleaseConfirmPassword => 'Vui lòng xác nhận mật khẩu';

  @override
  String get usernameExists => 'Tên đăng nhập đã tồn tại';

  @override
  String get registerSuccess => 'Đăng ký thành công';

  @override
  String get passwordWrongOld => 'Mật khẩu cũ không đúng.';

  @override
  String get passwordMismatch => 'Mật khẩu không khớp.';

  @override
  String get passwordUpdated => 'Đổi mật khẩu thành công.';

  @override
  String get oldPassword => 'Mật khẩu cũ';

  @override
  String get newPassword => 'Mật khẩu mới';

  @override
  String get incomeGreater => 'Thu > Chi';

  @override
  String get incomeEqualsExpense => 'Thu = Chi';

  @override
  String get expenseGreater => 'Chi > Thu';

  @override
  String get copyBalanceTooltip => 'Sao chép số dư';

  @override
  String copiedBalance(Object value) {
    return 'Đã sao chép: $value';
  }

  @override
  String savedIncome(Object amount) {
    return 'Đã lưu khoản thu $amount';
  }

  @override
  String savedExpense(Object amount) {
    return 'Đã lưu khoản chi $amount';
  }

  @override
  String get recordIncome => 'Ghi khoản thu';

  @override
  String get recordExpense => 'Ghi khoản chi';

  @override
  String get income => 'Thu';

  @override
  String get expense => 'Chi';

  @override
  String get summaryTitle => 'Tổng kết';

  @override
  String get moreIncome => 'Nhiều thu hơn';

  @override
  String get moreExpense => 'Nhiều chi hơn';

  @override
  String get netBalance => 'Số dư ròng';

  @override
  String get searchHint => 'Tìm kiếm…';

  @override
  String get clearSearchTooltip => 'Xóa tìm kiếm';

  @override
  String get today => 'Hôm nay';

  @override
  String get yesterday => 'Hôm qua';

  @override
  String get thisMonth => 'Tháng này';

  @override
  String get allTime => 'Mọi thời gian';

  @override
  String get range => 'Khoảng';

  @override
  String get noTransactionsInRange =>
      'Không có giao dịch trong khoảng đã chọn.';

  @override
  String get noNote => 'Không ghi chú';

  @override
  String get about_title => 'Về Chúng Tôi';

  @override
  String get about_members_title => 'Thành viên nhóm';

  @override
  String get walletTitle => 'Ví tiền';

  @override
  String get chooseWalletTooltip => 'Chọn ví';

  @override
  String get chooseWalletTitle => 'Chọn ví';

  @override
  String get allWallets => 'Tất cả ví';

  @override
  String get walletTypeCash => 'Tiền mặt';

  @override
  String get walletTypeBank => 'Ngân hàng';

  @override
  String get walletTypeCredit => 'Thẻ tín dụng';

  @override
  String get walletTypeSavings => 'Tiết kiệm';

  @override
  String get walletCreateTitle => 'Tạo ví mới';

  @override
  String get walletEditTitle => 'Sửa ví';

  @override
  String get walletAdded => 'Đã thêm ví';

  @override
  String get walletUpdated => 'Đã cập nhật ví';

  @override
  String get walletDeleted => 'Đã xóa ví';

  @override
  String get deleteConfirmTitle => 'Xác nhận xóa';

  @override
  String walletDeleteConfirm(Object name) {
    return 'Xóa ví “$name”? Hành động này không thể hoàn tác.';
  }

  @override
  String walletCannotDeleteWithBalance(Object name, Object amount) {
    return 'Không thể xóa. Ví “$name” vẫn còn số dư $amount. Vui lòng chuyển hết tiền hoặc điều chỉnh số dư về 0 trước.';
  }

  @override
  String get walletNameLabel => 'Tên ví';

  @override
  String get walletNameHint => 'Ví tiền mặt / Ngân hàng ACB / Thẻ VIB…';

  @override
  String get walletNameRequired => 'Tên ví là bắt buộc';

  @override
  String get walletTypeLabel => 'Loại ví';

  @override
  String get initialBalanceLabel => 'Số dư ban đầu';

  @override
  String get initialBalanceHint => '0';

  @override
  String get initialBalanceInvalid => 'Số dư phải là số hợp lệ';

  @override
  String get currencyLabel => 'Đơn vị tiền tệ';

  @override
  String get walletNoteHint => '4 số cuối thẻ / ghi chú khác…';

  @override
  String get reset => 'Đặt lại';

  @override
  String get openFullForm => 'Mở form toàn màn';

  @override
  String get createWalletButton => 'Tạo ví';

  @override
  String get createWalletSectionTitle => 'Tạo ví mới';

  @override
  String get badgeNew => 'MỚI';

  @override
  String get walletNameShort => 'Tên ví';

  @override
  String get walletNameHintShort => 'Ví chính / Tiền mặt…';

  @override
  String get edit => 'Sửa';

  @override
  String get addWalletFab => 'Thêm ví';

  @override
  String get noWalletsHint =>
      'Chưa có ví nào. Hãy tạo ví đầu tiên của bạn nhé!';

  @override
  String get cashflowChartTitle => 'Biểu đồ thu chi theo thời gian';

  @override
  String get incomeFullLabel => 'Thu nhập';

  @override
  String get expenseFullLabel => 'Chi tiêu';

  @override
  String get balance => 'Số dư';

  @override
  String get wallet => 'Ví';

  @override
  String get addWallet => 'Thêm ví';

  @override
  String get walletCreated => 'Đã tạo ví';

  @override
  String get selectWalletHint => 'Chọn một ví';
}
