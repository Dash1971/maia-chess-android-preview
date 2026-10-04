part of '../main.dart';

const appLanguagePreferenceKey = 'appLanguageV1';

class AppLanguageSettings extends InheritedWidget {
  const AppLanguageSettings({
    required this.selectedCode,
    required this.onChanged,
    required super.child,
    super.key,
  });

  final String? selectedCode;
  final ValueChanged<String?> onChanged;

  static AppLanguageSettings? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLanguageSettings>();

  @override
  bool updateShouldNotify(AppLanguageSettings oldWidget) =>
      selectedCode != oldWidget.selectedCode ||
      onChanged != oldWidget.onChanged;
}

// The first Dev-only Japanese slice. Unknown strings remain English while the
// rest of the interface is migrated; never translate stored game data or PGN.
String appText(BuildContext context, String english) {
  if (Localizations.maybeLocaleOf(context)?.languageCode != 'ja') {
    return english;
  }
  return _japaneseUiText[english] ?? english;
}

const _japaneseUiText = <String, String>{
  'About': 'アプリについて',
  'Analysis Board': '解析盤',
  'Back': '戻る',
  'Black': '黒',
  'Cancel premoves': 'プレムーブを取り消す',
  'Chessnut (experimental)': 'Chessnut（試験中）',
  'Connect Chessnut': 'Chessnutに接続',
  'Disconnect': '切断',
  'Engine settings': 'エンジン設定',
  'Game menu': '対局メニュー',
  'Game ready': '対局の準備完了',
  'Game settings': '対局設定',
  'Home': 'ホーム',
  'Play Maia': 'Maiaと対局',
  'Random': 'ランダム',
  'Recent games': '最近の対局',
  'Resign': '投了',
  'Settings': '設定',
  'Start game': '対局開始',
  'Time control': '持ち時間',
  'White': '白',
  'Unlimited': '無制限',
  'Custom': 'カスタム',
  'seconds': '秒',
  'Your side': '自分の駒色',
  'You': 'あなた',
  'System default': '端末の設定に従う',
  'Language': '言語',
  'Play Maia rating': '対局用Maiaレート',
  'Minutes': '分',
  'Increment': '追加秒',
  'Game sounds': '対局の効果音',
  'Moves, captures, errors, and game end': '指し手、駒取り、エラー、対局終了時の音',
  'Haptic feedback': '振動フィードバック',
  'Touch feedback for moves, checks, errors, and game end':
      '指し手、王手、エラー、対局終了時の振動',
  'Premoves': 'プレムーブ',
  'Queue a move while Maia is thinking': 'Maiaの手番中に次の手を予約',
  '100 ms premove penalty': 'プレムーブの0.1秒消費',
  'Use 0.1 seconds per premove in timed games': '持ち時間ありの対局でプレムーブごとに0.1秒消費',
  'Allow multiple premoves': '複数のプレムーブを許可',
  'Queue a sequence; an illegal move cancels the rest':
      '連続して予約できます。違法手以降は取り消されます',
  'Human move timing': '人間らしい指し手の間',
  'Variable natural pauses before Maia moves': 'Maiaの着手前に自然な長さの間を入れます',
  'About Temperature and Top-P': 'TemperatureとTop-Pについて',
  'Temperature': 'Temperature',
  'Top-P': 'Top-P',
  'Maia analysis rating': '解析用Maiaレート',
  'Add second Maia engine': '2つ目のMaiaエンジンを追加',
  'Compare another Maia rating in analysis and review': '解析と棋譜レビューで別のレートと比較',
  'Second Maia analysis rating': '2つ目の解析用Maiaレート',
  'Game analysis quality': '対局解析の品質',
  'Reset engine defaults': 'エンジン設定を初期化',
  'Board sounds': '盤の効果音',
  'Beep for check, checkmate, and completed illegal moves.':
      '王手、詰み、完了した違法手でビープ音を鳴らします。',
  'Copy diagnostics': '診断情報をコピー',
  'Diagnostics copied': '診断情報をコピーしました',
  'New game': '新しい対局',
  'Reset game': '対局をリセット',
  'Share and export': '共有とエクスポート',
  'Save PGN file': 'PGNファイルを保存',
  'Share PGN': 'PGNを共有',
  'Copy PGN': 'PGNをコピー',
  'Copy FEN': 'FENをコピー',
  'Maia error. Retry': 'Maiaのエラー。再試行',
  'Maia error. Please retry.': 'Maiaのエラー。再試行してください。',
  'Retry': '再試行',
  'Maia is thinking…': 'Maiaが手を選んでいます…',
  'HISTORY': '履歴',
  'START': '開始',
  'Chessnut status': 'Chessnutの状態',
  'Leave current game?': '対局から離れますか？',
  'Your game will be kept in Recent games.': '対局は「最近の対局」に保存されます。',
  'Cancel': 'キャンセル',
  'Continue': '続ける',
  'Start a new game?': '新しい対局を始めますか？',
  'Reset game?': '対局をリセットしますか？',
  'Your completed game will remain in Recent Games.': '終了した対局は「最近の対局」に残ります。',
  'This game will be permanently erased.': 'この対局は完全に削除されます。',
  'Start new game': '新しい対局を開始',
  'Reset': 'リセット',
  'Flip board': '盤を反転',
  'Offer draw': '引き分けを提案',
  'Take back move': '一手戻す',
  'White is victorious': '白の勝ち',
  'Black is victorious': '黒の勝ち',
  'The game is a draw': '引き分け',
  'The game has ended': '対局終了',
  'Rematch': '再対局',
  'Fast': '高速',
  'Balanced': '標準',
  'Thorough': '詳細',
  'Continue from here': 'ここから対局',
  'Load': '読み込む',
  'Edit Board': '盤面を編集',
  'Done': '完了',
  'White pieces': '白の駒',
  'Black pieces': '黒の駒',
  'White to move': '白の手番',
  'Black to move': '黒の手番',
  'Castling rights': 'キャスリングの権利',
  'White kingside': '白のキングサイド',
  'White queenside': '白のクイーンサイド',
  'Black kingside': '黒のキングサイド',
  'Black queenside': '黒のクイーンサイド',
  'En-passant target': 'アンパッサン対象マス',
  'Starting position': '初期配置',
  'Clear board': '盤面をクリア',
  'Load FEN': 'FENを読み込む',
  'Load PGN': 'PGNを読み込む',
  'Open PGN file': 'PGNファイルを開く',
  'Clear moves': '指し手を消去',
  'Board Editor': '盤面エディター',
  'end position': '最後の局面',
  'Analysis menu': '解析メニュー',
  'Turn engine off': 'エンジンをオフ',
  'Turn engine on': 'エンジンをオン',
  'Moves': '指し手',
  'Computer analysis': 'コンピューター解析',
  'Back to game': '対局に戻る',
};
