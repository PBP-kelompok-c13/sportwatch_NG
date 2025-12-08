import 'package:flutter/material.dart';

class SearchSummaryCard extends StatelessWidget {
  const SearchSummaryCard({super.key, required this.summaryText});

  final String summaryText;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(summaryText, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
