// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SafeCampus AI';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Login to your account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get registerButton => 'Register';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get createReport => 'Create Report';

  @override
  String get mapTitle => 'Safety Map';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get lowRisk => 'Low';

  @override
  String get mediumRisk => 'Medium';

  @override
  String get highRisk => 'High';

  @override
  String get criticalRisk => 'Critical';

  @override
  String get onboard1Title => 'Stay Safe';

  @override
  String get onboard1Desc =>
      'Know risk zones in real time inside and outside campus';

  @override
  String get onboard2Title => 'Report Incidents';

  @override
  String get onboard2Desc =>
      'Help your community by reporting dangerous situations instantly';

  @override
  String get onboard3Title => 'AI that Protects You';

  @override
  String get onboard3Desc =>
      'Our artificial intelligence predicts safe routes for you';

  @override
  String get reportIncident => 'Report Incident';

  @override
  String get selectType => 'Select Incident Type';

  @override
  String get description => 'Description';

  @override
  String get witnesses => 'Witnesses (optional)';

  @override
  String get urgencyLevel => 'Urgency Level';

  @override
  String get location => 'Location';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get obtainingLocation => 'Obtaining location...';

  @override
  String get reportSuccess => 'Report submitted successfully';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get errorLocation => 'Could not get location';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get critical => 'Critical';
}
