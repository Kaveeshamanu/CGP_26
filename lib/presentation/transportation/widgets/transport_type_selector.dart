import 'package:flutter/material.dart';

import '../../../config/theme.dart';
import '../../../data/models/transport.dart';

class TransportTypeSelector extends StatelessWidget {
  final TransportType selectedType;
  final Function(TransportType) onTypeSelected;

  const TransportTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildTransportTypeOption(
              context,
              type: TransportType.bus,
              icon: Icons.directions_bus,
              label: 'Bus',
              color: Colors.green,
            ),
            _buildTransportTypeOption(
              context,
              type: TransportType.train,
              icon: Icons.train,
              label: 'Train',
              color: Colors.purple,
            ),
            _buildTransportTypeOption(
              context,
              type: TransportType.taxi,
              icon: Icons.local_taxi,
              label: 'Taxi',
              color: Colors.amber,
            ),
            _buildTransportTypeOption(
              context,
              type: TransportType.tuktuk,
              icon: Icons.moped,
              label: 'Tuk-Tuk',
              color: Colors.orange,
            ),
            _buildTransportTypeOption(
              context,
              type: TransportType.car,
              icon: Icons.directions_car,
              label: 'Car Rental',
              color: Colors.blue,
            ),
            _buildTransportTypeOption(
              context,
              type: TransportType.all,
              icon: Icons.commute,
              label: 'All',
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportTypeOption(
    BuildContext context, {
    required TransportType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedType == type;
    
    return GestureDetector(
      onTap: () => onTypeSelected(type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[500],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}