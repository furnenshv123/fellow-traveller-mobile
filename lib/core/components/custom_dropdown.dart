import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatefulWidget {
  const CustomDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    required this.hint,
    this.itemLabelBuilder,
    this.backgroundColor = const Color(0xFFF5F5F5),
    this.borderColor = const Color(0xFFE0E0E0),
    this.borderRadius = 12,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    this.fontSize = 14,
    this.prefixIcon,
    this.enabled = true,
  });

  final List<T> items;
  final T? value;
  final String hint;
  final ValueChanged<T?> onChanged;
  final String Function(T)? itemLabelBuilder;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final double fontSize;
  final IconData? prefixIcon;
  final bool enabled;

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: widget.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: widget.value,
          hint: Row(
            children: <Widget>[
              if (widget.prefixIcon != null) ...<Widget>[
                Icon(
                  widget.prefixIcon,
                  color: const Color(0xFF1783FF),
                  size: 18,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.hint,
                style: TextStyle(
                  color: const Color(0xFFBDBDBD),
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          isExpanded: true,
          isDense: true,
          onChanged: widget.enabled ? widget.onChanged : null,
          items: widget.items.map((T item) {
            final String label = widget.itemLabelBuilder != null
                ? widget.itemLabelBuilder!(item)
                : item.toString();

            return DropdownMenuItem<T>(
              value: item,
              child: Padding(
                padding: widget.contentPadding,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1A1D24),
                  ),
                ),
              ),
            );
          }).toList(),
          padding: EdgeInsets.zero,
          underline: const SizedBox.shrink(),
          icon: const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(
              Icons.unfold_more_rounded,
              color: Color(0xFFBDBDBD),
              size: 20,
            ),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          menuMaxHeight: 300,
        ),
      ),
    );
  }
}
