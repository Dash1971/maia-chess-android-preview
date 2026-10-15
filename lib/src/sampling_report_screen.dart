part of '../main.dart';

class SamplingReportScreen extends StatefulWidget {
  const SamplingReportScreen({super.key, required this.report});
  final SamplingReport report;
  @override
  State<SamplingReportScreen> createState() => _SamplingReportScreenState();
}

class _SamplingReportScreenState extends State<SamplingReportScreen> {
  late final games = widget.report.games.values.toList(growable: false);
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final s = l10n(context);
    final text = samplingReportText(s);
    final decisions = games.isEmpty
        ? <SamplingReportDecision>[]
        : games[selected];
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(s.samplingSummary),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: decisions.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.samplingReportExplanation),
                const SizedBox(height: 12),
                Text(
                  s.samplingReportPartial,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (widget.report.incomplete) ...[
                  const SizedBox(height: 8),
                  Text(s.samplingReportMissing),
                ],
                const SizedBox(height: 20),
                if (games.isNotEmpty)
                  DropdownButtonFormField<int>(
                    key: const ValueKey('sampling-report-game'),
                    initialValue: selected,
                    isExpanded: true,
                    items: [
                      for (var i = 0; i < games.length; i++)
                        DropdownMenuItem(
                          value: i,
                          child: Text(s.samplingGame('${i + 1}')),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => selected = value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(s.samplingRecords('${decisions.length}')),
                const SizedBox(height: 12),
              ],
            );
          }
          final d = decisions[index - 1];
          final move = d.played;
          return Card(
            key: ValueKey(d.requestId),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${d.moveNumber} ${move == null ? s.samplingNotPlayed : move.san}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (move != null)
                        Text(
                          samplingPercent(move.probability, s.localeName),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    samplingSettings(d, text, s.localeName),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (d.alternatives.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(s.samplingAlternatives),
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        for (final m in d.alternatives)
                          Text(
                            '${m.san}  ${samplingPercent(m.probability, s.localeName)}',
                          ),
                      ],
                    ),
                  ],
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(s.samplingPositionBefore),
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) => cg.StaticChessboard(
                          size: min(256, constraints.maxWidth),
                          orientation: dc.Side.white,
                          fen: d.fen,
                          settings: const cg.StaticChessboardSettings(
                            colorScheme: cg.ChessboardColorScheme.brown,
                            enableCoordinates: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        MaterialLocalizations.of(context)
                            .formatFullDate(d.startedAt.toLocal()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Save/Share format choice. Readable is always the initial choice.
Future<bool?> chooseSamplingFormat(
  BuildContext context, {
  required bool share,
}) {
  final s = l10n(context);
  var readable = true;
  return showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(share ? s.samplingShare : s.samplingSave),
        content: SingleChildScrollView(
          child: RadioGroup<bool>(
            groupValue: readable,
            onChanged: (value) => setState(() => readable = value!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: true,
                  title: Text(s.samplingReadable),
                  subtitle: Text(s.samplingReadableHint),
                ),
                RadioListTile<bool>(
                  contentPadding: EdgeInsets.zero,
                  value: false,
                  title: Text(s.samplingResearch),
                  subtitle: Text(s.samplingResearchHint),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, readable),
            child: Text(share ? s.samplingShare : s.samplingSave),
          ),
        ],
      ),
    ),
  );
}
