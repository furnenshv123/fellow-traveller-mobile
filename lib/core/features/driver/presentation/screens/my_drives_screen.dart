import 'package:flutter/material.dart';

class DriverMyRidesScreen extends StatefulWidget {
  const DriverMyRidesScreen({super.key});

  @override
  State<DriverMyRidesScreen> createState() => _DriverMyDrivesScreenState();
}

class _DriverMyDrivesScreenState extends State<DriverMyRidesScreen> {
  final List<_DriverDrive> _myDrives = <_DriverDrive>[
    _DriverDrive(
      from: 'Алматы',
      to: 'Бишкек',
      date: DateTime(2026, 4, 27),
      price: 8500,
      availableSeats: 2,
      requestsCount: 3,
      requests: <_PassengerRequest>[
        _PassengerRequest(
          name: 'Ольга К.',
          rating: 4.9,
          reviews: 89,
          avatar: '👩',
        ),
        _PassengerRequest(
          name: 'Сергей П.',
          rating: 4.6,
          reviews: 45,
          avatar: '👨',
        ),
        _PassengerRequest(
          name: 'Мария Л.',
          rating: 4.3,
          reviews: 21,
          avatar: '👩',
        ),
      ],
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
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEAF2FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Создать',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1783FF),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myDrives.length,
        itemBuilder: (BuildContext context, int index) {
          final _DriverDrive drive = _myDrives[index];
          return GestureDetector(
            onTap: () {
              _showDriveRequests(context, drive);
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              '${drive.price} тг',
                              style: const TextStyle(
                                color: Color(0xFF0E7A36),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${drive.availableSeats} мест',
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3E5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.person_add_rounded,
                            size: 18,
                            color: Color(0xFFE67E22),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${drive.requestsCount} новых запросов',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE67E22),
                            ),
                          ),
                        ],
                      ),
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

  void _showDriveRequests(BuildContext context, _DriverDrive drive) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Запросы пассажиров (${drive.requests.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1D24),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: drive.requests.length,
                      itemBuilder: (BuildContext context, int index) {
                        final _PassengerRequest request = drive.requests[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        request.avatar,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          request.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1A1D24),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: <Widget>[
                                            const Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: Color(0xFFFFC107),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${request.rating} (${request.reviews})',
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
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: () {},
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFEBEE),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text(
                                        'Отклонить',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFC62828),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () {},
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(0xFF1783FF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text(
                                        'Принять',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DriverDrive {
  _DriverDrive({
    required this.from,
    required this.to,
    required this.date,
    required this.price,
    required this.availableSeats,
    required this.requestsCount,
    required this.requests,
  });

  final String from;
  final String to;
  final DateTime date;
  final int price;
  final int availableSeats;
  final int requestsCount;
  final List<_PassengerRequest> requests;
}

class _PassengerRequest {
  _PassengerRequest({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.avatar,
  });

  final String name;
  final double rating;
  final int reviews;
  final String avatar;
}
