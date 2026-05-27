import 'dart:async';

import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

/// City autocomplete: text field + server suggestions, no BLoC.
class PointSearchField extends StatefulWidget {
  const PointSearchField({
    required this.label,
    required this.onChanged,
    this.value,
    this.hint = 'Введите город',
    this.icon = Icons.location_on_outlined,
    super.key,
  });

  final String label;
  final String hint;
  final IconData icon;
  final PointModel? value;
  final ValueChanged<PointModel?> onChanged;

  @override
  State<PointSearchField> createState() => _PointSearchFieldState();
}

class _PointSearchFieldState extends State<PointSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  Timer? _debounce;
  int _requestId = 0;

  bool _loading = false;
  bool _showPanel = false;
  List<PointModel> _suggestions = <PointModel>[];
  String? _error;

  static const _debounceMs = 320;
  static const _minChars = 1;

  @override
  void initState() {
    super.initState();
    _applyValue(widget.value);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(PointSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value?.id != widget.value?.id) {
      _applyValue(widget.value);
    }
  }

  void _applyValue(PointModel? point) {
    final text = point?.name ?? '';
    if (_controller.text != text) {
      _controller.text = text;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() => _showPanel = true);
      if (_controller.text.trim().length >= _minChars) {
        _fetch(_controller.text.trim());
      }
    } else {
      Future<void>.delayed(const Duration(milliseconds: 150), () {
        if (mounted && !_focusNode.hasFocus) {
          setState(() => _showPanel = false);
        }
      });
    }
  }

  void _onTextChanged(String text) {
    widget.onChanged(null);

    _debounce?.cancel();
    final query = text.trim();

    if (query.length < _minChars) {
      setState(() {
        _loading = false;
        _suggestions = <PointModel>[];
        _error = null;
        _showPanel = _focusNode.hasFocus;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _showPanel = true;
    });

    _debounce = Timer(const Duration(milliseconds: _debounceMs), () => _fetch(query));
  }

  Future<void> _fetch(String query) async {
    final id = ++_requestId;

    try {
      final results =
          await AppDependencies.instance.ridesRepository.searchPoints(query);

      if (!mounted || id != _requestId) {
        return;
      }

      setState(() {
        _loading = false;
        _suggestions = results;
        _error = null;
      });
    } catch (_) {
      if (!mounted || id != _requestId) {
        return;
      }
      setState(() {
        _loading = false;
        _suggestions = <PointModel>[];
        _error = 'Не удалось загрузить подсказки';
      });
    }
  }

  void _select(PointModel point) {
    _controller.text = point.name;
    widget.onChanged(point);
    setState(() {
      _showPanel = false;
      _suggestions = <PointModel>[];
      _loading = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onTextChanged,
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.75),
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Icon(widget.icon, color: AppColors.accentBlue, size: 22),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.inputDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputFocused, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
        if (_showPanel) _SuggestionsPanel(
          loading: _loading,
          suggestions: _suggestions,
          error: _error,
          query: _controller.text.trim(),
          onSelect: _select,
        ),
      ],
    );
  }
}

class _SuggestionsPanel extends StatelessWidget {
  const _SuggestionsPanel({
    required this.loading,
    required this.suggestions,
    required this.error,
    required this.query,
    required this.onSelect,
  });

  final bool loading;
  final List<PointModel> suggestions;
  final String? error;
  final String query;
  final ValueChanged<PointModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (loading) const _LoadingRows() else _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (error != null) {
      return _MessageRow(icon: Icons.cloud_off_outlined, text: error!);
    }

    if (query.length < 1) {
      return const _MessageRow(
        icon: Icons.edit_location_alt_outlined,
        text: 'Начните вводить название города',
      );
    }

    if (suggestions.isEmpty) {
      return const _MessageRow(
        icon: Icons.search_off_rounded,
        text: 'Ничего не найдено',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.cardBorder),
      itemBuilder: (BuildContext context, int index) {
        final point = suggestions[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onSelect(point),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.place_outlined,
                    size: 20,
                    color: AppColors.accentBlue.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point.name,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoadingRows extends StatefulWidget {
  const _LoadingRows();

  @override
  State<_LoadingRows> createState() => _LoadingRowsState();
}

class _LoadingRowsState extends State<_LoadingRows> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: List<Widget>.generate(3, (int i) {
          return Padding(
            padding: EdgeInsets.only(bottom: i == 2 ? 0 : 10),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.35, end: 0.85).animate(
                CurvedAnimation(
                  parent: _pulse,
                  curve: Interval(i * 0.15, 0.85, curve: Curves.easeInOut),
                ),
              ),
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.textGray),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
