part of '../main.dart';

class _ContinuationSettings {
  const _ContinuationSettings({
    required this.side,
    required this.elo,
    required this.timePreset,
    required this.customMinutes,
    required this.customIncrement,
  });

  final PlayerSide side;
  final int elo;
  final TimePreset timePreset;
  final int customMinutes;
  final int customIncrement;
}

class _ContinueFromHereDialog extends StatefulWidget {
  const _ContinueFromHereDialog({required this.defaults});

  final _ContinuationSettings defaults;

  @override
  State<_ContinueFromHereDialog> createState() =>
      _ContinueFromHereDialogState();
}

class _ContinueFromHereDialogState extends State<_ContinueFromHereDialog> {
  late PlayerSide _side = widget.defaults.side;
  late int _elo = widget.defaults.elo;
  late TimePreset _timePreset = widget.defaults.timePreset;
  late int _customMinutes = widget.defaults.customMinutes;
  late int _customIncrement = widget.defaults.customIncrement;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(l10n(context).continueFromHere),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<PlayerSide>(
              key: const ValueKey('continuation-side'),
              initialValue: _side,
              decoration: InputDecoration(labelText: l10n(context).yourSide),
              items: [
                DropdownMenuItem(
                  value: PlayerSide.white,
                  child: Text(l10n(context).white),
                ),
                DropdownMenuItem(
                  value: PlayerSide.black,
                  child: Text(l10n(context).black),
                ),
                DropdownMenuItem(
                  value: PlayerSide.random,
                  child: Text(l10n(context).random),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _side = value);
              },
            ),
            const SizedBox(height: 12),
            Text(l10n(context).playRatingValue(displayNumber(context, _elo))),
            Slider(
              key: const ValueKey('continuation-rating'),
              min: maiaMinimumRating.toDouble(),
              max: maiaMaximumRating.toDouble(),
              divisions: maiaRatingDivisions,
              value: _elo.toDouble(),
              label: displayNumber(context, _elo),
              onChanged: (value) => setState(() => _elo = value.round()),
            ),
            DropdownButtonFormField<TimePreset>(
              key: const ValueKey('continuation-time-control'),
              initialValue: _timePreset,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n(context).timeControl),
              items: TimePreset.values
                  .map(
                    (preset) => DropdownMenuItem(
                      value: preset,
                      child: Text(localizedTimePreset(context, preset)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _timePreset = value);
              },
            ),
            if (_timePreset == TimePreset.custom) ...[
              const SizedBox(height: 12),
              Text(
                l10n(context)
                    .minutesValue(displayNumber(context, _customMinutes)),
              ),
              Slider(
                key: const ValueKey('continuation-custom-minutes'),
                min: 1,
                max: 60,
                divisions: 59,
                value: _customMinutes.toDouble(),
                label: displayNumber(context, _customMinutes),
                onChanged: (value) =>
                    setState(() => _customMinutes = value.round()),
              ),
              Text(
                l10n(context).incrementSecondsValue(
                  displayNumber(context, _customIncrement),
                ),
              ),
              Slider(
                key: const ValueKey('continuation-custom-increment'),
                min: 0,
                max: 30,
                divisions: 30,
                value: _customIncrement.toDouble(),
                label: displayNumber(context, _customIncrement),
                onChanged: (value) =>
                    setState(() => _customIncrement = value.round()),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n(context).cancel),
      ),
      FilledButton(
        key: const ValueKey('continuation-start-game'),
        onPressed: () => Navigator.pop(
          context,
          _ContinuationSettings(
            side: _side,
            elo: _elo,
            timePreset: _timePreset,
            customMinutes: _customMinutes,
            customIncrement: _customIncrement,
          ),
        ),
        child: Text(l10n(context).startGame),
      ),
    ],
  );
}

class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      minLines: 3,
      maxLines: 10,
      decoration: InputDecoration(
        hintText: widget.hint,
        border: const OutlineInputBorder(),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(l10n(context).cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: Text(l10n(context).load),
      ),
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class AnalysisBoardPage extends StatefulWidget {
  const AnalysisBoardPage({
    required this.initialSession,
    required this.maiaElo,
    this.secondMaiaElo,
    this.useMoveHistory = false,
    this.historyPrefix = const [],
    this.initialVariations = const [],
    this.initialTreeIsAuthoritative = false,
    this.initialCurrentFen,
    this.initialFlipped = false,
    this.gameAnalysisQuality = GameAnalysisQuality.fast,
    this.evaluator,
    this.maiaEvaluator,
    this.maiaPolicyEvaluator,
    super.key,
  });

  final AnalysisSession initialSession;
  final int maiaElo;
  final int? secondMaiaElo;
  final bool useMoveHistory;
  final List<String> historyPrefix;
  final List<RecordedVariation> initialVariations;
  final bool initialTreeIsAuthoritative;
  final String? initialCurrentFen;
  final bool initialFlipped;
  final GameAnalysisQuality gameAnalysisQuality;
  final Future<StockfishReview> Function(String fen)? evaluator;
  final Future<String?> Function(List<String> positions, int elo)?
  maiaEvaluator;
  final Future<List<double>?> Function(List<String> positions, int elo)?
  maiaPolicyEvaluator;

  @override
  State<AnalysisBoardPage> createState() => _AnalysisBoardPageState();
}

class _AnalysisBoardPageState extends State<AnalysisBoardPage> {
  late AnalysisSession _session = widget.initialSession;
  late List<RecordedVariation> _initialVariations = widget.initialVariations;
  late String? _initialCurrentFen = widget.initialCurrentFen;
  late bool _initialFlipped = widget.initialFlipped;
  int _revision = 0;

  @override
  void initState() {
    super.initState();
    if (!widget.initialTreeIsAuthoritative && _initialVariations.isEmpty) {
      _initialVariations = PgnVariationExporter.parseTree(_session.pgn);
    }
    unawaited(
      _saveAnalysisState(
        _initialCurrentFen ?? widget.initialSession.positions.first,
        _initialFlipped,
        _initialVariations,
      ),
    );
  }

  Future<void> _saveAnalysisState(
    String currentFen,
    bool flipped,
    List<RecordedVariation> variations,
  ) => ActiveSessionStore.save({
    'type': 'analysis',
    'treeIsAuthoritative': true,
    'session': _session.toJson(),
    'variations': variations.map((item) => item.toJson()).toList(),
    'currentFen': currentFen,
    'flipped': flipped,
    'maiaElo': widget.maiaElo,
    'maiaUseMoveHistory': widget.useMoveHistory,
    'historyPrefix': _revision == 0 ? widget.historyPrefix : const <String>[],
    if (widget.secondMaiaElo != null) 'secondMaiaElo': widget.secondMaiaElo,
  });

  void _replace(AnalysisSession session) {
    setState(() {
      _session = session;
      _initialVariations = PgnVariationExporter.parseTree(session.pgn);
      _initialCurrentFen = session.positions.first;
      _initialFlipped = false;
      _revision++;
    });
    unawaited(
      _saveAnalysisState(session.positions.first, false, _initialVariations),
    );
  }

  Future<String?> _textDialog(String title, String hint) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _TextInputDialog(title: title, hint: hint),
    );
  }

  void _showError(Object error, {bool fen = false}) {
    unawaited(
      AppDiagnostics.record(
        fen ? 'load-fen' : 'load-pgn',
        error,
        StackTrace.current,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fen ? l10n(context).invalidPosition : l10n(context).pgnLoadFailed,
        ),
      ),
    );
  }

  Future<void> _loadFen() async {
    final value = await _textDialog(
      l10n(context).loadFen,
      l10n(context).pasteFen,
    );
    if (value == null || value.trim().isEmpty) return;
    try {
      _replace(AnalysisSession.fromFen(value));
    } catch (error) {
      _showError(error, fen: true);
    }
  }

  Future<void> _loadPgnFile() async {
    try {
      final session = await PgnFiles.open();
      if (session != null && mounted) {
        await ActiveSessionStore.startNew();
        if (mounted) _replace(session);
      }
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _loadPgn() async {
    final value = await _textDialog(
      l10n(context).loadPgn,
      l10n(context).pastePgn,
    );
    if (value == null || value.trim().isEmpty) return;
    try {
      final session = await AnalysisSession.fromPgnAsync(value);
      if (!mounted) return;
      await ActiveSessionStore.startNew();
      if (mounted) _replace(session);
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _editBoard(String fen) async {
    final edited = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => BoardEditorPage(
          initialFen: fen,
          onContinue: (edited) => _playFrom(edited, [edited]),
        ),
      ),
    );
    if (edited != null) _replace(AnalysisSession.fromFen(edited));
  }

  Future<void> _playFrom(String fen, List<String> positions) async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    final defaults = _ContinuationSettings(
      side: _readValidatedPreference<PlayerSide>(
        preferences,
        maiaPlaySidePreferenceKey,
        fallback: PlayerSide.white,
        decode: (value) => value is String
            ? PlayerSide.values.where((side) => side.name == value).firstOrNull
            : null,
      ),
      elo: _readMaiaRatingPreference(
        preferences,
        maiaPlayEloPreferenceKey,
        fallback: 1500,
      ),
      timePreset: _readValidatedPreference<TimePreset>(
        preferences,
        maiaTimePresetPreferenceKey,
        fallback: TimePreset.unlimited,
        decode: (value) => value is String
            ? TimePreset.values
                  .where((preset) => preset.name == value)
                  .firstOrNull
            : null,
      ),
      customMinutes: _readValidatedPreference<int>(
        preferences,
        maiaCustomMinutesPreferenceKey,
        fallback: 10,
        decode: (value) =>
            value is int && value >= 1 && value <= 60 ? value : null,
      ),
      customIncrement: _readValidatedPreference<int>(
        preferences,
        maiaCustomIncrementPreferenceKey,
        fallback: 0,
        decode: (value) =>
            value is int && value >= 0 && value <= 30 ? value : null,
      ),
    );
    final selection = await showDialog<_ContinuationSettings>(
      context: context,
      builder: (context) => _ContinueFromHereDialog(defaults: defaults),
    );
    if (selection == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GamePage(
          startingFen: fen,
          startingUseMoveHistory: widget.useMoveHistory,
          startingPositionHistory: positions,
          startingSide: selection.side,
          startingElo: selection.elo,
          startingTimePreset: selection.timePreset,
          startingCustomMinutes: selection.customMinutes,
          startingCustomIncrement: selection.customIncrement,
        ),
      ),
    );
  }

  Future<void> _clearMoves() async {
    _replace(AnalysisSession.fromFen(_session.positions.first));
  }

  @override
  Widget build(BuildContext context) => ReviewPage(
    key: ValueKey(_revision),
    positions: _session.positions,
    uciMoves: _session.uciMoves,
    sanMoves: _session.sanMoves,
    playerIsWhite: true,
    pgn: _session.pgn,
    initialVariations: _initialVariations,
    initialTreeIsAuthoritative:
        _revision == 0 && widget.initialTreeIsAuthoritative,
    initialCurrentFen: _initialCurrentFen,
    initialFlipped: _initialFlipped,
    gameAnalysisQuality: widget.gameAnalysisQuality,
    onSessionChanged: _saveAnalysisState,
    maiaElo: widget.maiaElo,
    secondMaiaElo: widget.secondMaiaElo,
    useMoveHistory: widget.useMoveHistory,
    historyPrefix: _revision == 0 ? widget.historyPrefix : const [],
    evaluator: widget.evaluator,
    maiaEvaluator: widget.maiaEvaluator,
    maiaPolicyEvaluator: widget.maiaPolicyEvaluator,
    title: l10n(context).analysisBoard,
    onHome: ActiveSessionStore.clear,
    onLoadFen: _loadFen,
    onLoadPgn: _loadPgn,
    onLoadPgnFile: _loadPgnFile,
    onClearMoves: _clearMoves,
    onEditBoard: _editBoard,
    onPlayFromHistory: _playFrom,
  );
}

typedef MoveClassificationRunner = Future<List<ClassifiedMove>> Function({
  required List<StockfishReview> scores,
  required List<String> positions,
  required List<String> uciMoves,
});
