import 'package:flutter/material.dart';

class ReportDialog extends StatelessWidget {
  final String productId;
  final Function(List<String>) onReport;

  const ReportDialog({
    Key? key,
    required this.productId,
    required this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(
        'Report Product',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What would you like to report about this product?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildReportOption(
            context,
            'Incorrect Information',
            'The product information shown is incorrect',
            ['Product Information'],
          ),
          _buildReportOption(
            context,
            'Missing Information',
            'Important product information is missing',
            ['Missing Details'],
          ),
          _buildReportOption(
            context,
            'Other Issue',
            'Report another type of issue',
            ['Other'],
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(
    BuildContext context,
    String title,
    String subtitle,
    List<String> incorrectFields,
  ) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        onReport(incorrectFields);
      },
    );
  }
}
