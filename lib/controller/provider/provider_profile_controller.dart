import 'package:flutter/material.dart';

class ProviderProfileController extends ChangeNotifier {
  String _name = 'Michael Photographer';
  String _aboutMe = 'Professional wedding and event photographer with 10+ years of experience. Specialized in capturing authentic moments and emotions.';
  List<String> _specializations = ['Wedding', 'Event', 'Portrait'];
  List<String> _languages = ['English', 'Spanish', 'Catalan'];
  List<String> _recentWork = [
    'assets/images/img1.png',
    'assets/images/img2.png',
    'assets/images/img3.png',
    'assets/images/img4.png',
    'assets/images/img5.png',
    'assets/images/img6.png',
  ];

  String get name => _name;
  String get aboutMe => _aboutMe;
  List<String> get specializations => _specializations;
  List<String> get languages => _languages;
  List<String> get recentWork => _recentWork;

  void updateProfile({
    String? name,
    String? aboutMe,
    List<String>? specializations,
    List<String>? languages,
    List<String>? recentWork,
  }) {
    if (name != null) _name = name;
    if (aboutMe != null) _aboutMe = aboutMe;
    if (specializations != null) _specializations = specializations;
    if (languages != null) _languages = languages;
    if (recentWork != null) _recentWork = recentWork;
    notifyListeners();
  }

  void addSpecialization(String spec) {
    if (!_specializations.contains(spec)) {
      _specializations.add(spec);
      notifyListeners();
    }
  }

  void removeSpecialization(String spec) {
    _specializations.remove(spec);
    notifyListeners();
  }

  void addLanguage(String lang) {
    if (!_languages.contains(lang)) {
      _languages.add(lang);
      notifyListeners();
    }
  }

  void removeLanguage(String lang) {
    _languages.remove(lang);
    notifyListeners();
  }

  void addRecentWork(String url) {
    _recentWork.add(url);
    notifyListeners();
  }

  void removeRecentWork(String url) {
    _recentWork.remove(url);
    notifyListeners();
  }
}
