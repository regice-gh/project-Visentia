import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SubmissionPreview extends StatelessWidget {
  const SubmissionPreview({
    required this.name,
    required this.email,
    required this.message,
  });

  final String name;
  final String email;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.section),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.section),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'submission preview',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.item),
                Text('Name: $name'),
                Text('Email: $email'),
                const SizedBox(height: AppSpacing.small),
                const Text('Message:'),
                const SizedBox(height: AppSpacing.small),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
