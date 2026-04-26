import 'package:flutter/material.dart';

class PassengerMyDrivesScreen extends StatefulWidget {
  const PassengerMyDrivesScreen({super.key});

  @override
  State<PassengerMyDrivesScreen> createState() => _PassengerMyDrivesScreenState();
}

class _PassengerMyDrivesScreenState extends State<PassengerMyDrivesScreen> {
  final List<_PassengerDrive> _bookedDrives = <_PassengerDrive>[
    _PassengerDrive(
      from: 'Алматы',
      to: 'Бишкек',
      date: DateTime(2026, 4, 27),
      price: 8500,
      driverName: 'Нурсултан',
      driverRating: 4.8,
      driverReviews: 234,
      driverAvatar: '👨',
      status: 'Upcoming',
    ),
    _PassengerDrive(
      from: 'Астана',
      to: 'Караганда',
      date: DateTime(2026, 4, 20),
      price: 5000,
      driverName: 'Дана',
      driverRating: 4.5,
      driverReviews: 156,
      driverAvatar: '👩',
      status: 'Completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Мои поездки',
          style: TextStyle(
            color: Color(0xFF1A1D24),
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bookedDrives.length,
        itemBuilder: (BuildContext context, int index) {
          final _PassengerDrive drive = _bookedDrives[index];
          return GestureDetector(
            onTap: () {
              _showDriveDetails(context, drive);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEAF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.directions_car,
                            color: Color(0xFF176DFF),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '${drive.from} → ${drive.to}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1D24),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(drive.date),
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
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFF5F5F5),
                          ),
                          child: Center(
                            child: Text(
                              drive.driverAvatar,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                drive.driverName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1D24),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Color(0xFFFFC107),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${drive.driverRating} (${drive.driverReviews})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF667085),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: drive.status == 'Upcoming'
                                ? const Color(0xFFEAF2FF)
                                : const Color(0xFFEEEEEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            drive.status == 'Upcoming' ? 'Впереди' : 'Завершено',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: drive.status == 'Upcoming'
                                  ? const Color(0xFF176DFF)
                                  : const Color(0xFF667085),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  void _showDriveDetails(BuildContext context, _PassengerDrive drive) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF5F5F5),
                    ),
                    child: Center(
                      child: Text(
                        drive.driverAvatar,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          drive.driverName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1D24),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.star_rounded,
                              size: 18,
                              color: Color(0xFFFFC107),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${drive.driverRating}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1D24),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${drive.driverReviews} отзывов',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF667085),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Детали поездки',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1D24),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _detailRow('Маршрут', '${drive.from} → ${drive.to}'),
                    const SizedBox(height: 10),
                    _detailRow('Дата', _formatDate(drive.date)),
                    const SizedBox(height: 10),
                    _detailRow('Цена', '${drive.price} тг'),
                    const SizedBox(height: 10),
                    _detailRow('Статус', drive.status),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1783FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Закрыть',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF667085),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1D24),
          ),
        ),
      ],
    );
  }
}

class _PassengerDrive {
  _PassengerDrive({
    required this.from,
    required this.to,
    required this.date,
    required this.price,
    required this.driverName,
    required this.driverRating,
    required this.driverReviews,
    required this.driverAvatar,
    required this.status,
  });

  final String from;
  final String to;
  final DateTime date;
  final int price;
  final String driverName;
  final double driverRating;
  final int driverReviews;
  final String driverAvatar;
  final String status;
}
