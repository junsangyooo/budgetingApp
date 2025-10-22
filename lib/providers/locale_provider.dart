import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 전체의 언어를 관리하는 Provider
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en'); // 기본값: 영어

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  /// SharedPreferences에서 저장된 언어 불러오기
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  /// 언어 변경 및 저장
  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    notifyListeners();

    // SharedPreferences에 저장 (앱 재시작 후에도 유지)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  /// 시스템 언어로 초기화 (선택사항)
  void clearLocale() {
    _locale = const Locale('en');
    notifyListeners();
  }
}
