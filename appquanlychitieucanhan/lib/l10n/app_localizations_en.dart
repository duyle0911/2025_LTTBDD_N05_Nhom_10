// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Expense Manager';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTransactions => 'Transactions';

  @override
  String get tabStats => 'Statistics';

  @override
  String get tabProfile => 'Profile';

  @override
  String get tabAbout => 'About';

  @override
  String get tabWallet => 'Wallet';

  @override
  String get homeOverviewTitle => 'Overview';

  @override
  String get addIncomeUpper => 'ADD INCOME';

  @override
  String get addExpenseUpper => 'ADD EXPENSE';

  @override
  String get recentTransactions => 'Recent transactions';

  @override
  String get viewAll => 'View all';

  @override
  String get transactions => 'Transactions';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get transactionsTitleShort => 'Transactions';

  @override
  String get transactionsCount => 'Transactions';

  @override
  String get addIncomeTitle => 'Add income';

  @override
  String get addExpenseTitle => 'Add expense';

  @override
  String get saveIncome => 'Save income';

  @override
  String get saveExpense => 'Save expense';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get amount => 'Amount';

  @override
  String get amountHint => 'Enter amount';

  @override
  String get vndSuffix => 'VND';

  @override
  String get pleaseEnterAmount => 'Please enter the amount';

  @override
  String get amountInvalid => 'Invalid amount';

  @override
  String get amountMustBeGreaterThanZero => 'Amount must be greater than 0';

  @override
  String get category => 'Category';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get date => 'Date';

  @override
  String get catFood => 'Food & Drinks';

  @override
  String get catEducation => 'Education';

  @override
  String get catClothes => 'Clothes';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catTransport => 'Transport';

  @override
  String get catBill => 'Bills';

  @override
  String get catRent => 'Rent';

  @override
  String get catOther => 'Other';

  @override
  String get catSalary => 'Salary';

  @override
  String get catBonus => 'Bonus';

  @override
  String get catAllowance => 'Allowance';

  @override
  String get catInvestment => 'Investment';

  @override
  String get addCategoryTitle => 'Add category';

  @override
  String get addCategoryHint => 'Category name';

  @override
  String get addIncomeCategoryTitle => 'Add income category';

  @override
  String get addExpenseCategoryTitle => 'Add expense category';

  @override
  String get categoryNameHint => 'Enter category name';

  @override
  String get add => 'Add';

  @override
  String get incomeCategoriesTitle => 'Income categories';

  @override
  String get expenseCategoriesTitle => 'Expense categories';

  @override
  String get renameCategoryTitle => 'Rename category';

  @override
  String get renameCategoryHint => 'New category name';

  @override
  String get save => 'Save';

  @override
  String get deleteCategoryTitle => 'Delete category';

  @override
  String get delete => 'Delete';

  @override
  String deleteCategoryConfirm(Object name) {
    return 'Delete category “$name”?';
  }

  @override
  String get deleteDemo => 'Delete (demo)';

  @override
  String get renameDemo => 'Rename (demo)';

  @override
  String get deleteDemoNotice => 'This is a demo — delete action is disabled.';

  @override
  String categoryExists(Object name) {
    return 'Category “$name” already exists';
  }

  @override
  String categoryAdded(Object name) {
    return 'Added “$name”';
  }

  @override
  String get addCategoryFAB => 'Add category';

  @override
  String get searchCategoryHint => 'Search categories…';

  @override
  String get noCategoryMatch => 'No categories matched';

  @override
  String get incomeFull => 'Income';

  @override
  String get expenseFull => 'Expense';

  @override
  String get alreadyIncome => 'Already income';

  @override
  String get alreadyExpense => 'Already expense';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get pickDateRange => 'Pick date range';

  @override
  String get quickFilters => 'Quick filters';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisMonth => 'This month';

  @override
  String get filterCustom => 'Custom…';

  @override
  String get filterCustomEllipsis => 'Custom…';

  @override
  String get rangeLabel => 'Range';

  @override
  String get incomeShort => 'Income';

  @override
  String get expenseShort => 'Expense';

  @override
  String get totalIncomeLabel => 'Total income';

  @override
  String get totalExpenseLabel => 'Total expense';

  @override
  String get noIncomeDataForFilter => 'No income data for current filter.';

  @override
  String get noExpenseDataForFilter => 'No expense data for current filter.';

  @override
  String get logoutTitle => 'Log out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get logout => 'Log out';

  @override
  String get cancel => 'Cancel';

  @override
  String get userDefaultName => 'Guest';

  @override
  String get appTagline => 'Track your money smartly';

  @override
  String get totalIncome => 'Total income';

  @override
  String get totalExpense => 'Total expense';

  @override
  String get currentBalance => 'Current balance';

  @override
  String get incomeMinusExpense => 'Income minus expense';

  @override
  String get settings => 'Settings';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordSubtitle => 'Update your account password';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get forgotPasswordDemo => 'Forgot password is demo only.';

  @override
  String get invalidCredentials => 'Invalid username or password.';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginButton => 'Login';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPasswordQ => 'Forgot password?';

  @override
  String get noAccount => 'Don’t have an account?';

  @override
  String get registerNow => 'Register now';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerButton => 'Register';

  @override
  String get haveAccount => 'Already have an account?';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get pleaseEnterUsername => 'Please enter your username';

  @override
  String get usernameMinLen => 'Username must be at least 3 characters';

  @override
  String get usernameRules =>
      'Only letters, numbers, dot, underscore and dash are allowed';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLen => 'Password must be at least 6 characters';

  @override
  String get passwordRecommendLettersDigits =>
      'Use letters and digits for a stronger password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get usernameExists => 'Username already exists';

  @override
  String get registerSuccess => 'Registration successful';

  @override
  String get passwordWrongOld => 'Old password is incorrect.';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get passwordUpdated => 'Password updated successfully.';

  @override
  String get oldPassword => 'Old password';

  @override
  String get newPassword => 'New password';

  @override
  String get incomeGreater => 'Income > Expense';

  @override
  String get incomeEqualsExpense => 'Income = Expense';

  @override
  String get expenseGreater => 'Expense > Income';

  @override
  String get copyBalanceTooltip => 'Copy balance';

  @override
  String copiedBalance(Object value) {
    return 'Copied: $value';
  }

  @override
  String savedIncome(Object amount) {
    return 'Saved income $amount';
  }

  @override
  String savedExpense(Object amount) {
    return 'Saved expense $amount';
  }

  @override
  String get recordIncome => 'Record income';

  @override
  String get recordExpense => 'Record expense';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get summaryTitle => 'Summary';

  @override
  String get moreIncome => 'More income';

  @override
  String get moreExpense => 'More expense';

  @override
  String get netBalance => 'Net balance';

  @override
  String get searchHint => 'Search…';

  @override
  String get clearSearchTooltip => 'Clear search';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisMonth => 'This month';

  @override
  String get allTime => 'All time';

  @override
  String get range => 'Range';

  @override
  String get noTransactionsInRange =>
      'No transactions found for the selected period.';

  @override
  String get noNote => 'No note';

  @override
  String get about_title => 'About Us';

  @override
  String get about_members_title => 'Team Members';

  @override
  String get walletTitle => 'Wallets';

  @override
  String get chooseWalletTooltip => 'Choose wallet';

  @override
  String get chooseWalletTitle => 'Choose wallet';

  @override
  String get allWallets => 'All wallets';

  @override
  String get walletTypeCash => 'Cash';

  @override
  String get walletTypeBank => 'Bank';

  @override
  String get walletTypeCredit => 'Credit card';

  @override
  String get walletTypeSavings => 'Savings';

  @override
  String get walletCreateTitle => 'Create new wallet';

  @override
  String get walletEditTitle => 'Edit wallet';

  @override
  String get walletAdded => 'Wallet added';

  @override
  String get walletUpdated => 'Wallet updated';

  @override
  String get walletDeleted => 'Wallet deleted';

  @override
  String get deleteConfirmTitle => 'Confirm delete';

  @override
  String walletDeleteConfirm(Object name) {
    return 'Delete wallet “$name”? This cannot be undone.';
  }

  @override
  String walletCannotDeleteWithBalance(Object name, Object amount) {
    return 'Cannot delete. Wallet “$name” still has a balance of $amount. Please move funds or set the balance to 0 first.';
  }

  @override
  String get walletNameLabel => 'Wallet name';

  @override
  String get walletNameHint => 'e.g. Cash wallet / ACB Bank / VIB Credit…';

  @override
  String get walletNameRequired => 'Wallet name is required';

  @override
  String get walletTypeLabel => 'Wallet type';

  @override
  String get initialBalanceLabel => 'Initial balance';

  @override
  String get initialBalanceHint => '0';

  @override
  String get initialBalanceInvalid => 'Invalid number';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get walletNoteHint => 'Last 4 digits / extra notes…';

  @override
  String get reset => 'Reset';

  @override
  String get openFullForm => 'Open full-screen form';

  @override
  String get createWalletButton => 'Create wallet';

  @override
  String get createWalletSectionTitle => 'Create a new wallet';

  @override
  String get badgeNew => 'NEW';

  @override
  String get walletNameShort => 'Wallet name';

  @override
  String get walletNameHintShort => 'Main wallet / Cash…';

  @override
  String get edit => 'Edit';

  @override
  String get addWalletFab => 'Add wallet';

  @override
  String get noWalletsHint => 'No wallets yet. Create your first wallet!';

  @override
  String get cashflowChartTitle => 'Income and Expense over time';

  @override
  String get incomeFullLabel => 'Income';

  @override
  String get expenseFullLabel => 'Expense';

  @override
  String get balance => 'Balance';

  @override
  String get wallet => 'Wallet';

  @override
  String get addWallet => 'Add wallet';

  @override
  String get walletCreated => 'Wallet created';

  @override
  String get selectWalletHint => 'Select a wallet';

  @override
  String get walletManageTitle => 'Wallets';

  @override
  String get walletCreate => 'Create wallet';

  @override
  String get walletEdit => 'Edit wallet';

  @override
  String get fieldWalletName => 'Wallet name';

  @override
  String get fieldWalletType => 'Wallet type';

  @override
  String get fieldWalletTypeAccount => 'Account type';

  @override
  String get fieldBalanceVnd => 'Balance (VND)';

  @override
  String get fieldInitialBalance => 'Initial balance';

  @override
  String get fieldCurrency => 'Currency';

  @override
  String get fieldDescriptionOptional => 'Description (optional)';

  @override
  String get inputWalletName => 'Enter wallet name';

  @override
  String get invalidBalance => 'Invalid balance';

  @override
  String get create => 'Create';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get deleteWallet => 'Delete wallet';

  @override
  String deleteWalletConfirm(Object name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get createWalletPopup => 'Create wallet (popup)';

  @override
  String totalWallets(Object count) {
    return 'Total wallets: $count';
  }

  @override
  String get selected => 'Selected';

  @override
  String get newBadge => 'NEW';

  @override
  String get createWalletInlineTitle => 'Create new wallet';

  @override
  String get createWalletCta => 'Create wallet';

  @override
  String createdWallet(Object amount) {
    return 'Wallet created ($amount)';
  }

  @override
  String get chooseThisWallet => 'Choose this wallet';

  @override
  String get addTransactionCta => 'Add transaction';
}
