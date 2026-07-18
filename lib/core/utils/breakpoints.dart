import 'package:flutter/widgets.dart';

/// Material 3 window size classes (logical pixels), used to adapt layouts
/// for tablets and unfolded foldables instead of assuming a phone-width
/// screen everywhere.
enum WindowSize { compact, medium, expanded }

class Breakpoints {
  Breakpoints._();

  static const double medium = 600;
  static const double expanded = 840;

  /// Widest a single reading column should get before it looks stretched
  /// out on a tablet — content beyond this is centered instead of scaled.
  static const double maxContentWidth = 640;

  static WindowSize windowSizeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return of(width);
  }

  static WindowSize of(double width) {
    if (width >= expanded) return WindowSize.expanded;
    if (width >= medium) return WindowSize.medium;
    return WindowSize.compact;
  }

  static bool isCompact(BuildContext context) =>
      windowSizeOf(context) == WindowSize.compact;

  static bool isAtLeastMedium(BuildContext context) =>
      windowSizeOf(context) != WindowSize.compact;
}

/// Centers [child] and caps its width on medium/expanded screens so text
/// and controls don't stretch edge-to-edge on tablets and unfolded
/// foldables. No-op on compact (phone) widths.
class ContentWidthLimiter extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidthLimiter({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Only tighten maxWidth — copyWith keeps the incoming height
        // bounds intact, which a plain `BoxConstraints(maxWidth: ...)`
        // would not (it resets maxHeight to infinity and breaks any
        // Spacer/Expanded further down the tree).
        final capped = constraints.maxWidth > maxWidth
            ? constraints.copyWith(maxWidth: maxWidth, minWidth: 0)
            : constraints;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(constraints: capped, child: child),
        );
      },
    );
  }
}
