// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get about => 'アプリについて';

  @override
  String get analysisBoard => '解析ボード';

  @override
  String get back => '戻る';

  @override
  String get black => '黒';

  @override
  String get cancelPremoves => 'プレムーブを取り消す';

  @override
  String get chessnutExperimental => 'Chessnut（試験的機能）';

  @override
  String get connectChessnut => 'Chessnutに接続';

  @override
  String get disconnect => '切断';

  @override
  String get engineSettings => 'エンジン設定';

  @override
  String get gameMenu => '対局メニュー';

  @override
  String get gameReady => '対局の準備完了';

  @override
  String get gameSettings => '対局設定';

  @override
  String get home => 'ホーム';

  @override
  String get playMaia => 'Maiaと対局';

  @override
  String get random => 'ランダム';

  @override
  String get recentGames => '最近の対局';

  @override
  String get resign => '投了';

  @override
  String get settings => '設定';

  @override
  String get startGame => '対局開始';

  @override
  String get timeControl => '持ち時間';

  @override
  String get white => '白';

  @override
  String get unlimited => '無制限';

  @override
  String get custom => 'カスタム';

  @override
  String get seconds => '秒';

  @override
  String get yourSide => '駒の色';

  @override
  String get you => 'あなた';

  @override
  String get systemDefault => '端末の設定に従う';

  @override
  String get language => '言語';

  @override
  String get playMaiaRating => '対局用Maiaのレーティング';

  @override
  String get minutes => '分';

  @override
  String get increment => '1手ごとの追加時間';

  @override
  String get gameSounds => '対局の効果音';

  @override
  String get movesCapturesErrorsAndGameEnd => '指し手、駒取り、エラー、対局終了時の音';

  @override
  String get hapticFeedback => '振動フィードバック';

  @override
  String get touchFeedbackForMovesChecksErrorsAndGameEnd =>
      '指し手、チェック、エラー、対局終了時の振動';

  @override
  String get premoves => 'プレムーブ';

  @override
  String get queueAMoveWhileMaiaIsThinking => 'Maiaの手番中に次の手を予約';

  @override
  String get oneHundredMsPremovePenalty => 'プレムーブの0.1秒消費';

  @override
  String get use01SecondsPerPremoveInTimedGames => '持ち時間ありの対局でプレムーブごとに0.1秒消費';

  @override
  String get allowMultiplePremoves => '複数のプレムーブを許可';

  @override
  String get queueASequenceAnIllegalMoveCancelsTheRest =>
      '複数の手を予約できます。指せない手があると、そこから先の予約は取り消されます';

  @override
  String get humanMoveTiming => '人間らしい思考時間';

  @override
  String get variableNaturalPausesBeforeMaiaMoves =>
      'Maiaが指すまでの待ち時間に自然なばらつきを加えます';

  @override
  String get aboutTemperatureAndTopP => 'TemperatureとTop-Pについて';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top-P';

  @override
  String get maiaAnalysisRating => '解析用Maiaのレーティング';

  @override
  String get addSecondMaiaEngine => '2つ目のMaiaエンジンを追加';

  @override
  String get compareAnotherMaiaRatingInAnalysisAndReview =>
      '解析や棋譜レビューで、異なるレーティングのMaiaを比較します';

  @override
  String get secondMaiaAnalysisRating => '2つ目のMaiaのレーティング';

  @override
  String get gameAnalysisQuality => '対局解析の品質';

  @override
  String get resetEngineDefaults => 'エンジン設定を初期化';

  @override
  String get boardSounds => '電子盤の通知音';

  @override
  String get beepForCheckCheckmateAndCompletedIllegalMoves =>
      'チェック、チェックメイト、反則手を指したときに音で知らせます。';

  @override
  String get copyDiagnostics => '診断情報をコピー';

  @override
  String get diagnosticsCopied => '診断情報をコピーしました';

  @override
  String get newGame => '新しい対局';

  @override
  String get resetGame => '対局をリセット';

  @override
  String get shareAndExport => '共有とエクスポート';

  @override
  String get savePgnFile => 'PGNファイルを保存';

  @override
  String get sharePgn => 'PGNを共有';

  @override
  String get copyPgn => 'PGNをコピー';

  @override
  String get copyFen => 'FENをコピー';

  @override
  String get maiaErrorRetry => 'Maiaエラー：再試行';

  @override
  String get maiaErrorPleaseRetry => 'Maiaでエラーが発生しました。再試行してください。';

  @override
  String get retry => '再試行';

  @override
  String get maiaIsThinking => 'Maiaが思考中…';

  @override
  String get history => '履歴';

  @override
  String get start => '開始';

  @override
  String get chessnutStatus => 'Chessnutの状態';

  @override
  String get leaveCurrentGame => '対局から離れますか？';

  @override
  String get yourGameWillBeKeptInRecentGames => '対局は「最近の対局」に保存されます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get continueAction => '続ける';

  @override
  String get startANewGame => '新しい対局を始めますか？';

  @override
  String get resetGameQuestion => '対局をリセットしますか？';

  @override
  String get yourCompletedGameWillRemainInRecentGames => '終了した対局は「最近の対局」に残ります。';

  @override
  String get thisGameWillBePermanentlyErased => 'この対局は完全に削除されます。';

  @override
  String get startNewGame => '新しい対局を開始';

  @override
  String get reset => 'リセット';

  @override
  String get flipBoard => '盤を反転';

  @override
  String get offerDraw => '引き分けを提案';

  @override
  String get takeBackMove => '手を戻す';

  @override
  String get whiteIsVictorious => '白の勝ち';

  @override
  String get blackIsVictorious => '黒の勝ち';

  @override
  String get theGameIsADraw => '引き分け';

  @override
  String get theGameHasEnded => '対局終了';

  @override
  String get rematch => '再対局';

  @override
  String get fast => '高速';

  @override
  String get balanced => '標準';

  @override
  String get thorough => '詳細';

  @override
  String get continueFromHere => 'ここから対局';

  @override
  String get load => '読み込む';

  @override
  String get editBoard => '盤面を編集';

  @override
  String get done => '完了';

  @override
  String get whitePieces => '白の駒';

  @override
  String get blackPieces => '黒の駒';

  @override
  String get whiteToMove => '白の手番';

  @override
  String get blackToMove => '黒の手番';

  @override
  String get castlingRights => 'キャスリングの可否';

  @override
  String get whiteKingside => '白のキングサイド';

  @override
  String get whiteQueenside => '白のクイーンサイド';

  @override
  String get blackKingside => '黒のキングサイド';

  @override
  String get blackQueenside => '黒のクイーンサイド';

  @override
  String get enPassantTarget => 'アンパッサン対象マス';

  @override
  String get startingPosition => '初期配置';

  @override
  String get clearBoard => '駒をすべて取り除く';

  @override
  String get loadFen => 'FENを読み込む';

  @override
  String get loadPgn => 'PGNを読み込む';

  @override
  String get openPgnFile => 'PGNファイルを開く';

  @override
  String get clearMoves => '指し手を消去';

  @override
  String get boardEditor => '盤面エディター';

  @override
  String get endPosition => '最後の局面';

  @override
  String get analysisMenu => '解析メニュー';

  @override
  String get turnEngineOff => 'エンジンをオフ';

  @override
  String get turnEngineOn => 'エンジンをオン';

  @override
  String get moves => '指し手';

  @override
  String get computerAnalysis => 'コンピューター解析';

  @override
  String get backToGame => '対局に戻る';
}
