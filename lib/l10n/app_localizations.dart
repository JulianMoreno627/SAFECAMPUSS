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
