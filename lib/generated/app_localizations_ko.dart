// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get welcomeTitle => '예산 트래커에 오신 것을 환영합니다';

  @override
  String get chooseLanguage => '선호하는 언어를 선택하세요';

  @override
  String get confirm => '확인';

  @override
  String get createFirstAccount => '첫 번째 계좌 생성';

  @override
  String get setupAccountDesc => '시작하려면 최소 한 개의 계좌를 설정하세요';

  @override
  String get accountName => '계좌 이름';

  @override
  String get accountNameHint => '예: 내 체크 계좌';

  @override
  String get currency => '통화';

  @override
  String get initialBalance => '초기 잔액';

  @override
  String get finishSetup => '설정 완료';

  @override
  String get youCanAddMore => '설정에서 나중에 더 많은 통화와 계좌를 추가할 수 있습니다';

  @override
  String get english => 'English';

  @override
  String get korean => '한국어';

  @override
  String get defaultCurrencyUSD => '기본 통화: USD';

  @override
  String get defaultCurrencyKRW => '기본 통화: KRW';

  @override
  String get pleaseSelectLanguage => '언어를 선택해주세요';

  @override
  String get pleaseEnterAccountName => '계좌 이름을 입력하세요';

  @override
  String get pleaseEnterBalance => '초기 잔액을 입력하세요';

  @override
  String get pleaseEnterValidNumber => '유효한 숫자를 입력하세요';

  @override
  String errorOccurred(String error) {
    return '오류: $error';
  }

  @override
  String get selectCurrency => '통화 선택';

  @override
  String get searchCurrency => '통화 검색...';
}
