import 'package:flutter/material.dart';
import 'responsive_constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final ScreenBreakpoint breakpoint;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.breakpoint,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getPadding(breakpoint);
    final spacing = ResponsiveUtils.getSpacing(breakpoint);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: Colors.grey.shade300),
            SizedBox(height: spacing * 2),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getTitleSize(breakpoint),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: spacing),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ResponsiveUtils.getBodySize(breakpoint),
                color: Colors.grey.shade500,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: spacing * 2),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
