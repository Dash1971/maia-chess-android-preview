part of '../main.dart';

/// A shared, explicit move-history navigator for live play and analysis.
///
/// Previous/next retain their long-press shortcuts, while the first/latest
/// actions remain visible so discovery does not depend on gestures.
class MoveHistoryNavigator extends StatelessWidget {
  const MoveHistoryNavigator({
    required this.firstKey,
    required this.previousKey,
    required this.nextKey,
    required this.lastKey,
    required this.statusKey,
    required this.status,
    required this.statusSemanticsLabel,
    required this.canGoBack,
    required this.canGoForward,
    required this.onFirst,
    required this.onPrevious,
    required this.onNext,
    required this.onLast,
    this.headerActions = const [],
    this.headerActionWidth = 48,
    this.firstTooltip = 'Beginning',
    this.previousTooltip = 'Previous move',
    this.nextTooltip = 'Next move',
    this.lastTooltip = 'Latest position',
    super.key,
  });

  final Key firstKey;
  final Key previousKey;
  final Key nextKey;
  final Key lastKey;
  final Key statusKey;
  final String status;
  final String statusSemanticsLabel;
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onFirst;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onLast;
  final List<Widget> headerActions;
  final double headerActionWidth;
  final String firstTooltip;
  final String previousTooltip;
  final String nextTooltip;
  final String lastTooltip;

  Widget _button(
    BuildContext context, {
    required Key key,
    required String tooltip,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: InkResponse(
          key: key,
          radius: 24,
          onTap: enabled ? onTap : null,
          onLongPress: enabled ? onLongPress : null,
          child: SizedBox.square(
            dimension: 48,
            child: Icon(
              icon,
              color: enabled ? colors.onSurfaceVariant : colors.outlineVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _status(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      liveRegion: true,
      label: statusSemanticsLabel,
      child: ExcludeSemantics(
        child: Container(
          key: statusKey,
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            status,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final controls = <Widget>[
        _button(
          context,
          key: firstKey,
          tooltip: firstTooltip,
          icon: Icons.first_page,
          enabled: canGoBack,
          onTap: onFirst,
        ),
        _button(
          context,
          key: previousKey,
          tooltip: previousTooltip,
          icon: CupertinoIcons.chevron_back,
          enabled: canGoBack,
          onTap: onPrevious,
          onLongPress: onFirst,
        ),
        _button(
          context,
          key: nextKey,
          tooltip: nextTooltip,
          icon: CupertinoIcons.chevron_forward,
          enabled: canGoForward,
          onTap: onNext,
          onLongPress: onLast,
        ),
        _button(
          context,
          key: lastKey,
          tooltip: lastTooltip,
          icon: Icons.last_page,
          enabled: canGoForward,
          onTap: onLast,
        ),
      ];
      final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final inlineActionWidth =
          192.0 + headerActionWidth * headerActions.length + 64.0;
      if (headerActions.isNotEmpty &&
          constraints.maxWidth >= inlineActionWidth) {
        return SizedBox(
          height: 52,
          child: Row(
            children: [
              ...headerActions.map(
                (action) => SizedBox(
                  width: headerActionWidth,
                  child: Center(child: action),
                ),
              ),
              controls[0],
              controls[1],
              Expanded(child: _status(context)),
              controls[2],
              controls[3],
            ],
          ),
        );
      }
      final useTwoRows = constraints.maxWidth < 320 || textScale > 1.35;
      if (useTwoRows) {
        final statusRow = headerActions.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: _status(context),
                ),
              )
            : SizedBox(
                height: 52,
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _status(context),
                      ),
                    ),
                    ...headerActions.map(
                      (action) => SizedBox(
                        width: headerActionWidth,
                        child: Center(child: action),
                      ),
                    ),
                  ],
                ),
              );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            statusRow,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: controls,
            ),
          ],
        );
      }
      final navigationRow = SizedBox(
        height: 52,
        child: Row(
          children: [
            controls[0],
            controls[1],
            Expanded(child: _status(context)),
            controls[2],
            controls[3],
          ],
        ),
      );
      if (headerActions.isEmpty) return navigationRow;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: headerActions
                  .map((action) => Expanded(child: Center(child: action)))
                  .toList(growable: false),
            ),
          ),
          navigationRow,
        ],
      );
    },
  );
}
