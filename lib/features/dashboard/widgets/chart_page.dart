import 'dart:math' as math;

import 'dashboard_shared.dart';

class ChartDashboard extends StatelessWidget {
  const ChartDashboard({super.key, required this.transactions});

  final List<DashboardTransaction> transactions;

  static const _palette = [
    Color(0xFFFF355D),
    Color(0xFFF9EA18),
    Color(0xFFFFBE3D),
    Color(0xFFFF7D31),
    Color(0xFFE5007D),
    Color(0xFF5AC97B),
  ];

  List<_ChartCategory> get _categories {
    final grouped = <String, int>{};
    for (final item in transactions.where((item) => item.amountValue < 0)) {
      grouped[item.title] = (grouped[item.title] ?? 0) + item.amountValue.abs();
    }
    if (grouped.isEmpty) {
      return const [
        _ChartCategory(
          title: 'Belum ada',
          percent: 100,
          amountValue: 0,
          icon: Icons.pie_chart_outline_rounded,
          color: SakuColors.neutral300,
        ),
      ];
    }
    final total = grouped.values.fold<int>(0, (sum, value) => sum + value);
    var index = 0;
    return grouped.entries.map((entry) {
      final color = _palette[index % _palette.length];
      index += 1;
      return _ChartCategory(
        title: entry.key,
        percent: math.max(1, ((entry.value / total) * 100).round()),
        amountValue: entry.value,
        icon: categoryIcon(entry.key),
        color: color,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories;
    final totalExpense = transactions
        .where((item) => item.amountValue < 0)
        .fold<int>(0, (sum, item) => sum + item.amountValue.abs());
    final totalIncome = transactions
        .where((item) => item.amountValue > 0)
        .fold<int>(0, (sum, item) => sum + item.amountValue);

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        const _MonthTopBar(),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _PeriodFilter(
            onChanged: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Periode $value dipilih')),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _ChartSection(
            title: 'Pengeluaran',
            total: formatPlain(totalExpense),
            categories: categories,
            accent: SakuColors.danger,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _CompactIncomeCard(totalIncome: totalIncome),
        ),
      ],
    );
  }
}

class _MonthTopBar extends StatelessWidget {
  const _MonthTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SakuColors.blue100,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
      child: const Row(
        children: [
          Icon(Icons.chevron_left_rounded, color: SakuColors.blue900, size: 34),
          Expanded(
            child: Column(
              children: [
                Text(
                  'April',
                  style: TextStyle(
                    color: SakuColors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '2026',
                  style: TextStyle(
                    color: SakuColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: SakuColors.blue900, size: 34),
        ],
      ),
    );
  }
}

class _PeriodFilter extends StatelessWidget {
  const _PeriodFilter({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: SakuColors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Periode',
                    style: TextStyle(
                      color: SakuColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final item in ['Mingguan', 'Bulanan', 'Tahunan'])
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).pop();
                        onChanged(item);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: SakuColors.neutral600,
        side: const BorderSide(color: SakuColors.neutral300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Pilih Periode'),
          SizedBox(width: 24),
          Icon(Icons.keyboard_arrow_down_rounded, color: SakuColors.black),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.total,
    required this.categories,
    required this.accent,
  });

  final String title;
  final String total;
  final List<_ChartCategory> categories;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(radius: 10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 10),
            child: Row(
              children: [
                Icon(Icons.paid_outlined, color: accent, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: SakuColors.black,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: SakuColors.neutral100),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 26),
            child: SizedBox(
              height: 230,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(210, 210),
                    painter: _DonutChartPainter(categories),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: SakuColors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        total,
                        style: const TextStyle(
                          color: SakuColors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          ...categories.take(4).map((category) => _CategoryRow(category)),
          Material(
            color: SakuColors.neutral100,
            child: InkWell(
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: SakuColors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  builder: (context) => _ChartCategorySheet(
                    title: title,
                    categories: categories,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat Lainnya',
                      style: TextStyle(
                        color: SakuColors.neutral600,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: SakuColors.neutral600,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCategorySheet extends StatelessWidget {
  const _ChartCategorySheet({
    required this.title,
    required this.categories,
  });

  final String title;
  final List<_ChartCategory> categories;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semua Kategori $title',
              style: const TextStyle(
                color: SakuColors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final category in categories)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  child: Icon(category.icon, color: SakuColors.black),
                ),
                title: Text(category.title),
                subtitle: Text('Rp ${formatPlain(category.amountValue)}'),
                trailing: Text(
                  '${category.percent}%',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CompactIncomeCard extends StatelessWidget {
  const _CompactIncomeCard({required this.totalIncome});

  final int totalIncome;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(radius: 10),
      child: Row(
        children: [
          const Icon(Icons.paid_outlined, color: SakuColors.success, size: 28),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Pemasukan',
              style: TextStyle(
                color: SakuColors.black,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Text(
            formatPlain(totalIncome),
            style: const TextStyle(
              color: SakuColors.success,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow(this.category);

  final _ChartCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: SakuColors.neutral100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: category.color,
            child: Icon(category.icon, color: SakuColors.black, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.title,
              style: const TextStyle(
                color: SakuColors.neutral700,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${category.percent}%',
            style: const TextStyle(
              color: SakuColors.neutral700,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCategory {
  const _ChartCategory({
    required this.title,
    required this.percent,
    required this.amountValue,
    required this.icon,
    required this.color,
  });

  final String title;
  final int percent;
  final int amountValue;
  final IconData icon;
  final Color color;
}

class _DonutChartPainter extends CustomPainter {
  const _DonutChartPainter(this.categories);

  final List<_ChartCategory> categories;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 48
      ..strokeCap = StrokeCap.butt;

    var startAngle = -math.pi / 2;
    final total = categories.fold<int>(0, (sum, item) => sum + item.percent);

    for (final category in categories) {
      final sweepAngle = math.pi * 2 * (category.percent / total);
      paint.color = category.color;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.categories != categories;
  }
}
