import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/material.dart';

enum MainScreenRole { passenger, driver }

enum _UserRole { passenger, driver }

class _Drive {
  const _Drive({
    required this.from,
    required this.to,
    required this.date,
    required this.price,
    required this.driverName,
    required this.seats,
  });

  final String from;
  final String to;
  final DateTime date;
  final int price;
  final String driverName;
  final int seats;
}

class MainScreen extends StatefulWidget {
  const MainScreen({
    this.initialRole = MainScreenRole.passenger,
    super.key,
  });

  final MainScreenRole initialRole;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late _UserRole _role;

  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  final List<_Drive> _sampleDrives = <_Drive>[
    _Drive(
      from: 'Алматы',
      to: 'Бишкек',
      date: DateTime(2026, 4, 27),
      price: 8500,
      driverName: 'Нурсултан',
      seats: 2,
    ),
    _Drive(
      from: 'Тараз',
      to: 'Шымкент',
      date: DateTime(2026, 4, 28),
      price: 4500,
      driverName: 'Азамат',
      seats: 3,
    ),
    _Drive(
      from: 'Астана',
      to: 'Караганда',
      date: DateTime(2026, 4, 29),
      price: 5000,
      driverName: 'Дана',
      seats: 1,
    ),
  ];

  final List<_Drive> _createdByDriver = <_Drive>[];
  List<_Drive> _searchResults = <_Drive>[];

  @override
  void initState() {
    super.initState();
    _role = widget.initialRole == MainScreenRole.driver
        ? _UserRole.driver
        : _UserRole.passenger;
    _searchResults = List<_Drive>.from(_sampleDrives);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
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

  void _searchDrives() {
    final String from = _fromController.text.trim().toLowerCase();
    final String to = _toController.text.trim().toLowerCase();
    final String date = _dateController.text.trim();

    setState(() {
      _searchResults = _sampleDrives.where((_Drive drive) {
        final bool fromMatches = from.isEmpty || drive.from.toLowerCase().contains(from);
        final bool toMatches = to.isEmpty || drive.to.toLowerCase().contains(to);
        final bool dateMatches =
            date.isEmpty || _formatDate(drive.date).toLowerCase() == date.toLowerCase();
        return fromMatches && toMatches && dateMatches;
      }).toList();
    });
  }

  void _createDrive() {
    final String from = _fromController.text.trim();
    final String to = _toController.text.trim();
    final String date = _dateController.text.trim();
    final int seats = int.tryParse(_seatsController.text.trim()) ?? 0;
    final int price = int.tryParse(_priceController.text.trim()) ?? 0;

    if (from.isEmpty || to.isEmpty || date.isEmpty || seats <= 0 || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля корректно')),
      );
      return;
    }

    final DateTime parsedDate = _parseDate(date) ?? DateTime.now();
    final _Drive newDrive = _Drive(
      from: from,
      to: to,
      date: parsedDate,
      price: price,
      driverName: 'Вы',
      seats: seats,
    );

    setState(() {
      _createdByDriver.insert(0, newDrive);
      _fromController.clear();
      _toController.clear();
      _dateController.clear();
      _seatsController.clear();
      _priceController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Поездка создана')));
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  DateTime? _parseDate(String value) {
    final List<String> parts = value.split('.');
    if (parts.length != 3) {
      return null;
    }

    final int? day = int.tryParse(parts[0]);
    final int? month = int.tryParse(parts[1]);
    final int? year = int.tryParse(parts[2]);

    if (day == null || month == null || year == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  List<_Drive> get _drivesForList {
    if (_role == _UserRole.driver) {
      return _createdByDriver;
    }
    return _searchResults;
  }

  @override
  Widget build(BuildContext context) {
    final bool isPassenger = _role == _UserRole.passenger;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildHeroBlock(isPassenger),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                isPassenger ? 'Найденные поездки' : 'Ваши поездки',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: _buildDrivesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBlock(bool isPassenger) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Stack(
          children: <Widget>[
            SizedBox(
              height: 620,
              width: double.infinity,
              child: Image.asset('assets/images/bg_img.png', fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      const Color(0xCC0B2C4A),
                      const Color(0x8C0B2C4A),
                      const Color(0xD9243D56),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1A84FF),
                            ),
                            child: const Icon(Icons.airline_stops_rounded, color: Color(0xFFF5F5F5)),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Poputka',
                            style: TextStyle(
                              color: Color(0xFF1A84FF),
                              fontWeight: FontWeight.w600,
                              fontSize: 27,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1783FF),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'Вход',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Твоя дорога\nтвоя компания',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.w700,
                      height: 1.03,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isPassenger
                        ? 'Мы соединяем водителей, которые едут по своим делам, и попутчиков, ищущих удобный способ добраться до цели.'
                        : 'Создайте поездку, чтобы пассажиры могли найти вас по маршруту и дате.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildRoleSwitcher(),
                  const SizedBox(height: 18),
                  if (isPassenger) ...<Widget>[
                    _buildInput(
                      controller: _fromController,
                      icon: Icons.location_on,
                      hint: 'откуда',
                      suffix: IconButton(
                        onPressed: _switchFromTo,
                        icon: const Icon(
                          Icons.swap_vert_rounded,
                          color: Color(0xFF0E121B),
                          size: 30,
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
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton(
                        onPressed: _searchDrives,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1783FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 60,
                            vertical: 18,
                          ),
                        ),
                        child: const Text(
                          'Найти',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ] else ...<Widget>[
                    _buildInput(
                      controller: _fromController,
                      icon: Icons.location_on,
                      hint: 'откуда',
                    ),
                    const SizedBox(height: 12),
                    _buildInput(
                      controller: _toController,
                      icon: Icons.location_on,
                      hint: 'куда',
                    ),
                    const SizedBox(height: 12),
                    _buildDateInput(),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _buildInput(
                            controller: _seatsController,
                            icon: Icons.event_seat,
                            hint: 'места',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInput(
                            controller: _priceController,
                            icon: Icons.payments,
                            hint: 'цена',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: FilledButton(
                        onPressed: _createDrive,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF1783FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(36),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 38,
                            vertical: 16,
                          ),
                        ),
                        child: const Text(
                          'Создать поездку',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xB3263648),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _RoleItem(
              title: 'Пассажир',
              selected: _role == _UserRole.passenger,
              onTap: () {
                setState(() {
                  _role = _UserRole.passenger;
                });
              },
            ),
          ),
          Expanded(
            child: _RoleItem(
              title: 'Водитель',
              selected: _role == _UserRole.driver,
              onTap: () {
                setState(() {
                  _role = _UserRole.driver;
                });
              },
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
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 74,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0D1118), size: 32),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFAFB2B7),
            fontSize: 38,
            fontWeight: FontWeight.w600,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildDateInput() {
    return SizedBox(
      height: 74,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _pickDate,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 32,
                  color: Color(0xFF0D1118),
                ),
                const SizedBox(width: 14),
                Text(
                  _dateController.text.isEmpty ? 'даты' : _dateController.text,
                  style: TextStyle(
                    color: _dateController.text.isEmpty
                        ? const Color(0xFFAFB2B7)
                        : const Color(0xFF0D1118),
                    fontSize: 38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrivesList() {
    final List<_Drive> data = _drivesForList;

    if (data.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _role == _UserRole.driver
              ? 'У вас пока нет созданных поездок.'
              : 'По вашему запросу ничего не найдено.',
          style: const TextStyle(fontSize: 18, color: Color(0xFF667085)),
        ),
      );
    }

    return Column(
      children: data.map((_Drive drive) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car, color: Color(0xFF176DFF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${drive.from} -> ${drive.to}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(drive.date)} | ${drive.driverName} | ${drive.seats} мест',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF667085),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${drive.price} тг',
                style: const TextStyle(
                  color: Color(0xFF0E7A36),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _RoleItem extends StatelessWidget {
  const _RoleItem({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1783FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
