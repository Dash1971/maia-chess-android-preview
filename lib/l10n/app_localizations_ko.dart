// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get about => '앱 정보';

  @override
  String get analysisBoard => '분석 보드';

  @override
  String get back => '뒤로';

  @override
  String get black => '흑';

  @override
  String get cancelPremoves => '예약 수 취소';

  @override
  String get chessnutExperimental => 'Chessnut(실험 기능)';

  @override
  String get connectChessnut => 'Chessnut 연결';

  @override
  String get disconnect => '연결 해제';

  @override
  String get engineSettings => '엔진 설정';

  @override
  String get gameMenu => '대국 메뉴';

  @override
  String get gameReady => '대국 준비 완료';

  @override
  String get gameSettings => '대국 설정';

  @override
  String get home => '홈';

  @override
  String get playMaia => 'Maia와 대국';

  @override
  String get random => '무작위';

  @override
  String get recentGames => '최근 대국';

  @override
  String get resign => '기권';

  @override
  String get settings => '설정';

  @override
  String get startGame => '대국 시작';

  @override
  String get timeControl => '시간 제한';

  @override
  String get white => '백';

  @override
  String get unlimited => '무제한';

  @override
  String get custom => '사용자 지정';

  @override
  String get seconds => '초';

  @override
  String get yourSide => '내 진영';

  @override
  String get you => '나';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get language => '언어';

  @override
  String get playMaiaRating => '대국 Maia 레이팅';

  @override
  String get minutes => '분';

  @override
  String get increment => '증분';

  @override
  String get gameSounds => '대국 소리';

  @override
  String get movesCapturesErrorsAndGameEnd => '수, 기물 잡기, 오류 및 대국 종료 소리';

  @override
  String get hapticFeedback => '햅틱 피드백';

  @override
  String get touchFeedbackForMovesChecksErrorsAndGameEnd =>
      '수, 체크, 오류 및 대국 종료 시 진동';

  @override
  String get premoves => '예약 수';

  @override
  String get queueAMoveWhileMaiaIsThinking => 'Maia 차례에 다음 수 예약';

  @override
  String get oneHundredMsPremovePenalty => '예약 수 100ms 시간 차감';

  @override
  String get use01SecondsPerPremoveInTimedGames => '시간제 대국에서 예약 수마다 0.1초 차감';

  @override
  String get allowMultiplePremoves => '여러 예약 수 허용';

  @override
  String get queueASequenceAnIllegalMoveCancelsTheRest =>
      '연속 예약 가능. 불법 수가 나오면 나머지는 취소됩니다';

  @override
  String get humanMoveTiming => '사람처럼 두기';

  @override
  String get variableNaturalPausesBeforeMaiaMoves =>
      'Maia가 두기 전 자연스러운 대기 시간 추가';

  @override
  String get aboutTemperatureAndTopP => 'Temperature와 Top-P 정보';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top-P';

  @override
  String get maiaAnalysisRating => 'Maia 분석 레이팅';

  @override
  String get addSecondMaiaEngine => '두 번째 Maia 엔진 추가';

  @override
  String get compareAnotherMaiaRatingInAnalysisAndReview =>
      '분석과 복기에서 다른 Maia 레이팅 비교';

  @override
  String get secondMaiaAnalysisRating => '두 번째 Maia 분석 레이팅';

  @override
  String get gameAnalysisQuality => '대국 분석 품질';

  @override
  String get resetEngineDefaults => '엔진 기본값 복원';

  @override
  String get boardSounds => '보드 소리';

  @override
  String get beepForCheckCheckmateAndCompletedIllegalMoves =>
      '체크, 체크메이트 및 완료된 불법 수에 알림음을 냅니다.';

  @override
  String get copyDiagnostics => '진단 정보 복사';

  @override
  String get diagnosticsCopied => '진단 정보가 복사되었습니다';

  @override
  String get newGame => '새 대국';

  @override
  String get resetGame => '대국 초기화';

  @override
  String get shareAndExport => '공유 및 내보내기';

  @override
  String get savePgnFile => 'PGN 파일 저장';

  @override
  String get sharePgn => 'PGN 공유';

  @override
  String get copyPgn => 'PGN 복사';

  @override
  String get copyFen => 'FEN 복사';

  @override
  String get maiaErrorRetry => 'Maia 오류. 다시 시도';

  @override
  String get maiaErrorPleaseRetry => 'Maia 오류. 다시 시도해 주세요.';

  @override
  String get retry => '다시 시도';

  @override
  String get maiaIsThinking => 'Maia가 수를 고르는 중…';

  @override
  String get history => '기록';

  @override
  String get start => '시작';

  @override
  String get chessnutStatus => 'Chessnut 상태';

  @override
  String get leaveCurrentGame => '현재 대국을 나가시겠습니까?';

  @override
  String get yourGameWillBeKeptInRecentGames => '대국은 최근 대국에 보관됩니다.';

  @override
  String get cancel => '취소';

  @override
  String get continueAction => '계속';

  @override
  String get startANewGame => '새 대국을 시작하시겠습니까?';

  @override
  String get resetGameQuestion => '대국을 초기화하시겠습니까?';

  @override
  String get yourCompletedGameWillRemainInRecentGames => '완료된 대국은 최근 대국에 남습니다.';

  @override
  String get thisGameWillBePermanentlyErased => '이 대국은 영구적으로 삭제됩니다.';

  @override
  String get startNewGame => '새 대국 시작';

  @override
  String get reset => '초기화';

  @override
  String get flipBoard => '보드 뒤집기';

  @override
  String get offerDraw => '무승부 제안';

  @override
  String get takeBackMove => '한 수 무르기';

  @override
  String get whiteIsVictorious => '백 승리';

  @override
  String get blackIsVictorious => '흑 승리';

  @override
  String get theGameIsADraw => '무승부';

  @override
  String get theGameHasEnded => '대국 종료';

  @override
  String get rematch => '재대국';

  @override
  String get fast => '빠름';

  @override
  String get balanced => '균형';

  @override
  String get thorough => '정밀';

  @override
  String get continueFromHere => '여기서 계속 두기';

  @override
  String get load => '불러오기';

  @override
  String get editBoard => '보드 편집';

  @override
  String get done => '완료';

  @override
  String get whitePieces => '백 기물';

  @override
  String get blackPieces => '흑 기물';

  @override
  String get whiteToMove => '백 차례';

  @override
  String get blackToMove => '흑 차례';

  @override
  String get castlingRights => '캐슬링 권리';

  @override
  String get whiteKingside => '백 킹사이드';

  @override
  String get whiteQueenside => '백 퀸사이드';

  @override
  String get blackKingside => '흑 킹사이드';

  @override
  String get blackQueenside => '흑 퀸사이드';

  @override
  String get enPassantTarget => '앙파상 대상 칸';

  @override
  String get startingPosition => '시작 위치';

  @override
  String get clearBoard => '보드 비우기';

  @override
  String get loadFen => 'FEN 불러오기';

  @override
  String get loadPgn => 'PGN 불러오기';

  @override
  String get openPgnFile => 'PGN 파일 열기';

  @override
  String get clearMoves => '수 삭제';

  @override
  String get boardEditor => '보드 편집기';

  @override
  String get endPosition => '마지막 위치';

  @override
  String get analysisMenu => '분석 메뉴';

  @override
  String get turnEngineOff => '엔진 끄기';

  @override
  String get turnEngineOn => '엔진 켜기';

  @override
  String get moves => '수';

  @override
  String get computerAnalysis => '컴퓨터 분석';

  @override
  String get backToGame => '대국으로 돌아가기';
}
