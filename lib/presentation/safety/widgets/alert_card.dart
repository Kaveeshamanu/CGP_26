import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../safety_screen.dart';

class AlertCard extends StatelessWidget {
  final SafetyAlert alert;
  final VoidCallback onTap;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getSeverityColor().withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getSeverityColor().withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getSeverityIcon(),
                      color: _getSeverityColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getSeverityColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getSeverityText(),
                                style: TextStyle(
                                  color: _getSeverityColor(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeago.format(alert.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Text(
                  alert.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return Colors.blue;
      case AlertSeverity.moderate:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      }
  }

  IconData _getSeverityIcon() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return Icons.info_outline;
      case AlertSeverity.moderate:
        return Icons.warning_amber_outlined;
      case AlertSeverity.high:
        return Icons.error_outline;
      }
  }

  String _getSeverityText() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return 'Advisory';
      case AlertSeverity.moderate:
        return 'Caution';
      case AlertSeverity.high:
        return 'Warning';
      }
  }
}