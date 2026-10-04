// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get about => '关于';

  @override
  String get analysisBoard => '分析棋盘';

  @override
  String get back => '返回';

  @override
  String get black => '黑方';

  @override
  String get cancelPremoves => '取消预走';

  @override
  String get chessnutExperimental => 'Chessnut（实验性）';

  @override
  String get connectChessnut => '连接 Chessnut';

  @override
  String get disconnect => '断开连接';

  @override
  String get engineSettings => '引擎设置';

  @override
  String get gameMenu => '对局菜单';

  @override
  String get gameReady => '对局已准备就绪';

  @override
  String get gameSettings => '对局设置';

  @override
  String get home => '主页';

  @override
  String get playMaia => '与 Maia 对弈';

  @override
  String get random => '随机';

  @override
  String get recentGames => '最近的对局';

  @override
  String get resign => '认输';

  @override
  String get settings => '设置';

  @override
  String get startGame => '开始对局';

  @override
  String get timeControl => '用时设置';

  @override
  String get white => '白方';

  @override
  String get unlimited => '无限制';

  @override
  String get custom => '自定义';

  @override
  String get seconds => '秒';

  @override
  String get yourSide => '执棋颜色';

  @override
  String get you => '你';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get language => '语言';

  @override
  String get playMaiaRating => '对手 Maia 的等级分';

  @override
  String get minutes => '分钟';

  @override
  String get increment => '每步加秒';

  @override
  String get gameSounds => '对局音效';

  @override
  String get movesCapturesErrorsAndGameEnd => '走棋、吃子、错误及对局结束时的音效';

  @override
  String get hapticFeedback => '触觉反馈';

  @override
  String get touchFeedbackForMovesChecksErrorsAndGameEnd => '走棋、将军、错误及对局结束时的振动';

  @override
  String get premoves => '预走';

  @override
  String get queueAMoveWhileMaiaIsThinking => '在 Maia 思考时预设下一步棋';

  @override
  String get oneHundredMsPremovePenalty => '预走扣除 100 毫秒';

  @override
  String get use01SecondsPerPremoveInTimedGames => '计时对局中每次预走扣除 0.1 秒';

  @override
  String get allowMultiplePremoves => '允许连续预走';

  @override
  String get queueASequenceAnIllegalMoveCancelsTheRest =>
      '可预设多步棋；若某一步无法合法走出，将取消该步及之后的预走';

  @override
  String get humanMoveTiming => '模拟思考时间';

  @override
  String get variableNaturalPausesBeforeMaiaMoves => 'Maia 走棋前加入时长不一的自然停顿';

  @override
  String get aboutTemperatureAndTopP => '关于 Temperature 和 Top-P';

  @override
  String get temperature => 'Temperature';

  @override
  String get topP => 'Top-P';

  @override
  String get maiaAnalysisRating => 'Maia 分析等级分';

  @override
  String get addSecondMaiaEngine => '添加第二个 Maia 引擎';

  @override
  String get compareAnotherMaiaRatingInAnalysisAndReview =>
      '在分析和复盘中比较另一等级分的 Maia';

  @override
  String get secondMaiaAnalysisRating => '第二个 Maia 的分析等级分';

  @override
  String get gameAnalysisQuality => '对局分析质量';

  @override
  String get resetEngineDefaults => '恢复引擎默认设置';

  @override
  String get boardSounds => '电子棋盘提示音';

  @override
  String get beepForCheckCheckmateAndCompletedIllegalMoves =>
      '将军、将死或走出不合法的棋步时发出提示音。';

  @override
  String get copyDiagnostics => '复制诊断信息';

  @override
  String get diagnosticsCopied => '已复制诊断信息';

  @override
  String get newGame => '新对局';

  @override
  String get resetGame => '重置对局';

  @override
  String get shareAndExport => '分享与导出';

  @override
  String get savePgnFile => '保存 PGN 文件';

  @override
  String get sharePgn => '分享 PGN';

  @override
  String get copyPgn => '复制 PGN';

  @override
  String get copyFen => '复制 FEN';

  @override
  String get maiaErrorRetry => 'Maia 出错。重试';

  @override
  String get maiaErrorPleaseRetry => 'Maia 出错。请重试。';

  @override
  String get retry => '重试';

  @override
  String get maiaIsThinking => 'Maia 正在思考…';

  @override
  String get history => '历史记录';

  @override
  String get start => '开始';

  @override
  String get chessnutStatus => 'Chessnut 状态';

  @override
  String get leaveCurrentGame => '离开当前对局？';

  @override
  String get yourGameWillBeKeptInRecentGames => '对局将保留在“最近的对局”中。';

  @override
  String get cancel => '取消';

  @override
  String get continueAction => '继续';

  @override
  String get startANewGame => '开始新对局？';

  @override
  String get resetGameQuestion => '重置对局？';

  @override
  String get yourCompletedGameWillRemainInRecentGames => '已结束的对局仍会保留在“最近的对局”中。';

  @override
  String get thisGameWillBePermanentlyErased => '该对局将被永久删除。';

  @override
  String get startNewGame => '开始新对局';

  @override
  String get reset => '重置';

  @override
  String get flipBoard => '翻转棋盘';

  @override
  String get offerDraw => '提议和棋';

  @override
  String get takeBackMove => '悔棋';

  @override
  String get whiteIsVictorious => '白方获胜';

  @override
  String get blackIsVictorious => '黑方获胜';

  @override
  String get theGameIsADraw => '和棋';

  @override
  String get theGameHasEnded => '对局已结束';

  @override
  String get rematch => '再来一局';

  @override
  String get fast => '快速';

  @override
  String get balanced => '均衡';

  @override
  String get thorough => '详细';

  @override
  String get continueFromHere => '从此处继续对局';

  @override
  String get load => '加载';

  @override
  String get editBoard => '编辑棋盘';

  @override
  String get done => '完成';

  @override
  String get whitePieces => '白方棋子';

  @override
  String get blackPieces => '黑方棋子';

  @override
  String get whiteToMove => '白方走棋';

  @override
  String get blackToMove => '黑方走棋';

  @override
  String get castlingRights => '王车易位权利';

  @override
  String get whiteKingside => '白方短易位';

  @override
  String get whiteQueenside => '白方长易位';

  @override
  String get blackKingside => '黑方短易位';

  @override
  String get blackQueenside => '黑方长易位';

  @override
  String get enPassantTarget => '吃过路兵目标格';

  @override
  String get startingPosition => '初始局面';

  @override
  String get clearBoard => '清空棋盘';

  @override
  String get loadFen => '加载 FEN';

  @override
  String get loadPgn => '加载 PGN';

  @override
  String get openPgnFile => '打开 PGN 文件';

  @override
  String get clearMoves => '清除着法';

  @override
  String get boardEditor => '棋盘编辑器';

  @override
  String get endPosition => '最后局面';

  @override
  String get analysisMenu => '分析菜单';

  @override
  String get turnEngineOff => '关闭引擎';

  @override
  String get turnEngineOn => '开启引擎';

  @override
  String get moves => '着法';

  @override
  String get computerAnalysis => '电脑分析';

  @override
  String get backToGame => '返回对局';
}
