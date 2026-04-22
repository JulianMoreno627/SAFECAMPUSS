import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SafeCampus AI'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @createReport.
  ///
  /// In en, this message translates to:
  /// **'Create Report'**
  String get createReport;

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Map'**
  String get mapTitle;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get lowRisk;

  /// No description provided for @mediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediumRisk;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highRisk;

  /// No description provided for @criticalRisk.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get criticalRisk;

  /// No description provided for @onboard1Title.
  ///
  /// In en, this message translates to:
  /// **'Stay Safe'**
  String get onboard1Title;

  /// No description provided for @onboard1Desc.
  ///
  /// In en, this message translates to:
  /// **'Know risk zones in real time inside and outside campus'**
  String get onboard1Desc;

  /// No description provided for @onboard2Title.
  ///
  /// In en, this message translates to:
  /// **'Report Incidents'**
  String get onboard2Title;

  /// No description provided for @onboard2Desc.
  ///
  /// In en, this message translates to:
  /// **'Help your community by reporting dangerous situations instantly'**
  String get onboard2Desc;

  /// No description provided for @onboard3Title.
  ///
  /// In en, this message translates to:
  /// **'AI that Protects You'**
  String get onboard3Title;

  /// No description provided for @onboard3Desc.
  ///
  /// In en, this message translates to:
  /// **'Our artificial intelligence predicts safe routes for you'**
  String get onboard3Desc;

  /// No description provided for @reportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report Incident'**
  String get reportIncident;

  /// No description provided for @selectType.
  ///
  /// In en, this message translates to:
  /// **'Select Incident Type'**
  String get selectType;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @witnesses.
  ///
  /// In en, this message translates to:
  /// **'Witnesses (optional)'**
  String get witnesses;

  /// No description provided for @urgencyLevel.
  ///
  /// In en, this message translates to:
  /// **'Urgency Level'**
  String get urgencyLevel;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @obtainingLocation.
  ///
  /// In en, this message translates to:
  /// **'Obtaining location...'**
  String get obtainingLocation;

  /// No description provided for @reportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully'**
  String get reportSuccess;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// No description provided for @errorLocation.
  ///
  /// In en, this message translates to:
  /// **'Could not get location'**
  String get errorLocation;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Your safety, our priority'**
  String get splashTagline;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @biometricLabel.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get biometricLabel;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Personal Data'**
  String get step1Title;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Secure Account'**
  String get step2Title;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get step3Title;

  /// No description provided for @step1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us who you are'**
  String get step1Subtitle;

  /// No description provided for @step2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your credentials'**
  String get step2Subtitle;

  /// No description provided for @step3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get step3Subtitle;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createAccountButton;

  /// No description provided for @accountSummary.
  ///
  /// In en, this message translates to:
  /// **'Account summary'**
  String get accountSummary;

  /// No description provided for @mustAcceptTerms.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get mustAcceptTerms;

  /// No description provided for @registerSuccessMsg.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! You can now log in.'**
  String get registerSuccessMsg;

  /// No description provided for @alreadyHaveAccountQ.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountQ;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginLink;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @enterFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get enterFirstName;

  /// No description provided for @enterLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get enterLastName;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone'**
  String get enterPhone;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone'**
  String get invalidPhone;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// No description provided for @minSixChars.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minSixChars;

  /// No description provided for @confirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @passWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get passWeak;

  /// No description provided for @passFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get passFair;

  /// No description provided for @passGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get passGood;

  /// No description provided for @passStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get passStrong;

  /// No description provided for @passwordIs.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordIs;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @campusStats.
  ///
  /// In en, this message translates to:
  /// **'Campus statistics'**
  String get campusStats;

  /// No description provided for @currentRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'Current Risk Level'**
  String get currentRiskLevel;

  /// No description provided for @nearbyReportsLabel.
  ///
  /// In en, this message translates to:
  /// **'nearby reports'**
  String get nearbyReportsLabel;

  /// No description provided for @criticals.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get criticals;

  /// No description provided for @highs.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get highs;

  /// No description provided for @mediums.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get mediums;

  /// No description provided for @reportsByType.
  ///
  /// In en, this message translates to:
  /// **'Reports by type'**
  String get reportsByType;

  /// No description provided for @urgencyDistribution.
  ///
  /// In en, this message translates to:
  /// **'Urgency distribution'**
  String get urgencyDistribution;

  /// No description provided for @chatWithSafeBot.
  ///
  /// In en, this message translates to:
  /// **'Talk to SafeBot'**
  String get chatWithSafeBot;

  /// No description provided for @safeBotDesc.
  ///
  /// In en, this message translates to:
  /// **'Your AI security assistant. Ask anything.'**
  String get safeBotDesc;

  /// No description provided for @sosTitle.
  ///
  /// In en, this message translates to:
  /// **'SOS Emergency'**
  String get sosTitle;

  /// No description provided for @holdToActivate.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to activate'**
  String get holdToActivate;

  /// No description provided for @sosActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get sosActiveLabel;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @callEmergencies.
  ///
  /// In en, this message translates to:
  /// **'Call\nEmergency'**
  String get callEmergencies;

  /// No description provided for @shareLocation.
  ///
  /// In en, this message translates to:
  /// **'Share\nLocation'**
  String get shareLocation;

  /// No description provided for @alertContacts.
  ///
  /// In en, this message translates to:
  /// **'Alert\nContacts'**
  String get alertContacts;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @addLabel.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addLabel;

  /// No description provided for @noEmergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'No emergency contacts'**
  String get noEmergencyContacts;

  /// No description provided for @addTrustedPeople.
  ///
  /// In en, this message translates to:
  /// **'Add trusted people who will be alerted in case of emergency'**
  String get addTrustedPeople;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by type or description...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterTheft.
  ///
  /// In en, this message translates to:
  /// **'Theft'**
  String get filterTheft;

  /// No description provided for @filterHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get filterHarassment;

  /// No description provided for @filterFight.
  ///
  /// In en, this message translates to:
  /// **'Fight'**
  String get filterFight;

  /// No description provided for @filterVandalism.
  ///
  /// In en, this message translates to:
  /// **'Vandalism'**
  String get filterVandalism;

  /// No description provided for @filterAccident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get filterAccident;

  /// No description provided for @filterSuspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious person'**
  String get filterSuspicious;

  /// No description provided for @filterLighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get filterLighting;

  /// No description provided for @filterOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get filterOther;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @quietZone.
  ///
  /// In en, this message translates to:
  /// **'Quiet zone'**
  String get quietZone;

  /// No description provided for @tryOtherFilter.
  ///
  /// In en, this message translates to:
  /// **'Try another filter or search'**
  String get tryOtherFilter;

  /// No description provided for @noNearbyIncidents.
  ///
  /// In en, this message translates to:
  /// **'No nearby incidents reported'**
  String get noNearbyIncidents;

  /// No description provided for @timeAgoNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeAgoNow;

  /// No description provided for @chatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI Security Assistant'**
  String get chatSubtitle;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineStatus;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Ask SafeBot...'**
  String get chatHint;

  /// No description provided for @chatHintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'SafeBot unavailable'**
  String get chatHintUnavailable;

  /// No description provided for @suggestion1.
  ///
  /// In en, this message translates to:
  /// **'What are the safest zones right now?'**
  String get suggestion1;

  /// No description provided for @suggestion2.
  ///
  /// In en, this message translates to:
  /// **'How do I report an incident?'**
  String get suggestion2;

  /// No description provided for @suggestion3.
  ///
  /// In en, this message translates to:
  /// **'What should I do if I\'m robbed?'**
  String get suggestion3;

  /// No description provided for @suggestion4.
  ///
  /// In en, this message translates to:
  /// **'Safe routes for this time'**
  String get suggestion4;

  /// No description provided for @suggestion5.
  ///
  /// In en, this message translates to:
  /// **'How do I activate SOS?'**
  String get suggestion5;

  /// No description provided for @safebotWelcome.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m SafeBot 🤖, your campus security assistant. I\'m aware of nearby incidents and ready to help you. How can I assist you today?'**
  String get safebotWelcome;

  /// No description provided for @safebotUnavailableMsg.
  ///
  /// In en, this message translates to:
  /// **'SafeBot is not available without a configured API key. Add GEMINI_API_KEY to the .env file to activate it.'**
  String get safebotUnavailableMsg;

  /// No description provided for @safebotConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Error contacting SafeBot. Check your connection.'**
  String get safebotConnectionError;

  /// No description provided for @verifiedStudent.
  ///
  /// In en, this message translates to:
  /// **'Verified Student'**
  String get verifiedStudent;

  /// No description provided for @statsReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get statsReports;

  /// No description provided for @statsAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get statsAlerts;

  /// No description provided for @statsRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get statsRoutes;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @notificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsLabel;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @sectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get sectionSecurity;

  /// No description provided for @emergencyContactsMenu.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContactsMenu;

  /// No description provided for @reportHistory.
  ///
  /// In en, this message translates to:
  /// **'Report History'**
  String get reportHistory;

  /// No description provided for @savedRoutes.
  ///
  /// In en, this message translates to:
  /// **'Saved Routes'**
  String get savedRoutes;

  /// No description provided for @sectionApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get sectionApp;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsMenu.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsMenu;

  /// No description provided for @safetyGuide.
  ///
  /// In en, this message translates to:
  /// **'Safety Guide'**
  String get safetyGuide;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @logoutLabel.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutLabel;

  /// No description provided for @helpKeepCampusSafe.
  ///
  /// In en, this message translates to:
  /// **'Help keep campus safe'**
  String get helpKeepCampusSafe;

  /// No description provided for @aiActive.
  ///
  /// In en, this message translates to:
  /// **'AI Active'**
  String get aiActive;

  /// No description provided for @photoSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'📸 Incident Photo'**
  String get photoSectionTitle;

  /// No description provided for @photoSectionSub.
  ///
  /// In en, this message translates to:
  /// **'Optional but helps AI classify better'**
  String get photoSectionSub;

  /// No description provided for @incidentTypeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'🚨 Incident Type'**
  String get incidentTypeSectionTitle;

  /// No description provided for @incidentTypeSectionSub.
  ///
  /// In en, this message translates to:
  /// **'Select the best matching category'**
  String get incidentTypeSectionSub;

  /// No description provided for @descriptionSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'📝 Description'**
  String get descriptionSectionTitle;

  /// No description provided for @descriptionSectionSub.
  ///
  /// In en, this message translates to:
  /// **'Tell us what happened in as much detail as possible'**
  String get descriptionSectionSub;

  /// No description provided for @urgencySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'⚡ Urgency Level'**
  String get urgencySectionTitle;

  /// No description provided for @urgencySectionSub.
  ///
  /// In en, this message translates to:
  /// **'AI will also calculate its own level'**
  String get urgencySectionSub;

  /// No description provided for @witnessesSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'👥 Witnesses'**
  String get witnessesSectionTitle;

  /// No description provided for @witnessesSectionSub.
  ///
  /// In en, this message translates to:
  /// **'Approximate number of people who witnessed the incident'**
  String get witnessesSectionSub;

  /// No description provided for @locationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'📍 Location'**
  String get locationSectionTitle;

  /// No description provided for @locationSectionSub.
  ///
  /// In en, this message translates to:
  /// **'Obtained automatically'**
  String get locationSectionSub;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @cameraOrGallery.
  ///
  /// In en, this message translates to:
  /// **'Camera or gallery'**
  String get cameraOrGallery;

  /// No description provided for @locationDetected.
  ///
  /// In en, this message translates to:
  /// **'Location detected'**
  String get locationDetected;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searching;

  /// No description provided for @waitingGps.
  ///
  /// In en, this message translates to:
  /// **'Waiting for GPS location...'**
  String get waitingGps;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get sendReport;

  /// No description provided for @aiAnalysisNotice.
  ///
  /// In en, this message translates to:
  /// **'SafeCampus AI will analyze your report, classify the incident and automatically notify students within a 500m radius.'**
  String get aiAnalysisNotice;

  /// No description provided for @aiWillAnalyzePhoto.
  ///
  /// In en, this message translates to:
  /// **'AI will analyze this photo'**
  String get aiWillAnalyzePhoto;

  /// No description provided for @describeIncident.
  ///
  /// In en, this message translates to:
  /// **'Describe the incident'**
  String get describeIncident;

  /// No description provided for @minTwentyChars.
  ///
  /// In en, this message translates to:
  /// **'Minimum 20 characters'**
  String get minTwentyChars;

  /// No description provided for @incidentDefault.
  ///
  /// In en, this message translates to:
  /// **'Incident'**
  String get incidentDefault;

  /// No description provided for @witnessCount.
  ///
  /// In en, this message translates to:
  /// **'witness'**
  String get witnessCount;

  /// No description provided for @witnessCountPlural.
  ///
  /// In en, this message translates to:
  /// **'witnesses'**
  String get witnessCountPlural;

  /// No description provided for @navSos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get navSos;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @sosAdvisorTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Assistant'**
  String get sosAdvisorTitle;

  /// No description provided for @sosAdvisorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SafeBot guides you step by step'**
  String get sosAdvisorSubtitle;

  /// No description provided for @sosWhatsHappening.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening?'**
  String get sosWhatsHappening;

  /// No description provided for @sosActionSteps.
  ///
  /// In en, this message translates to:
  /// **'Action steps'**
  String get sosActionSteps;

  /// No description provided for @sosBotPreparing.
  ///
  /// In en, this message translates to:
  /// **'SafeBot preparing tips...'**
  String get sosBotPreparing;

  /// No description provided for @emergRobo.
  ///
  /// In en, this message translates to:
  /// **'Robbery / Assault'**
  String get emergRobo;

  /// No description provided for @emergAcoso.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get emergAcoso;

  /// No description provided for @emergAccidente.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get emergAccidente;

  /// No description provided for @emergPelea.
  ///
  /// In en, this message translates to:
  /// **'Fight'**
  String get emergPelea;

  /// No description provided for @emergPeligro.
  ///
  /// In en, this message translates to:
  /// **'I feel in danger'**
  String get emergPeligro;

  /// No description provided for @emergOtro.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get emergOtro;

  /// No description provided for @myReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReportsTitle;

  /// No description provided for @noReportsSent.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t sent any reports'**
  String get noReportsSent;

  /// No description provided for @helpCommunityReport.
  ///
  /// In en, this message translates to:
  /// **'Help the community by reporting incidents on campus'**
  String get helpCommunityReport;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @safeRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'Safe Route'**
  String get safeRouteTitle;

  /// No description provided for @safeRouteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI security analysis'**
  String get safeRouteSubtitle;

  /// No description provided for @whereAreYouGoing.
  ///
  /// In en, this message translates to:
  /// **'Where are you going?'**
  String get whereAreYouGoing;

  /// No description provided for @routeOrigin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get routeOrigin;

  /// No description provided for @routeDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get routeDestination;

  /// No description provided for @analyzeWithAI.
  ///
  /// In en, this message translates to:
  /// **'Analyze Route with AI'**
  String get analyzeWithAI;

  /// No description provided for @safebotAnalyzingRoute.
  ///
  /// In en, this message translates to:
  /// **'SafeBot analyzing route...'**
  String get safebotAnalyzingRoute;

  /// No description provided for @checkingNearbyReports.
  ///
  /// In en, this message translates to:
  /// **'Checking nearby reports and calculating risk'**
  String get checkingNearbyReports;

  /// No description provided for @enterDestinationHint.
  ///
  /// In en, this message translates to:
  /// **'Enter destination'**
  String get enterDestinationHint;

  /// No description provided for @aiRouteAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Route Analysis'**
  String get aiRouteAnalysisTitle;

  /// No description provided for @aiRouteAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter origin and destination. SafeBot will analyze nearby security reports and calculate the risk level of your route.'**
  String get aiRouteAnalysisDesc;

  /// No description provided for @safetyScore.
  ///
  /// In en, this message translates to:
  /// **'Safety Score'**
  String get safetyScore;

  /// No description provided for @riskLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk'**
  String get riskLabel;

  /// No description provided for @safebotRecommendsAlternative.
  ///
  /// In en, this message translates to:
  /// **'SafeBot recommends taking an alternative route'**
  String get safebotRecommendsAlternative;

  /// No description provided for @routeTipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tips for this route'**
  String get routeTipsTitle;

  /// No description provided for @newQueryLabel.
  ///
  /// In en, this message translates to:
  /// **'New query'**
  String get newQueryLabel;

  /// No description provided for @configTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get configTitle;

  /// No description provided for @configSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get configSubtitle;

  /// No description provided for @configPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Location'**
  String get configPrivacySection;

  /// No description provided for @configAlertRadiusSection.
  ///
  /// In en, this message translates to:
  /// **'Alert Radius'**
  String get configAlertRadiusSection;

  /// No description provided for @configSoundSection.
  ///
  /// In en, this message translates to:
  /// **'Sound & Vibration'**
  String get configSoundSection;

  /// No description provided for @configInfoSection.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get configInfoSection;

  /// No description provided for @configSecurityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Security alerts'**
  String get configSecurityAlerts;

  /// No description provided for @configSecurityAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Incidents near your location'**
  String get configSecurityAlertsSub;

  /// No description provided for @configNewReports.
  ///
  /// In en, this message translates to:
  /// **'New reports'**
  String get configNewReports;

  /// No description provided for @configNewReportsSub.
  ///
  /// In en, this message translates to:
  /// **'Reports sent by the community'**
  String get configNewReportsSub;

  /// No description provided for @configSosAlerts.
  ///
  /// In en, this message translates to:
  /// **'SOS Alerts'**
  String get configSosAlerts;

  /// No description provided for @configSosAlertsSub.
  ///
  /// In en, this message translates to:
  /// **'Active emergencies on campus'**
  String get configSosAlertsSub;

  /// No description provided for @configAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'SafeBot Analysis'**
  String get configAiAnalysis;

  /// No description provided for @configAiAnalysisSub.
  ///
  /// In en, this message translates to:
  /// **'AI recommendations and trends'**
  String get configAiAnalysisSub;

  /// No description provided for @configShareLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Share location'**
  String get configShareLocationLabel;

  /// No description provided for @configShareLocationSub.
  ///
  /// In en, this message translates to:
  /// **'Required for real-time alerts'**
  String get configShareLocationSub;

  /// No description provided for @configBgLocation.
  ///
  /// In en, this message translates to:
  /// **'Background location'**
  String get configBgLocation;

  /// No description provided for @configBgLocationSub.
  ///
  /// In en, this message translates to:
  /// **'Alerts even when app is closed'**
  String get configBgLocationSub;

  /// No description provided for @configAnonReports.
  ///
  /// In en, this message translates to:
  /// **'Anonymous reports'**
  String get configAnonReports;

  /// No description provided for @configAnonReportsSub.
  ///
  /// In en, this message translates to:
  /// **'Your name won\'t appear in reports'**
  String get configAnonReportsSub;

  /// No description provided for @configDetectionRadius.
  ///
  /// In en, this message translates to:
  /// **'Detection radius'**
  String get configDetectionRadius;

  /// No description provided for @configDetectionRadiusSub.
  ///
  /// In en, this message translates to:
  /// **'Distance for alerts'**
  String get configDetectionRadiusSub;

  /// No description provided for @configSoundLabel.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get configSoundLabel;

  /// No description provided for @configSoundSub.
  ///
  /// In en, this message translates to:
  /// **'Alerts with sound'**
  String get configSoundSub;

  /// No description provided for @configVibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get configVibration;

  /// No description provided for @configVibrationSub.
  ///
  /// In en, this message translates to:
  /// **'Alerts with vibration'**
  String get configVibrationSub;

  /// No description provided for @configVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get configVersion;

  /// No description provided for @configTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get configTerms;

  /// No description provided for @configPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get configPrivacyPolicy;

  /// No description provided for @guiaTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Guide'**
  String get guiaTitle;

  /// No description provided for @guiaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency action protocols'**
  String get guiaSubtitle;

  /// No description provided for @guiaHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay prepared'**
  String get guiaHeroTitle;

  /// No description provided for @guiaHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Knowing security protocols can save lives. Tap each situation to see action steps.'**
  String get guiaHeroDesc;

  /// No description provided for @guia1Title.
  ///
  /// In en, this message translates to:
  /// **'Robbery or Assault'**
  String get guia1Title;

  /// No description provided for @guia1Step1.
  ///
  /// In en, this message translates to:
  /// **'Do not resist. Your safety is worth more than any object.'**
  String get guia1Step1;

  /// No description provided for @guia1Step2.
  ///
  /// In en, this message translates to:
  /// **'Memorize features of the attacker: clothing, height, direction taken.'**
  String get guia1Step2;

  /// No description provided for @guia1Step3.
  ///
  /// In en, this message translates to:
  /// **'Leave the area immediately and find a public, crowded place.'**
  String get guia1Step3;

  /// No description provided for @guia1Step4.
  ///
  /// In en, this message translates to:
  /// **'Call emergency services (123) and report the incident in SafeCampus.'**
  String get guia1Step4;

  /// No description provided for @guia1Step5.
  ///
  /// In en, this message translates to:
  /// **'Preserve any evidence (messages, photos) for the police report.'**
  String get guia1Step5;

  /// No description provided for @guia2Title.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get guia2Title;

  /// No description provided for @guia2Step1.
  ///
  /// In en, this message translates to:
  /// **'Leave the place and find people or campus safety zones.'**
  String get guia2Step1;

  /// No description provided for @guia2Step2.
  ///
  /// In en, this message translates to:
  /// **'Document: date, time, location, description of the aggressor.'**
  String get guia2Step2;

  /// No description provided for @guia2Step3.
  ///
  /// In en, this message translates to:
  /// **'Report in SafeCampus to alert other students.'**
  String get guia2Step3;

  /// No description provided for @guia2Step4.
  ///
  /// In en, this message translates to:
  /// **'Talk to the university welfare office or campus security.'**
  String get guia2Step4;

  /// No description provided for @guia2Step5.
  ///
  /// In en, this message translates to:
  /// **'If harassment is digital, save screenshots and block the aggressor.'**
  String get guia2Step5;

  /// No description provided for @guia3Title.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get guia3Title;

  /// No description provided for @guia3Step1.
  ///
  /// In en, this message translates to:
  /// **'Assess the situation without exposing yourself to more risks.'**
  String get guia3Step1;

  /// No description provided for @guia3Step2.
  ///
  /// In en, this message translates to:
  /// **'Call 123 (emergency) if there are injured people.'**
  String get guia3Step2;

  /// No description provided for @guia3Step3.
  ///
  /// In en, this message translates to:
  /// **'Do not move injured people unless there is imminent danger.'**
  String get guia3Step3;

  /// No description provided for @guia3Step4.
  ///
  /// In en, this message translates to:
  /// **'Signal the area to prevent more accidents.'**
  String get guia3Step4;

  /// No description provided for @guia3Step5.
  ///
  /// In en, this message translates to:
  /// **'Report the incident in SafeCampus to activate alerts in the area.'**
  String get guia3Step5;

  /// No description provided for @guia4Title.
  ///
  /// In en, this message translates to:
  /// **'Fight'**
  String get guia4Title;

  /// No description provided for @guia4Step1.
  ///
  /// In en, this message translates to:
  /// **'Do not intervene physically — call campus security.'**
  String get guia4Step1;

  /// No description provided for @guia4Step2.
  ///
  /// In en, this message translates to:
  /// **'Leave the area immediately.'**
  String get guia4Step2;

  /// No description provided for @guia4Step3.
  ///
  /// In en, this message translates to:
  /// **'Call campus security number or 123.'**
  String get guia4Step3;

  /// No description provided for @guia4Step4.
  ///
  /// In en, this message translates to:
  /// **'Report in SafeCampus with the exact location.'**
  String get guia4Step4;

  /// No description provided for @guia4Step5.
  ///
  /// In en, this message translates to:
  /// **'If there are injured, wait for emergency services.'**
  String get guia4Step5;

  /// No description provided for @guia5Title.
  ///
  /// In en, this message translates to:
  /// **'General Prevention'**
  String get guia5Title;

  /// No description provided for @guia5Step1.
  ///
  /// In en, this message translates to:
  /// **'Share your location with trusted contacts when you go alone.'**
  String get guia5Step1;

  /// No description provided for @guia5Step2.
  ///
  /// In en, this message translates to:
  /// **'Avoid poorly lit or solitary areas at night.'**
  String get guia5Step2;

  /// No description provided for @guia5Step3.
  ///
  /// In en, this message translates to:
  /// **'Keep your phone charged and volume low in risk zones.'**
  String get guia5Step3;

  /// No description provided for @guia5Step4.
  ///
  /// In en, this message translates to:
  /// **'Use earphones with one ear to stay aware of your surroundings.'**
  String get guia5Step4;

  /// No description provided for @guia5Step5.
  ///
  /// In en, this message translates to:
  /// **'Set up your emergency contacts in SafeCampus.'**
  String get guia5Step5;

  /// No description provided for @guia6Title.
  ///
  /// In en, this message translates to:
  /// **'Emergency Numbers'**
  String get guia6Title;

  /// No description provided for @guia6Step1.
  ///
  /// In en, this message translates to:
  /// **'123 — National Police'**
  String get guia6Step1;

  /// No description provided for @guia6Step2.
  ///
  /// In en, this message translates to:
  /// **'132 — Fire Department'**
  String get guia6Step2;

  /// No description provided for @guia6Step3.
  ///
  /// In en, this message translates to:
  /// **'125 — Civil Defense'**
  String get guia6Step3;

  /// No description provided for @guia6Step4.
  ///
  /// In en, this message translates to:
  /// **'115 — Red Cross'**
  String get guia6Step4;

  /// No description provided for @guia6Step5.
  ///
  /// In en, this message translates to:
  /// **'Campus security — check the institutional directory'**
  String get guia6Step5;

  /// No description provided for @notifScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifScreenTitle;

  /// No description provided for @notifScreenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your security alerts'**
  String get notifScreenSubtitle;

  /// No description provided for @notifMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifMarkAllRead;

  /// No description provided for @notifClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notifClearAll;

  /// No description provided for @notifNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notifNoNotifications;

  /// No description provided for @dashboardAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Campus AI Analysis'**
  String get dashboardAiAnalysis;

  /// No description provided for @analyzingTrends.
  ///
  /// In en, this message translates to:
  /// **'Analyzing trends...'**
  String get analyzingTrends;

  /// No description provided for @trendsNoData.
  ///
  /// In en, this message translates to:
  /// **'Trend analysis will be available when there are nearby reports.'**
  String get trendsNoData;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @saveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveLabel;

  /// No description provided for @sosCallFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not place the call'**
  String get sosCallFailed;

  /// No description provided for @sosObtainingLocationRetry.
  ///
  /// In en, this message translates to:
  /// **'Getting location... try again'**
  String get sosObtainingLocationRetry;

  /// No description provided for @sosShareLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi! I am sharing my SafeCampus safety location: {mapUrl}'**
  String sosShareLocationMessage(Object mapUrl);

  /// No description provided for @reportedIncident.
  ///
  /// In en, this message translates to:
  /// **'Reported incident'**
  String get reportedIncident;

  /// No description provided for @descriptionTitleUpper.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get descriptionTitleUpper;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get noDescriptionAvailable;

  /// No description provided for @detailsTitleUpper.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get detailsTitleUpper;

  /// No description provided for @witnessesLabel.
  ///
  /// In en, this message translates to:
  /// **'Witnesses'**
  String get witnessesLabel;

  /// No description provided for @coordinatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinatesLabel;

  /// No description provided for @shareLabel.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareLabel;

  /// No description provided for @viewOnMapLabel.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get viewOnMapLabel;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginError;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google'**
  String get googleLoginFailed;

  /// No description provided for @googleErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Google error'**
  String get googleErrorPrefix;

  /// No description provided for @biometricSetupRequired.
  ///
  /// In en, this message translates to:
  /// **'First sign in with email to enable fingerprint login'**
  String get biometricSetupRequired;

  /// No description provided for @biometricPrompt.
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to enter SafeCampus'**
  String get biometricPrompt;

  /// No description provided for @biometricUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics unavailable'**
  String get biometricUnavailable;

  /// No description provided for @sosNoContactsConfigured.
  ///
  /// In en, this message translates to:
  /// **'You have no emergency contacts configured'**
  String get sosNoContactsConfigured;

  /// No description provided for @sosEmergencyAlertMessage.
  ///
  /// In en, this message translates to:
  /// **'EMERGENCY! I\'m in SafeCampus and I need help.'**
  String get sosEmergencyAlertMessage;

  /// No description provided for @emergencyContactsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} contacts'**
  String emergencyContactsCount(Object count, Object max);

  /// No description provided for @emergencyContactsInfoBanner.
  ///
  /// In en, this message translates to:
  /// **'When SOS is activated, these contacts will receive your location and an immediate alert.'**
  String get emergencyContactsInfoBanner;

  /// No description provided for @deleteEmergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get deleteEmergencyContactTitle;

  /// No description provided for @deleteEmergencyContactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteEmergencyContactConfirm(Object name);

  /// No description provided for @addEmergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addEmergencyContactTitle;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameHint;

  /// No description provided for @relationshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationshipLabel;

  /// No description provided for @relationshipFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get relationshipFamily;

  /// No description provided for @relationshipFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get relationshipFriend;

  /// No description provided for @relationshipPartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get relationshipPartner;

  /// No description provided for @relationshipClassmate.
  ///
  /// In en, this message translates to:
  /// **'Classmate'**
  String get relationshipClassmate;

  /// No description provided for @relationshipOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get relationshipOther;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get changeProfilePhoto;

  /// No description provided for @deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete photo'**
  String get deletePhoto;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// No description provided for @errorLoadingReports.
  ///
  /// In en, this message translates to:
  /// **'Error loading reports'**
  String get errorLoadingReports;

  /// No description provided for @acceptTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I accept the '**
  String get acceptTermsPrefix;

  /// No description provided for @acceptTermsMiddle.
  ///
  /// In en, this message translates to:
  /// **' and the '**
  String get acceptTermsMiddle;

  /// No description provided for @acceptTermsSuffix.
  ///
  /// In en, this message translates to:
  /// **' of SafeCampus AI'**
  String get acceptTermsSuffix;

  /// No description provided for @incidentTheft.
  ///
  /// In en, this message translates to:
  /// **'Theft'**
  String get incidentTheft;

  /// No description provided for @incidentHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get incidentHarassment;

  /// No description provided for @incidentSuspiciousPerson.
  ///
  /// In en, this message translates to:
  /// **'Suspicious person'**
  String get incidentSuspiciousPerson;

  /// No description provided for @incidentLighting.
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get incidentLighting;

  /// No description provided for @incidentFight.
  ///
  /// In en, this message translates to:
  /// **'Fight'**
  String get incidentFight;

  /// No description provided for @incidentVandalism.
  ///
  /// In en, this message translates to:
  /// **'Vandalism'**
  String get incidentVandalism;

  /// No description provided for @incidentAccident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get incidentAccident;

  /// No description provided for @incidentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get incidentOther;

  /// No description provided for @aiShortLabel.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiShortLabel;

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI analyzing...'**
  String get aiAnalyzing;

  /// No description provided for @aiClassifying.
  ///
  /// In en, this message translates to:
  /// **'AI classifying...'**
  String get aiClassifying;

  /// No description provided for @aiReasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get aiReasonPrefix;

  /// No description provided for @incidentExampleHint.
  ///
  /// In en, this message translates to:
  /// **'Example: I saw a suspicious person wandering near the north parking lot around 10 PM...'**
  String get incidentExampleHint;

  /// No description provided for @riskAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk Analysis'**
  String get riskAnalysisTitle;

  /// No description provided for @riskAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personal AI assessment'**
  String get riskAnalysisSubtitle;

  /// No description provided for @personalLabel.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personalLabel;

  /// No description provided for @riskExposureQuestion.
  ///
  /// In en, this message translates to:
  /// **'How exposed are you?'**
  String get riskExposureQuestion;

  /// No description provided for @riskExposureInfo.
  ///
  /// In en, this message translates to:
  /// **'SafeBot analyzes your incident history, frequent areas, and schedule to calculate your personal risk profile.'**
  String get riskExposureInfo;

  /// No description provided for @analyzeRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze your risk profile'**
  String get analyzeRiskTitle;

  /// No description provided for @analyzeRiskDescription.
  ///
  /// In en, this message translates to:
  /// **'SafeBot will evaluate your exposure to risks based on incidents reported in your area and your usual schedule.'**
  String get analyzeRiskDescription;

  /// No description provided for @analyzePersonalRiskButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze my personal risk'**
  String get analyzePersonalRiskButton;

  /// No description provided for @analyzingRiskProfile.
  ///
  /// In en, this message translates to:
  /// **'SafeBot is evaluating your profile...'**
  String get analyzingRiskProfile;

  /// No description provided for @analyzingRiskContext.
  ///
  /// In en, this message translates to:
  /// **'Analyzing nearby incidents, areas, and schedule'**
  String get analyzingRiskContext;

  /// No description provided for @exposureLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Exposure Level'**
  String get exposureLevelLabel;

  /// No description provided for @riskiestZoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Riskiest area'**
  String get riskiestZoneLabel;

  /// No description provided for @vulnerableDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Vulnerable day'**
  String get vulnerableDayLabel;

  /// No description provided for @recommendedActionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Recommended actions'**
  String get recommendedActionsLabel;

  /// No description provided for @refreshAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Refresh analysis'**
  String get refreshAnalysis;

  /// No description provided for @exposureModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get exposureModerate;

  /// No description provided for @exposurePrefix.
  ///
  /// In en, this message translates to:
  /// **'Exposure'**
  String get exposurePrefix;

  /// No description provided for @notIdentified.
  ///
  /// In en, this message translates to:
  /// **'Not identified'**
  String get notIdentified;

  /// No description provided for @notIdentifiedFemale.
  ///
  /// In en, this message translates to:
  /// **'Not identified'**
  String get notIdentifiedFemale;

  /// No description provided for @morningLabel.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morningLabel;

  /// No description provided for @afternoonLabel.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoonLabel;

  /// No description provided for @nightLabel.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get nightLabel;

  /// No description provided for @generalCampusArea.
  ///
  /// In en, this message translates to:
  /// **'General campus area'**
  String get generalCampusArea;

  /// No description provided for @mainCampus.
  ///
  /// In en, this message translates to:
  /// **'Main campus'**
  String get mainCampus;

  /// No description provided for @libraryLabel.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryLabel;

  /// No description provided for @cafeteriaLabel.
  ///
  /// In en, this message translates to:
  /// **'Cafeteria'**
  String get cafeteriaLabel;

  /// No description provided for @incidentZonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Area with {type} incidents'**
  String incidentZonePrefix(Object type);

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeAgoMinutes(Object count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeAgoHours(Object count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String timeAgoDays(Object count);

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Keep me logged in'**
  String get rememberMe;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
