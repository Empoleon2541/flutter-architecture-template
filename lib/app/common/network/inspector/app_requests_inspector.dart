import 'package:flutter/widgets.dart';
import 'package:requests_inspector/requests_inspector.dart';
import '../../utils/app_constants.dart';

/// Conditionally wraps [child] with [RequestsInspector].
///
/// When [AppConstants.enableRequestsInspector] is false (production) the child
/// is returned as-is with zero overhead. When enabled, long-pressing anywhere
/// on screen (or shaking on mobile) opens the inspector UI.
class AppRequestsInspector extends StatelessWidget {
  const AppRequestsInspector({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.enableRequestsInspector) return child;

    return RequestsInspector(
      hideInspectorBanner: true,
      showInspectorOn: ShowInspectorOn.Both, // shake + long-press
      child: child,
    );
  }
}
