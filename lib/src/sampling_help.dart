part of '../main.dart';

/// Informational guidance, not a strength guarantee. No inference is run here.
List<String> samplingSettingsNotices(
  AppLocalizations strings, {
  required double temperature,
  required double topP,
  required bool openingVariety,
}) => [
  if (temperature == 1.0 && topP == 1.0) strings.samplingFullVarietyNotice,
  if (temperature == 0.0 || topP == 0.0)
    strings.samplingArgmaxNotice
  else if (temperature < defaultMaiaTemperature || topP < defaultMaiaTopP)
    strings.samplingLowerNotice,
  if (!openingVariety && (temperature < 1.0 || topP < 1.0))
    strings.samplingRecommendationWarning,
];

const samplingGuideUrl =
    'https://github.com/Dash1971/mobile-maia-research/blob/'
    'main/guides/choosing-maia-settings/README.md';

/// The explanation selector changes prose only; it never changes preferences.
class SamplingHelpDialog extends StatefulWidget {
  const SamplingHelpDialog({super.key});

  @override
  State<SamplingHelpDialog> createState() => _SamplingHelpDialogState();
}

class _SamplingHelpDialogState extends State<SamplingHelpDialog> {
  bool _technical = false;

  // Buttons can grow with wrapped labels. ChoiceChip assumes a single-line
  // label and can silently fade long translations or enlarged text.
  Widget _explanationChoice(
    BuildContext context, {
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onPressed,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: OutlinedButton.icon(
        key: key,
        onPressed: onPressed,
        icon: selected ? const Icon(Icons.check, size: 18) : null,
        label: Text(label, softWrap: true),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? colors.secondaryContainer : null,
          foregroundColor: selected
              ? colors.onSecondaryContainer
              : colors.onSurfaceVariant,
          side: selected ? BorderSide.none : BorderSide(color: colors.outline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = l10n(context);
    final paragraphs = _technical
        ? [
            strings.samplingTechnicalTemperature,
            strings.samplingTechnicalTopP,
            strings.samplingTechnicalOpening,
            strings.samplingTechnicalEvidence,
          ]
        : [
            strings.samplingHelpIntro,
            strings.samplingHelpVariety,
            strings.samplingHelpDefaults,
            strings.samplingHelpStrength,
            strings.samplingHelpArgmax,
            strings.samplingHelpTopP,
          ];
    return AlertDialog(
      scrollable: true,
      title: Text(strings.samplingTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _explanationChoice(
                  context,
                  key: const ValueKey('sampling-help-simple'),
                  label: strings.samplingSimpleExplanation,
                  selected: !_technical,
                  onPressed: () => setState(() => _technical = false),
                ),
                _explanationChoice(
                  context,
                  key: const ValueKey('sampling-help-technical'),
                  label: strings.samplingTechnicalExplanation,
                  selected: _technical,
                  onPressed: () => setState(() => _technical = true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final paragraph in paragraphs) ...[
              Text(paragraph),
              const SizedBox(height: 14),
            ],
            Text(strings.samplingHelpResearchIntro),
            TextButton.icon(
              key: const ValueKey('sampling-research-link'),
              onPressed: () => maiaEngineChannel.invokeMethod<void>('openUrl', {
                'url': samplingGuideUrl,
              }),
              icon: const Icon(Icons.open_in_new),
              label: Text(strings.samplingResearchLink),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.close),
        ),
      ],
    );
  }
}
