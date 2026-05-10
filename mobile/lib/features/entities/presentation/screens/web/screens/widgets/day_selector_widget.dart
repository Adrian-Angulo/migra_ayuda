import 'package:flutter/material.dart';

class DaySelectorWidget extends StatelessWidget {
  final List<String> selectedDays;
  final ValueChanged<List<String>> onDaysChanged;

  const DaySelectorWidget({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  static const List<String> days = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = selectedDays.contains(day);
        return InkWell(
          onTap: () {
            final newSelectedDays = List<String>.from(selectedDays);
            if (isSelected) {
              newSelectedDays.remove(day);
            } else {
              newSelectedDays.add(day);
            }
            onDaysChanged(newSelectedDays);
          },
          borderRadius: BorderRadius.circular(50),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2196F3)
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
