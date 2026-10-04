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

// Dev localization bridge. Call sites are being migrated to stable ARB IDs.
String appText(BuildContext context, String english) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return english;
  return switch (english) {
    "About" => l10n.about,
    "Analysis Board" => l10n.analysisBoard,
    "Back" => l10n.back,
    "Black" => l10n.black,
    "Cancel premoves" => l10n.cancelPremoves,
    "Chessnut (experimental)" => l10n.chessnutExperimental,
    "Connect Chessnut" => l10n.connectChessnut,
    "Disconnect" => l10n.disconnect,
    "Engine settings" => l10n.engineSettings,
    "Game menu" => l10n.gameMenu,
    "Game ready" => l10n.gameReady,
    "Game settings" => l10n.gameSettings,
    "Home" => l10n.home,
    "Play Maia" => l10n.playMaia,
    "Random" => l10n.random,
    "Recent games" => l10n.recentGames,
    "Resign" => l10n.resign,
    "Settings" => l10n.settings,
    "Start game" => l10n.startGame,
    "Time control" => l10n.timeControl,
    "White" => l10n.white,
    "Unlimited" => l10n.unlimited,
    "Custom" => l10n.custom,
    "seconds" => l10n.seconds,
    "Your side" => l10n.yourSide,
    "You" => l10n.you,
    "System default" => l10n.systemDefault,
    "Language" => l10n.language,
    "Play Maia rating" => l10n.playMaiaRating,
    "Minutes" => l10n.minutes,
    "Increment" => l10n.increment,
    "Game sounds" => l10n.gameSounds,
    "Moves, captures, errors, and game end" =>
      l10n.movesCapturesErrorsAndGameEnd,
    "Haptic feedback" => l10n.hapticFeedback,
    "Touch feedback for moves, checks, errors, and game end" =>
      l10n.touchFeedbackForMovesChecksErrorsAndGameEnd,
    "Premoves" => l10n.premoves,
    "Queue a move while Maia is thinking" => l10n.queueAMoveWhileMaiaIsThinking,
    "100 ms premove penalty" => l10n.oneHundredMsPremovePenalty,
    "Use 0.1 seconds per premove in timed games" =>
      l10n.use01SecondsPerPremoveInTimedGames,
    "Allow multiple premoves" => l10n.allowMultiplePremoves,
    "Queue a sequence; an illegal move cancels the rest" =>
      l10n.queueASequenceAnIllegalMoveCancelsTheRest,
    "Human move timing" => l10n.humanMoveTiming,
    "Variable natural pauses before Maia moves" =>
      l10n.variableNaturalPausesBeforeMaiaMoves,
    "About Temperature and Top-P" => l10n.aboutTemperatureAndTopP,
    "Temperature" => l10n.temperature,
    "Top-P" => l10n.topP,
    "Maia analysis rating" => l10n.maiaAnalysisRating,
    "Add second Maia engine" => l10n.addSecondMaiaEngine,
    "Compare another Maia rating in analysis and review" =>
      l10n.compareAnotherMaiaRatingInAnalysisAndReview,
    "Second Maia analysis rating" => l10n.secondMaiaAnalysisRating,
    "Game analysis quality" => l10n.gameAnalysisQuality,
    "Reset engine defaults" => l10n.resetEngineDefaults,
    "Board sounds" => l10n.boardSounds,
    "Beep for check, checkmate, and completed illegal moves." =>
      l10n.beepForCheckCheckmateAndCompletedIllegalMoves,
    "Copy diagnostics" => l10n.copyDiagnostics,
    "Diagnostics copied" => l10n.diagnosticsCopied,
    "New game" => l10n.newGame,
    "Reset game" => l10n.resetGame,
    "Share and export" => l10n.shareAndExport,
    "Save PGN file" => l10n.savePgnFile,
    "Share PGN" => l10n.sharePgn,
    "Copy PGN" => l10n.copyPgn,
    "Copy FEN" => l10n.copyFen,
    "Maia error. Retry" => l10n.maiaErrorRetry,
    "Maia error. Please retry." => l10n.maiaErrorPleaseRetry,
    "Retry" => l10n.retry,
    "Maia is thinking…" => l10n.maiaIsThinking,
    "HISTORY" => l10n.history,
    "START" => l10n.start,
    "Chessnut status" => l10n.chessnutStatus,
    "Leave current game?" => l10n.leaveCurrentGame,
    "Your game will be kept in Recent games." =>
      l10n.yourGameWillBeKeptInRecentGames,
    "Cancel" => l10n.cancel,
    "Continue" => l10n.continueAction,
    "Start a new game?" => l10n.startANewGame,
    "Reset game?" => l10n.resetGameQuestion,
    "Your completed game will remain in Recent Games." =>
      l10n.yourCompletedGameWillRemainInRecentGames,
    "This game will be permanently erased." =>
      l10n.thisGameWillBePermanentlyErased,
    "Start new game" => l10n.startNewGame,
    "Reset" => l10n.reset,
    "Flip board" => l10n.flipBoard,
    "Offer draw" => l10n.offerDraw,
    "Take back move" => l10n.takeBackMove,
    "White is victorious" => l10n.whiteIsVictorious,
    "Black is victorious" => l10n.blackIsVictorious,
    "The game is a draw" => l10n.theGameIsADraw,
    "The game has ended" => l10n.theGameHasEnded,
    "Rematch" => l10n.rematch,
    "Fast" => l10n.fast,
    "Balanced" => l10n.balanced,
    "Thorough" => l10n.thorough,
    "Continue from here" => l10n.continueFromHere,
    "Load" => l10n.load,
    "Edit Board" => l10n.editBoard,
    "Done" => l10n.done,
    "White pieces" => l10n.whitePieces,
    "Black pieces" => l10n.blackPieces,
    "White to move" => l10n.whiteToMove,
    "Black to move" => l10n.blackToMove,
    "Castling rights" => l10n.castlingRights,
    "White kingside" => l10n.whiteKingside,
    "White queenside" => l10n.whiteQueenside,
    "Black kingside" => l10n.blackKingside,
    "Black queenside" => l10n.blackQueenside,
    "En-passant target" => l10n.enPassantTarget,
    "Starting position" => l10n.startingPosition,
    "Clear board" => l10n.clearBoard,
    "Load FEN" => l10n.loadFen,
    "Load PGN" => l10n.loadPgn,
    "Open PGN file" => l10n.openPgnFile,
    "Clear moves" => l10n.clearMoves,
    "Board Editor" => l10n.boardEditor,
    "end position" => l10n.endPosition,
    "Analysis menu" => l10n.analysisMenu,
    "Turn engine off" => l10n.turnEngineOff,
    "Turn engine on" => l10n.turnEngineOn,
    "Moves" => l10n.moves,
    "Computer analysis" => l10n.computerAnalysis,
    "Back to game" => l10n.backToGame,
    _ => english,
  };
}
