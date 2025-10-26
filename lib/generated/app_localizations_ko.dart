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
  String get filter => '필터';

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

  @override
  String get currency_USD => '미국 달러';

  @override
  String get currency_EUR => '유로';

  @override
  String get currency_GBP => '영국 파운드';

  @override
  String get currency_JPY => '일본 엔';

  @override
  String get currency_CNY => '중국 위안';

  @override
  String get currency_KRW => '원';

  @override
  String get currency_CAD => '캐나다 달러';

  @override
  String get currency_AUD => '호주 달러';

  @override
  String get currency_CHF => '스위스 프랑';

  @override
  String get currency_HKD => '홍콩 달러';

  @override
  String get currency_SGD => '싱가포르 달러';

  @override
  String get currency_NZD => '뉴질랜드 달러';

  @override
  String get navHome => '홈';

  @override
  String get navSummary => '요약';

  @override
  String get navSettings => '설정';

  @override
  String get settings => '설정';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get subscriptions => '구독';

  @override
  String get addSubscription => '구독 추가';

  @override
  String get subscriptionName => '구독 이름';

  @override
  String get subscriptionAmount => '금액';

  @override
  String get subscriptionAccount => '계좌';

  @override
  String get subscriptionStartDate => '시작 날짜';

  @override
  String get subscriptionEndDate => '종료 날짜 (선택사항)';

  @override
  String get subscriptionPayingDate => '결제 날짜';

  @override
  String get subscriptionFrequency => '주기';

  @override
  String get deleteSubscription => '구독 삭제';

  @override
  String deleteSubscriptionConfirm(String name) {
    return '구독 \"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get subscriptionAdded => '구독이 성공적으로 추가되었습니다';

  @override
  String get subscriptionUpdated => '구독이 성공적으로 수정되었습니다';

  @override
  String get subscriptionDeleted => '구독이 성공적으로 삭제되었습니다';

  @override
  String get noSubscriptions => '구독 없음';

  @override
  String get monthly => '월간';

  @override
  String get pleaseEnterSubscriptionName => '구독 이름을 입력하세요';

  @override
  String get pleaseEnterSubscriptionAmount => '금액을 입력하세요';

  @override
  String get pleaseSelectSubscriptionAccount => '계좌를 선택하세요';

  @override
  String get categories => '카테고리';

  @override
  String get manageCategories => '카테고리 관리';

  @override
  String get addCategory => '카테고리 추가';

  @override
  String get categoryName => '카테고리 이름';

  @override
  String get newAccountTitle => '새 계좌';

  @override
  String get addNewAccount => '새 계좌 추가';

  @override
  String get deleteAccount => '계좌 삭제';

  @override
  String deleteAccountConfirm(String name) {
    return '계좌 \"$name\"을(를) 삭제하시겠습니까? 관련된 모든 거래가 삭제됩니다.';
  }

  @override
  String get accountDeleted => '계좌가 성공적으로 삭제되었습니다';

  @override
  String get accountAdded => '계좌가 성공적으로 추가되었습니다';

  @override
  String get categoryAdded => '카테고리가 성공적으로 추가되었습니다';

  @override
  String get categoryDeleted => '카테고리가 성공적으로 삭제되었습니다';

  @override
  String get pleaseEnterCategoryName => '카테고리 이름을 입력하세요';

  @override
  String get editCategory => '카테고리 수정';

  @override
  String get categoryUpdated => '카테고리가 성공적으로 수정되었습니다';

  @override
  String get summary => '요약';

  @override
  String get monthlyNetStats => '월별 순이익 통계';

  @override
  String get categoryBreakdown => '카테고리별 분석';

  @override
  String get selectCategories => '카테고리 선택';

  @override
  String get selectAccountOrCurrencyForChart => '계좌 또는 통화 선택';

  @override
  String get noData => '사용 가능한 데이터가 없습니다';

  @override
  String get all => '전체';
}
