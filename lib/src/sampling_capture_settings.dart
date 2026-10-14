part of '../main.dart';

class SamplingCaptureSettings extends StatefulWidget {
  const SamplingCaptureSettings({super.key});
  @override
  State<SamplingCaptureSettings> createState() =>
      _SamplingCaptureSettingsState();
}

class _SamplingCaptureSettingsState extends State<SamplingCaptureSettings> {
  final capture = SamplingCapture.instance;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    unawaited(capture.loadStoredData());
  }

  Future<void> _run(Future<void> Function() operation) async {
    if (_working) return;
    setState(() => _working = true);
    try {
      await operation();
      if (capture.failed) throw StateError('Capture storage failed');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n(context).samplingDataError)),
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _export() async {
    final file = await capture.export();
    try {
      await maiaEngineChannel.invokeMethod<bool>('saveSamplingData');
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: capture,
    builder: (context, _) {
      final strings = l10n(context);
      final blocked = _working || capture.busy;
      return Column(
        children: [
          SwitchListTile(
            key: const ValueKey('sampling-data-toggle'),
            title: Text(strings.saveMaiaSamplingData),
            value: capture.enabled,
            onChanged: blocked
                ? null
                : (value) => _run(() => capture.setEnabled(value)),
            secondary: IconButton(
              tooltip: strings.saveMaiaSamplingData,
              icon: const Icon(Icons.info_outline),
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(strings.saveMaiaSamplingData),
                  content: SingleChildScrollView(
                    child: Text(strings.samplingDataHelp),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(strings.close),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (capture.enabled || capture.records > 0 || capture.failed) ...[
            ListTile(
              title: Text(strings.exportSamplingData),
              subtitle: Text(
                capture.failed
                    ? strings.samplingDataError
                    : strings.samplingDataStatus(
                        capture.records,
                        capture.prunedGames,
                      ),
              ),
              trailing: const Icon(Icons.save_alt),
              onTap: blocked || capture.records == 0
                  ? null
                  : () => _run(_export),
            ),
            ListTile(
              title: Text(strings.clearSamplingData),
              trailing: const Icon(Icons.delete_outline),
              onTap: blocked || (capture.records == 0 && !capture.failed)
                  ? null
                  : () => _run(capture.clear),
            ),
          ],
        ],
      );
    },
  );
}
