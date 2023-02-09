import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    required this.onChanged,
    super.key,
    this.value = false,
    this.enabled = true,
  });

  final bool value;
  final bool enabled;
  final ValueSetter<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? () => onChanged(!value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        curve: Curves.fastLinearToSlowEaseIn,
        decoration: BoxDecoration(
          color: value ? const Color(0xFF4A78FA) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: value
              ? null
              : Border.all(color: Colors.grey.withOpacity(.6), width: 2),
        ),
        width: 25,
        height: 25,
        child: value ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
