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

  @override
  String get transactions => '거래 내역';

  @override
  String get noTransactionsFound => '거래 내역이 없습니다';

  @override
  String get allAccounts => '모든 계좌';

  @override
  String get allTime => '전체 기간';

  @override
  String get allCategories => '모든 카테고리';

  @override
  String get selectAccountOrCurrency => '계좌 또는 통화 선택';

  @override
  String get currencies => '통화';

  @override
  String get accounts => '계좌';

  @override
  String get selectPeriod => '기간 선택';

  @override
  String get thisMonth => '이번 달';

  @override
  String get lastThreeMonths => '최근 3개월';

  @override
  String get customRange => '사용자 지정';

  @override
  String get income => '수입';

  @override
  String get expense => '지출';

  @override
  String get balance => '잔액';

  @override
  String get food => '식료품';

  @override
  String get dining => '외식';

  @override
  String get drinks => '음료';

  @override
  String get transportation => '교통';

  @override
  String get housing => '주거';

  @override
  String get subscription => '구독';

  @override
  String get shopping => '쇼핑';

  @override
  String get health => '건강';

  @override
  String get education => '교육';

  @override
  String get entertainment => '여가';

  @override
  String get gifts => '선물';

  @override
  String get investment => '투자';

  @override
  String get others => '기타';

  @override
  String get deleteTransaction => '거래 삭제';

  @override
  String deleteConfirmation(String title) {
    return '\"$title\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get transactionDeleted => '거래가 삭제되었습니다';

  @override
  String get addTransaction => '거래 추가';

  @override
  String get editTransaction => '거래 수정';

  @override
  String get title => '제목';

  @override
  String get amount => '금액';

  @override
  String get category => '카테고리';

  @override
  String get account => '계좌';

  @override
  String get date => '날짜';

  @override
  String get note => '메모 (선택사항)';

  @override
  String get save => '저장';

  @override
  String get pleaseEnterTitle => '제목을 입력하세요';

  @override
  String get pleaseEnterAmount => '금액을 입력하세요';

  @override
  String get pleaseSelectAccount => '계좌를 선택하세요';

  @override
  String get transactionAdded => '거래가 추가되었습니다';

  @override
  String get transactionUpdated => '거래가 수정되었습니다';

  @override
  String get noAccounts => '계좌 없음';

  @override
  String get createAccountFirst => '거래를 추가하기 전에 먼저 계좌를 만들어주세요.';

  @override
  String get ok => '확인';

  @override
  String get loading => '로딩 중...';

  @override
  String currencyLabel(String code) {
    return '통화: $code';
  }

  @override
  String accountLabel(int id) {
    return '계좌: #$id';
  }
}
