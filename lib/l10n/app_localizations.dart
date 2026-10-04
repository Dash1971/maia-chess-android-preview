import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// Home / game setup: About
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Home / game setup: Analysis Board
  ///
  /// In en, this message translates to:
  /// **'Analysis Board'**
  String get analysisBoard;

  /// Home / game setup: Back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Home / game setup: Black
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// Home / game setup: Cancel premoves
  ///
  /// In en, this message translates to:
  /// **'Cancel premoves'**
  String get cancelPremoves;

  /// Home / game setup: Chessnut (experimental)
  ///
  /// In en, this message translates to:
  /// **'Chessnut (experimental)'**
  String get chessnutExperimental;

  /// Home / game setup: Connect Chessnut
  ///
  /// In en, this message translates to:
  /// **'Connect Chessnut'**
  String get connectChessnut;

  /// Home / game setup: Disconnect
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Home / game setup: Engine settings
  ///
  /// In en, this message translates to:
  /// **'Engine settings'**
  String get engineSettings;

  /// Home / game setup: Game menu
  ///
  /// In en, this message translates to:
  /// **'Game menu'**
  String get gameMenu;

  /// Home / game setup: Game ready
  ///
  /// In en, this message translates to:
  /// **'Game ready'**
  String get gameReady;

  /// Home / game setup: Game settings
  ///
  /// In en, this message translates to:
  /// **'Game settings'**
  String get gameSettings;

  /// Home / game setup: Home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Home / game setup: Play Maia
  ///
  /// In en, this message translates to:
  /// **'Play Maia'**
  String get playMaia;

  /// Home / game setup: Random
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get random;

  /// Home / game setup: Recent games
  ///
  /// In en, this message translates to:
  /// **'Recent games'**
  String get recentGames;

  /// Home / game setup: Resign
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get resign;

  /// Home / game setup: Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Home / game setup: Start game
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// Home / game setup: Time control
  ///
  /// In en, this message translates to:
  /// **'Time control'**
  String get timeControl;

  /// Home / game setup: White
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// Home / game setup: Unlimited
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// Home / game setup: Custom
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Home / game setup: seconds
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Home / game setup: Your side
  ///
  /// In en, this message translates to:
  /// **'Your side'**
  String get yourSide;

  /// Home / game setup: You
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Settings: System default
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get systemDefault;

  /// Settings: Language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings: Play Maia rating
  ///
  /// In en, this message translates to:
  /// **'Play Maia rating'**
  String get playMaiaRating;

  /// Settings: Minutes
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// Settings: Increment
  ///
  /// In en, this message translates to:
  /// **'Increment'**
  String get increment;

  /// Settings: Game sounds
  ///
  /// In en, this message translates to:
  /// **'Game sounds'**
  String get gameSounds;

  /// Settings: Moves, captures, errors, and game end
  ///
  /// In en, this message translates to:
  /// **'Moves, captures, errors, and game end'**
  String get movesCapturesErrorsAndGameEnd;

  /// Settings: Haptic feedback
  ///
  /// In en, this message translates to:
  /// **'Haptic feedback'**
  String get hapticFeedback;

  /// Settings: Touch feedback for moves, checks, errors, and game end
  ///
  /// In en, this message translates to:
  /// **'Touch feedback for moves, checks, errors, and game end'**
  String get touchFeedbackForMovesChecksErrorsAndGameEnd;

  /// Settings: Premoves
  ///
  /// In en, this message translates to:
  /// **'Premoves'**
  String get premoves;

  /// Settings: Queue a move while Maia is thinking
  ///
  /// In en, this message translates to:
  /// **'Queue a move while Maia is thinking'**
  String get queueAMoveWhileMaiaIsThinking;

  /// Settings: 100 ms premove penalty
  ///
  /// In en, this message translates to:
  /// **'100 ms premove penalty'**
  String get oneHundredMsPremovePenalty;

  /// Settings: Use 0.1 seconds per premove in timed games
  ///
  /// In en, this message translates to:
  /// **'Use 0.1 seconds per premove in timed games'**
  String get use01SecondsPerPremoveInTimedGames;

  /// Settings: Allow multiple premoves
  ///
  /// In en, this message translates to:
  /// **'Allow multiple premoves'**
  String get allowMultiplePremoves;

  /// Settings: Queue a sequence; an illegal move cancels the rest
  ///
  /// In en, this message translates to:
  /// **'Queue a sequence; an illegal move cancels the rest'**
  String get queueASequenceAnIllegalMoveCancelsTheRest;

  /// Settings: Human move timing
  ///
  /// In en, this message translates to:
  /// **'Human move timing'**
  String get humanMoveTiming;

  /// Settings: Variable natural pauses before Maia moves
  ///
  /// In en, this message translates to:
  /// **'Variable natural pauses before Maia moves'**
  String get variableNaturalPausesBeforeMaiaMoves;

  /// Settings: About Temperature and Top-P
  ///
  /// In en, this message translates to:
  /// **'About Temperature and Top-P'**
  String get aboutTemperatureAndTopP;

  /// Settings: Temperature
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// Settings: Top-P
  ///
  /// In en, this message translates to:
  /// **'Top-P'**
  String get topP;

  /// Settings: Maia analysis rating
  ///
  /// In en, this message translates to:
  /// **'Maia analysis rating'**
  String get maiaAnalysisRating;

  /// Settings: Add second Maia engine
  ///
  /// In en, this message translates to:
  /// **'Add second Maia engine'**
  String get addSecondMaiaEngine;

  /// Settings: Compare another Maia rating in analysis and review
  ///
  /// In en, this message translates to:
  /// **'Compare another Maia rating in analysis and review'**
  String get compareAnotherMaiaRatingInAnalysisAndReview;

  /// Settings: Second Maia analysis rating
  ///
  /// In en, this message translates to:
  /// **'Second Maia analysis rating'**
  String get secondMaiaAnalysisRating;

  /// Settings: Game analysis quality
  ///
  /// In en, this message translates to:
  /// **'Game analysis quality'**
  String get gameAnalysisQuality;

  /// Settings: Reset engine defaults
  ///
  /// In en, this message translates to:
  /// **'Reset engine defaults'**
  String get resetEngineDefaults;

  /// Settings: Board sounds
  ///
  /// In en, this message translates to:
  /// **'Board sounds'**
  String get boardSounds;

  /// Settings: Beep for check, checkmate, and completed illegal moves.
  ///
  /// In en, this message translates to:
  /// **'Beep for check, checkmate, and completed illegal moves.'**
  String get beepForCheckCheckmateAndCompletedIllegalMoves;

  /// Settings: Copy diagnostics
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostics'**
  String get copyDiagnostics;

  /// Settings: Diagnostics copied
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied'**
  String get diagnosticsCopied;

  /// Live game: New game
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// Live game: Reset game
  ///
  /// In en, this message translates to:
  /// **'Reset game'**
  String get resetGame;

  /// Live game: Share and export
  ///
  /// In en, this message translates to:
  /// **'Share and export'**
  String get shareAndExport;

  /// Live game: Save PGN file
  ///
  /// In en, this message translates to:
  /// **'Save PGN file'**
  String get savePgnFile;

  /// Live game: Share PGN
  ///
  /// In en, this message translates to:
  /// **'Share PGN'**
  String get sharePgn;

  /// Live game: Copy PGN
  ///
  /// In en, this message translates to:
  /// **'Copy PGN'**
  String get copyPgn;

  /// Live game: Copy FEN
  ///
  /// In en, this message translates to:
  /// **'Copy FEN'**
  String get copyFen;

  /// Live game: Maia error. Retry
  ///
  /// In en, this message translates to:
  /// **'Maia error. Retry'**
  String get maiaErrorRetry;

  /// Live game: Maia error. Please retry.
  ///
  /// In en, this message translates to:
  /// **'Maia error. Please retry.'**
  String get maiaErrorPleaseRetry;

  /// Live game: Retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Live game: Maia is thinking…
  ///
  /// In en, this message translates to:
  /// **'Maia is thinking…'**
  String get maiaIsThinking;

  /// Live game: HISTORY
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get history;

  /// Live game: START
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// Live game: Chessnut status
  ///
  /// In en, this message translates to:
  /// **'Chessnut status'**
  String get chessnutStatus;

  /// Live game: Leave current game?
  ///
  /// In en, this message translates to:
  /// **'Leave current game?'**
  String get leaveCurrentGame;

  /// Live game: Your game will be kept in Recent games.
  ///
  /// In en, this message translates to:
  /// **'Your game will be kept in Recent games.'**
  String get yourGameWillBeKeptInRecentGames;

  /// Live game: Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Live game: Continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// Live game: Start a new game?
  ///
  /// In en, this message translates to:
  /// **'Start a new game?'**
  String get startANewGame;

  /// Live game: Reset game?
  ///
  /// In en, this message translates to:
  /// **'Reset game?'**
  String get resetGameQuestion;

  /// Live game: Your completed game will remain in Recent Games.
  ///
  /// In en, this message translates to:
  /// **'Your completed game will remain in Recent Games.'**
  String get yourCompletedGameWillRemainInRecentGames;

  /// Live game: This game will be permanently erased.
  ///
  /// In en, this message translates to:
  /// **'This game will be permanently erased.'**
  String get thisGameWillBePermanentlyErased;

  /// Live game: Start new game
  ///
  /// In en, this message translates to:
  /// **'Start new game'**
  String get startNewGame;

  /// Live game: Reset
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Live game: Flip board
  ///
  /// In en, this message translates to:
  /// **'Flip board'**
  String get flipBoard;

  /// Live game: Offer draw
  ///
  /// In en, this message translates to:
  /// **'Offer draw'**
  String get offerDraw;

  /// Live game: Take back move
  ///
  /// In en, this message translates to:
  /// **'Take back move'**
  String get takeBackMove;

  /// Live game: White is victorious
  ///
  /// In en, this message translates to:
  /// **'White is victorious'**
  String get whiteIsVictorious;

  /// Live game: Black is victorious
  ///
  /// In en, this message translates to:
  /// **'Black is victorious'**
  String get blackIsVictorious;

  /// Live game: The game is a draw
  ///
  /// In en, this message translates to:
  /// **'The game is a draw'**
  String get theGameIsADraw;

  /// Live game: The game has ended
  ///
  /// In en, this message translates to:
  /// **'The game has ended'**
  String get theGameHasEnded;

  /// Live game: Rematch
  ///
  /// In en, this message translates to:
  /// **'Rematch'**
  String get rematch;

  /// Analysis quality: Fast
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// Analysis quality: Balanced
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// Analysis quality: Thorough
  ///
  /// In en, this message translates to:
  /// **'Thorough'**
  String get thorough;

  /// Analysis Board / Review: Continue from here
  ///
  /// In en, this message translates to:
  /// **'Continue from here'**
  String get continueFromHere;

  /// Analysis Board / Review: Load
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// Analysis Board / Review: Edit Board
  ///
  /// In en, this message translates to:
  /// **'Edit Board'**
  String get editBoard;

  /// Analysis Board / Review: Done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Analysis Board / Review: White pieces
  ///
  /// In en, this message translates to:
  /// **'White pieces'**
  String get whitePieces;

  /// Analysis Board / Review: Black pieces
  ///
  /// In en, this message translates to:
  /// **'Black pieces'**
  String get blackPieces;

  /// Analysis Board / Review: White to move
  ///
  /// In en, this message translates to:
  /// **'White to move'**
  String get whiteToMove;

  /// Analysis Board / Review: Black to move
  ///
  /// In en, this message translates to:
  /// **'Black to move'**
  String get blackToMove;

  /// Analysis Board / Review: Castling rights
  ///
  /// In en, this message translates to:
  /// **'Castling rights'**
  String get castlingRights;

  /// Analysis Board / Review: White kingside
  ///
  /// In en, this message translates to:
  /// **'White kingside'**
  String get whiteKingside;

  /// Analysis Board / Review: White queenside
  ///
  /// In en, this message translates to:
  /// **'White queenside'**
  String get whiteQueenside;

  /// Analysis Board / Review: Black kingside
  ///
  /// In en, this message translates to:
  /// **'Black kingside'**
  String get blackKingside;

  /// Analysis Board / Review: Black queenside
  ///
  /// In en, this message translates to:
  /// **'Black queenside'**
  String get blackQueenside;

  /// Analysis Board / Review: En-passant target
  ///
  /// In en, this message translates to:
  /// **'En-passant target'**
  String get enPassantTarget;

  /// Analysis Board / Review: Starting position
  ///
  /// In en, this message translates to:
  /// **'Starting position'**
  String get startingPosition;

  /// Analysis Board / Review: Clear board
  ///
  /// In en, this message translates to:
  /// **'Clear board'**
  String get clearBoard;

  /// Analysis Board / Review: Load FEN
  ///
  /// In en, this message translates to:
  /// **'Load FEN'**
  String get loadFen;

  /// Analysis Board / Review: Load PGN
  ///
  /// In en, this message translates to:
  /// **'Load PGN'**
  String get loadPgn;

  /// Analysis Board / Review: Open PGN file
  ///
  /// In en, this message translates to:
  /// **'Open PGN file'**
  String get openPgnFile;

  /// Analysis Board / Review: Clear moves
  ///
  /// In en, this message translates to:
  /// **'Clear moves'**
  String get clearMoves;

  /// Analysis Board / Review: Board Editor
  ///
  /// In en, this message translates to:
  /// **'Board Editor'**
  String get boardEditor;

  /// Analysis Board / Review: end position
  ///
  /// In en, this message translates to:
  /// **'end position'**
  String get endPosition;

  /// Analysis Board / Review: Analysis menu
  ///
  /// In en, this message translates to:
  /// **'Analysis menu'**
  String get analysisMenu;

  /// Analysis Board / Review: Turn engine off
  ///
  /// In en, this message translates to:
  /// **'Turn engine off'**
  String get turnEngineOff;

  /// Analysis Board / Review: Turn engine on
  ///
  /// In en, this message translates to:
  /// **'Turn engine on'**
  String get turnEngineOn;

  /// Analysis Board / Review: Moves
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get moves;

  /// Analysis Board / Review: Computer analysis
  ///
  /// In en, this message translates to:
  /// **'Computer analysis'**
  String get computerAnalysis;

  /// Analysis Board / Review: Back to game
  ///
  /// In en, this message translates to:
  /// **'Back to game'**
  String get backToGame;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
