import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Expense Manager'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get tabTransactions;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get tabStats;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @homeOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get homeOverviewTitle;

  /// No description provided for @addIncomeUpper.
  ///
  /// In en, this message translates to:
  /// **'ADD INCOME'**
  String get addIncomeUpper;

  /// No description provided for @addExpenseUpper.
  ///
  /// In en, this message translates to:
  /// **'ADD EXPENSE'**
  String get addExpenseUpper;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent transactions'**
  String get recentTransactions;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @transactionsTitleShort.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitleShort;

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsCount;

  /// No description provided for @addIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add income'**
  String get addIncomeTitle;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense'**
  String get addExpenseTitle;

  /// No description provided for @saveIncome.
  ///
  /// In en, this message translates to:
  /// **'Save income'**
  String get saveIncome;

  /// No description provided for @saveExpense.
  ///
  /// In en, this message translates to:
  /// **'Save expense'**
  String get saveExpense;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get saveTransaction;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get amountHint;

  /// No description provided for @vndSuffix.
  ///
  /// In en, this message translates to:
  /// **'VND'**
  String get vndSuffix;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter the amount'**
  String get pleaseEnterAmount;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get amountInvalid;

  /// No description provided for @amountMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountMustBeGreaterThanZero;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get catFood;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catClothes.
  ///
  /// In en, this message translates to:
  /// **'Clothes'**
  String get catClothes;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catBill.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get catBill;

  /// No description provided for @catRent.
  ///
  /// In en, this message translates to:
  /// **'Rent'**
  String get catRent;

  /// No description provided for @catOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get catOther;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catBonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get catBonus;

  /// No description provided for @catAllowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get catAllowance;

  /// No description provided for @catInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get catInvestment;

  /// No description provided for @addCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryTitle;

  /// No description provided for @addCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get addCategoryHint;

  /// No description provided for @addIncomeCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add income category'**
  String get addIncomeCategoryTitle;

  /// No description provided for @addExpenseCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense category'**
  String get addExpenseCategoryTitle;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get categoryNameHint;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @incomeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Income categories'**
  String get incomeCategoriesTitle;

  /// No description provided for @expenseCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense categories'**
  String get expenseCategoriesTitle;

  /// No description provided for @renameCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get renameCategoryTitle;

  /// No description provided for @renameCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'New category name'**
  String get renameCategoryHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTitle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete category “{name}”?'**
  String deleteCategoryConfirm(Object name);

  /// No description provided for @deleteDemo.
  ///
  /// In en, this message translates to:
  /// **'Delete (demo)'**
  String get deleteDemo;

  /// No description provided for @renameDemo.
  ///
  /// In en, this message translates to:
  /// **'Rename (demo)'**
  String get renameDemo;

  /// No description provided for @deleteDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a demo — delete action is disabled.'**
  String get deleteDemoNotice;

  /// No description provided for @categoryExists.
  ///
  /// In en, this message translates to:
  /// **'Category “{name}” already exists'**
  String categoryExists(Object name);

  /// No description provided for @categoryAdded.
  ///
  /// In en, this message translates to:
  /// **'Added “{name}”'**
  String categoryAdded(Object name);

  /// No description provided for @addCategoryFAB.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryFAB;

  /// No description provided for @searchCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories…'**
  String get searchCategoryHint;

  /// No description provided for @noCategoryMatch.
  ///
  /// In en, this message translates to:
  /// **'No categories matched'**
  String get noCategoryMatch;

  /// No description provided for @incomeFull.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeFull;

  /// No description provided for @expenseFull.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseFull;

  /// No description provided for @alreadyIncome.
  ///
  /// In en, this message translates to:
  /// **'Already income'**
  String get alreadyIncome;

  /// No description provided for @alreadyExpense.
  ///
  /// In en, this message translates to:
  /// **'Already expense'**
  String get alreadyExpense;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @pickDateRange.
  ///
  /// In en, this message translates to:
  /// **'Pick date range'**
  String get pickDateRange;

  /// No description provided for @quickFilters.
  ///
  /// In en, this message translates to:
  /// **'Quick filters'**
  String get quickFilters;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get filterThisMonth;

  /// No description provided for @filterCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get filterCustom;

  /// No description provided for @filterCustomEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get filterCustomEllipsis;

  /// No description provided for @rangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get rangeLabel;

  /// No description provided for @incomeShort.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeShort;

  /// No description provided for @expenseShort.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseShort;

  /// No description provided for @totalIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get totalIncomeLabel;

  /// No description provided for @totalExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Total expense'**
  String get totalExpenseLabel;

  /// No description provided for @noIncomeDataForFilter.
  ///
  /// In en, this message translates to:
  /// **'No income data for current filter.'**
  String get noIncomeDataForFilter;

  /// No description provided for @noExpenseDataForFilter.
  ///
  /// In en, this message translates to:
  /// **'No expense data for current filter.'**
  String get noExpenseDataForFilter;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @userDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get userDefaultName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Track your money smartly'**
  String get appTagline;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total income'**
  String get totalIncome;

  /// No description provided for @totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total expense'**
  String get totalExpense;

  /// No description provided for @currentBalance.
  ///
  /// In en, this message translates to:
  /// **'Current balance'**
  String get currentBalance;

  /// No description provided for @incomeMinusExpense.
  ///
  /// In en, this message translates to:
  /// **'Income minus expense'**
  String get incomeMinusExpense;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get changePasswordSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @forgotPasswordDemo.
  ///
  /// In en, this message translates to:
  /// **'Forgot password is demo only.'**
  String get forgotPasswordDemo;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password.'**
  String get invalidCredentials;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPasswordQ.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordQ;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get noAccount;

  /// No description provided for @registerNow.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNow;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get pleaseEnterUsername;

  /// No description provided for @usernameMinLen.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameMinLen;

  /// No description provided for @usernameRules.
  ///
  /// In en, this message translates to:
  /// **'Only letters, numbers, dot, underscore and dash are allowed'**
  String get usernameRules;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLen.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLen;

  /// No description provided for @passwordRecommendLettersDigits.
  ///
  /// In en, this message translates to:
  /// **'Use letters and digits for a stronger password'**
  String get passwordRecommendLettersDigits;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @usernameExists.
  ///
  /// In en, this message translates to:
  /// **'Username already exists'**
  String get usernameExists;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registerSuccess;

  /// No description provided for @passwordWrongOld.
  ///
  /// In en, this message translates to:
  /// **'Old password is incorrect.'**
  String get passwordWrongOld;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully.'**
  String get passwordUpdated;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @incomeGreater.
  ///
  /// In en, this message translates to:
  /// **'Income > Expense'**
  String get incomeGreater;

  /// No description provided for @incomeEqualsExpense.
  ///
  /// In en, this message translates to:
  /// **'Income = Expense'**
  String get incomeEqualsExpense;

  /// No description provided for @expenseGreater.
  ///
  /// In en, this message translates to:
  /// **'Expense > Income'**
  String get expenseGreater;

  /// No description provided for @copyBalanceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy balance'**
  String get copyBalanceTooltip;

  /// No description provided for @copiedBalance.
  ///
  /// In en, this message translates to:
  /// **'Copied: {value}'**
  String copiedBalance(Object value);

  /// No description provided for @savedIncome.
  ///
  /// In en, this message translates to:
  /// **'Saved income {amount}'**
  String savedIncome(Object amount);

  /// No description provided for @savedExpense.
  ///
  /// In en, this message translates to:
  /// **'Saved expense {amount}'**
  String savedExpense(Object amount);

  /// No description provided for @recordIncome.
  ///
  /// In en, this message translates to:
  /// **'Record income'**
  String get recordIncome;

  /// No description provided for @recordExpense.
  ///
  /// In en, this message translates to:
  /// **'Record expense'**
  String get recordExpense;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryTitle;

  /// No description provided for @moreIncome.
  ///
  /// In en, this message translates to:
  /// **'More income'**
  String get moreIncome;

  /// No description provided for @moreExpense.
  ///
  /// In en, this message translates to:
  /// **'More expense'**
  String get moreExpense;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance'**
  String get netBalance;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get searchHint;

  /// No description provided for @clearSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchTooltip;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @range.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get range;

  /// No description provided for @noTransactionsInRange.
  ///
  /// In en, this message translates to:
  /// **'No transactions found for the selected period.'**
  String get noTransactionsInRange;

  /// No description provided for @noNote.
  ///
  /// In en, this message translates to:
  /// **'No note'**
  String get noNote;

  /// No description provided for @about_title.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get about_title;

  /// No description provided for @about_members_title.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get about_members_title;

  /// No description provided for @tabAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get tabAbout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
