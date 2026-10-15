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
  final _menu = GlobalKey<PopupMenuButtonState<String>>();

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

  Future<void> _action(String action) async {
    if (_working || capture.busy) return;
    if (action == 'view') {
      SamplingReport? report;
      await _run(() async {
        report = await capture.report();
      });
      if (mounted && report != null) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => SamplingReportScreen(report: report!),
          ),
        );
      }
      return;
    }
    final share = action == 'share';
    final readable = await chooseSamplingFormat(context, share: share);
    if (!mounted || readable == null || capture.busy) return;
    final s = l10n(context);
    final text = samplingReportText(s);
    await _run(() async {
      final images = readable
          ? await samplingPieceImages()
          : <String, String>{};
      await capture.saveDocument(
        share: share,
        readable: readable,
        text: text,
        locale: s.localeName,
        pieceImages: images,
      );
    });
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
            title: Row(
              children: [
                Flexible(child: Text(strings.saveMaiaSamplingData)),
                IconButton(
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
              ],
            ),
            value: capture.enabled,
            onChanged: blocked
                ? null
                : (value) => _run(() => capture.setEnabled(value)),
          ),
          if (capture.enabled || capture.records > 0 || capture.failed) ...[
            ListTile(
              key: const ValueKey('sampling-actions'),
              enabled: !blocked && capture.records > 0,
              title: Text(strings.exportSamplingData),
              subtitle: Text(
                capture.failed
                    ? strings.samplingDataError
                    : strings.samplingDataStatus(capture.records),
              ),
              onTap: blocked || capture.records == 0
                  ? null
                  : () => _menu.currentState?.showButtonMenu(),
              trailing: PopupMenuButton<String>(
                key: _menu,
                enabled: !blocked && capture.records > 0,
                position: PopupMenuPosition.under,
                tooltip: strings.shareAndExport,
                onSelected: _action,
                icon: blocked
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.more_vert),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'view',
                    child: Text(strings.samplingView),
                  ),
                  PopupMenuItem(
                    value: 'save',
                    child: Text(strings.samplingSave),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Text(strings.samplingShare),
                  ),
                ],
              ),
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
