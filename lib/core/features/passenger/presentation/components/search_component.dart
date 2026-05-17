import 'package:flutter/material.dart';

class PassengerSearchComponent extends StatefulWidget {
  const PassengerSearchComponent({super.key});

  @override
  State<PassengerSearchComponent> createState() =>
      _PassengerSearchComponentState();
}

class _PassengerSearchComponentState extends State<PassengerSearchComponent> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime.tryParse(_dateController.text) ?? now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      locale: const Locale('ru', 'RU'),
    );

    if (picked == null) {
      return;
    }

    _dateController.text = _formatDate(picked);
    setState(() {});
  }

  void _switchFromTo() {
    final String currentFrom = _fromController.text;
    _fromController.text = _toController.text;
    _toController.text = currentFrom;
    setState(() {});
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2333),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E3447), width: 1),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x00000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Поиск поездок',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE0E0E0),
            ),
          ),
          const SizedBox(height: 16),
          _buildInput(
            controller: _fromController,
            icon: Icons.location_on,
            hint: 'откуда',
            suffix: IconButton(
              onPressed: _switchFromTo,
              icon: const Icon(
                Icons.swap_vert_rounded,
                color: Color(0xFFE0E0E0),
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildInput(
            controller: _toController,
            icon: Icons.location_on,
            hint: 'куда',
          ),
          const SizedBox(height: 12),
          _buildDateInput(),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1783FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Найти поездки',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    Widget? suffix,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFF2A3142),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A4255), width: 1),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF1783FF), size: 20),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF8A8E99),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE0E0E0),
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _pickDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.calendar_month_outlined,
              size: 20,
              color: Color(0xFF1783FF),
            ),
            const SizedBox(width: 10),
            Text(
              _dateController.text.isEmpty ? 'дата' : _dateController.text,
              style: TextStyle(
                color: _dateController.text.isEmpty
                    ? const Color(0xFFBDBDBD)
                    : const Color(0xFF1A1D24),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
