import 'dashboard_shared.dart';
import '../../auth/google_auth_service.dart';
import '../../auth/login_page.dart';
import 'history_page.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({
    super.key,
    required this.userName,
    required this.transactions,
    required this.onOpenHistory,
    required this.onOpenBudget,
    required this.onOpenInsight,
  });

  final String userName;
  final List<DashboardTransaction> transactions;
  final VoidCallback onOpenHistory;
  final VoidCallback onOpenBudget;
  final VoidCallback onOpenInsight;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _HomeHeroSection(
          userName: userName,
          onLogout: () async {
            await GoogleAuthService.instance.signOut();
            if (!context.mounted) return;
            Navigator.of(context).pushReplacementNamed(
              LoginPage.routeName,
            );
          },
          onOpenBudget: onOpenBudget,
          onOpenInsight: onOpenInsight,
        ),
        _HomeBodyPanel(
          transactions: transactions,
          onOpenHistory: onOpenHistory,
        ),
      ],
    );
  }
}

class _HomeHeroSection extends StatelessWidget {
  const _HomeHeroSection({
    required this.userName,
    required this.onLogout,
    required this.onOpenBudget,
    required this.onOpenInsight,
  });

  final String userName;
  final VoidCallback onLogout;
  final VoidCallback onOpenBudget;
  final VoidCallback onOpenInsight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 565,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            height: 506,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SakuColors.blue100,
                image: DecorationImage(
                  image: AssetImage('assets/background beranda biru.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 454,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: SakuColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(46),
                ),
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            top: 50,
            child: _BalanceCard(
              userName: userName,
              onLogout: onLogout,
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            top: 424,
            child: _HeroTools(
              onOpenBudget: onOpenBudget,
              onOpenInsight: onOpenInsight,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBodyPanel extends StatelessWidget {
  const _HomeBodyPanel({
    required this.transactions,
    required this.onOpenHistory,
  });

  final List<DashboardTransaction> transactions;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SakuColors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        children: [
          _RecentNotesCard(
            transactions: transactions.take(2).toList(),
            onOpenMore: onOpenHistory,
          ),
          const SizedBox(height: 20),
          const _ActiveDebtCard(),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.userName,
    required this.onLogout,
  });

  final String userName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(26, 28, 26, 24),
      decoration: BoxDecoration(
        color: SakuColors.blue900.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: SakuColors.blue900.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: SakuColors.blue50,
                child: Icon(
                  Icons.person_rounded,
                  color: SakuColors.blue700,
                  size: 34,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Hei, $userName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SakuColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                onPressed: onLogout,
                style: IconButton.styleFrom(
                  backgroundColor: SakuColors.white.withValues(alpha: 0.18),
                  foregroundColor: SakuColors.white,
                ),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Total Saldo',
                  style: TextStyle(
                    color: SakuColors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.visibility_outlined,
                color: SakuColors.white,
                size: 32,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: SakuColors.blue100,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: SakuColors.blue300, width: 2),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '12.000.000',
                style: TextStyle(
                  color: SakuColors.neutral700,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: SakuColors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: SakuColors.blue300, width: 2),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    title: 'Pengeluaran',
                    amount: '1.000.000',
                    icon: Icons.trending_down_rounded,
                    color: SakuColors.danger,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _HeroMetric(
                    title: 'Pemasukan',
                    amount: '13.000.000',
                    icon: Icons.trending_up_rounded,
                    color: SakuColors.success,
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

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SakuColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: const TextStyle(
                    color: SakuColors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroTools extends StatelessWidget {
  const _HeroTools({
    required this.onOpenBudget,
    required this.onOpenInsight,
  });

  final VoidCallback onOpenBudget;
  final VoidCallback onOpenInsight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 224,
              padding: const EdgeInsets.all(13),
              decoration: cardDecoration(radius: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ToolShortcut(
                      title: 'Budgeting',
                      icon: Icons.savings_rounded,
                      onTap: onOpenBudget,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ToolShortcut(
                      title: 'Saku Insight',
                      icon: Icons.insights_rounded,
                      onTap: onOpenInsight,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            right: 2,
            bottom: -2,
            child: Image(
              image: AssetImage('assets/Maskot-dashboard.png'),
              width: 156,
              height: 98,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolShortcut extends StatelessWidget {
  const _ToolShortcut({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: SakuColors.blue50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SakuColors.blue100, width: 2),
            ),
            child: Icon(icon, color: SakuColors.blue300, size: 34),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                color: SakuColors.black,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentNotesCard extends StatelessWidget {
  const _RecentNotesCard({
    required this.transactions,
    required this.onOpenMore,
  });

  final List<DashboardTransaction> transactions;
  final VoidCallback onOpenMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(radius: 18),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Catatan Terakhir',
                style: TextStyle(
                  color: SakuColors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Container(
            color: SakuColors.blue50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: const Row(
              children: [
                Text(
                  '18',
                  style: TextStyle(
                    color: SakuColors.black,
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'April',
                        style: TextStyle(
                          color: SakuColors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Sabtu',
                        style: TextStyle(
                          color: SakuColors.neutral300,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '11.970.000',
                  style: TextStyle(
                    color: SakuColors.neutral700,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          ...transactions.map((transaction) => TransactionTile(
                item: transaction,
                compactIcon: true,
              )),
          Material(
            color: SakuColors.neutral100,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(18),
            ),
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(18),
              ),
              onTap: onOpenMore,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Lihat riwayat lainnya',
                          style: TextStyle(
                            color: SakuColors.neutral600,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: SakuColors.neutral600,
                      size: 30,
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

class _ActiveDebtCard extends StatelessWidget {
  const _ActiveDebtCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(radius: 18),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hutang Aktif',
            style: TextStyle(
              color: SakuColors.black,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 12),
          _DebtTile(
            title: 'Hutang',
            person: 'Anisa',
            amount: '30.000',
            due: '30 April 2026',
          ),
          Divider(height: 1, color: SakuColors.neutral100),
          _DebtTile(
            title: 'Beri Pinjaman',
            person: 'Nadia',
            amount: '20.000',
            due: '02 Mei 2026',
          ),
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({
    required this.title,
    required this.person,
    required this.amount,
    required this.due,
  });

  final String title;
  final String person;
  final String amount;
  final String due;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: SakuColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SakuColors.neutral300, width: 1.5),
            ),
            child: const Icon(
              Icons.payments_outlined,
              color: SakuColors.sage500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: title,
                    style: const TextStyle(
                      color: SakuColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                    children: const [
                      TextSpan(
                        text: ' Belum Lunas',
                        style: TextStyle(
                          color: SakuColors.danger,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$person - jatuh tempo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SakuColors.neutral300,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    amount,
                    style: const TextStyle(
                      color: SakuColors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    due,
                    style: const TextStyle(
                      color: SakuColors.neutral300,
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
