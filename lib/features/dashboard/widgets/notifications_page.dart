import 'dashboard_shared.dart';

class NotificationsDashboard extends StatelessWidget {
  const NotificationsDashboard({super.key, required this.onBack});

  final VoidCallback onBack;

  static const _items = [
    NotificationItem(
      title: 'Jangan lupa catat ya. sudah ada\npengeluaran hari ini?',
      time: '4:40 PM',
      icon: Icons.edit_note_rounded,
      iconColor: SakuColors.neutral700,
    ),
    NotificationItem(
      title:
          'Pengeluaran meningkat kamu\nmenghabiskan lebih banyak dari pada\nbiasanya',
      time: '6.30 PM',
      icon: Icons.trending_down_rounded,
      iconColor: SakuColors.danger,
    ),
    NotificationItem(
      title:
          'Pengeluaran tercatat\nkamu baru saja mengeluarkan Rp\n50.000 untuk makan',
      time: '8.25 PM',
      icon: Icons.edit_note_rounded,
      iconColor: SakuColors.neutral700,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChildPageTopBar(title: 'Notifikasi', onBack: onBack),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _NotificationRow(item: _items[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 14, 32, 10),
      decoration: const BoxDecoration(
        color: SakuColors.white,
        border: Border(bottom: BorderSide(color: SakuColors.neutral300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            height: 40,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                Icon(item.icon, color: item.iconColor, size: 28),
                if (item.icon == Icons.edit_note_rounded)
                  const Positioned(
                    right: 0,
                    bottom: 3,
                    child: Icon(
                      Icons.edit_rounded,
                      color: SakuColors.mango500,
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: SakuColors.black,
                    fontSize: 17,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    item.time,
                    style: const TextStyle(
                      color: SakuColors.neutral300,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
