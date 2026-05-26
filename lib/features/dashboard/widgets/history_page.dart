import 'dashboard_shared.dart';
import 'add_note_page.dart';

class HistoryDashboard extends StatefulWidget {
  const HistoryDashboard({
    super.key,
    required this.transactions,
    required this.onDelete,
    required this.onEdit,
    required this.onMarkSettled,
  });

  final List<DashboardTransaction> transactions;
  final ValueChanged<DashboardTransaction> onDelete;
  final ValueChanged<DashboardTransaction> onEdit;
  final ValueChanged<DashboardTransaction> onMarkSettled;

  @override
  State<HistoryDashboard> createState() => HistoryDashboardState();
}

class HistoryDashboardState extends State<HistoryDashboard> {
  String _query = '';
  String _category = 'Semua';

  List<DashboardTransaction> get _visibleTransactions {
    return widget.transactions.where((item) {
      final matchesQuery = _query.trim().isEmpty ||
          item.title.toLowerCase().contains(_query.toLowerCase()) ||
          item.note.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory = _category == 'Semua' || item.title == _category;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTransactions = _visibleTransactions;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
      children: [
        const Text(
          'Riwayat',
          style: TextStyle(
            color: SakuColors.black,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Cari catatan...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => _FilterDialog(
                    selectedCategory: _category,
                    onApply: (category) {
                      setState(() => _category = category);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.filter_alt_rounded),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const _MonthHeader(),
        const SizedBox(height: 14),
        if (visibleTransactions.isEmpty)
          const EmptyStateCard(
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada catatan',
            message: 'Coba ubah pencarian atau filter kategorinya.',
          )
        else
          _CardList(
            children: visibleTransactions
                .map(
                  (transaction) => TransactionTile(
                    item: transaction,
                    onTap: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => _TransactionDetailDialog(
                          item: transaction,
                          onDelete: () {
                            widget.onDelete(transaction);
                            Navigator.of(context).pop();
                          },
                          onMarkSettled: () {
                            widget.onMarkSettled(transaction);
                            Navigator.of(context).pop();
                          },
                          onEdit: () {
                            Navigator.of(context).pop();
                            widget.onEdit(transaction);
                          },
                        ),
                      );
                    },
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog({
    required this.selectedCategory,
    required this.onApply,
  });

  final String selectedCategory;
  final ValueChanged<String> onApply;

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String _category = widget.selectedCategory;

  void _pickCategory() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SakuColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => CategoryPickerSheet(
        selectedCategory: _category,
        kind: CategoryKind.expense,
        includeAll: true,
        onSelected: (category) {
          setState(() => _category = category);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: SakuColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Filter',
              style: TextStyle(
                color: SakuColors.black,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Cari berdasarkan filter\ntanggal dan kategori',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SakuColors.black,
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DialogSelectField(
                    label: 'Kategori',
                    value: _category == 'Semua' ? 'Semua' : _category,
                    icon: Icons.work_rounded,
                    trailing: Icons.chevron_right_rounded,
                    muted: _category == 'Semua',
                    onTap: _pickCategory,
                  ),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: DialogSelectField(
                    label: 'Tanggal',
                    value: 'Pilih tanggal',
                    icon: null,
                    trailing: Icons.keyboard_arrow_down_rounded,
                    muted: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SakuColors.mango500,
                      side: const BorderSide(
                        color: SakuColors.mango500,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: FilledButton(
                    onPressed: () => widget.onApply(_category),
                    style: FilledButton.styleFrom(
                      backgroundColor: SakuColors.blue300,
                      foregroundColor: SakuColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Cari',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionDetailDialog extends StatelessWidget {
  const _TransactionDetailDialog({
    required this.item,
    required this.onDelete,
    required this.onEdit,
    required this.onMarkSettled,
  });

  final DashboardTransaction item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onMarkSettled;

  bool get _isLoan => item.title == 'Beri Pinjaman';
  bool get _isDebt => item.title == 'Hutang';

  @override
  Widget build(BuildContext context) {
    if (_isLoan) {
      return _LoanDetailDialog(
        item: item,
        onDelete: onDelete,
        onEdit: onEdit,
        onMarkSettled: onMarkSettled,
      );
    }

    if (_isDebt) {
      return _DebtPaymentDialog(
        item: item,
        onMarkSettled: onMarkSettled,
      );
    }

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: SakuColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: item.color.withValues(alpha: 0.12),
              child: Icon(item.icon, color: item.color, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              item.title,
              style: const TextStyle(
                color: SakuColors.black,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.amount,
              style: TextStyle(
                color: item.color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            _DetailLine(label: 'Catatan', value: item.note),
            _DetailLine(label: 'Waktu', value: item.time),
            const _DetailLine(label: 'Dompet', value: 'BSI'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: SakuColors.blue300,
                  foregroundColor: SakuColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtPaymentDialog extends StatelessWidget {
  const _DebtPaymentDialog({
    required this.item,
    required this.onMarkSettled,
  });

  final DashboardTransaction item;
  final VoidCallback onMarkSettled;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: SakuColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bayar hutang dari dompet mana?',
              style: TextStyle(
                color: SakuColors.black,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: DialogSelectField(
                    label: 'Dompet',
                    value: 'BSI',
                    icon: Icons.credit_card_rounded,
                    trailing: Icons.keyboard_arrow_down_rounded,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DialogSelectField(
                    label: 'Tanggal Lunas',
                    value: '12 Juni 2026',
                    icon: null,
                    trailing: Icons.calendar_month_rounded,
                    muted: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SakuColors.mango500,
                      side: const BorderSide(
                        color: SakuColors.mango500,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Kembali',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onMarkSettled,
                    style: FilledButton.styleFrom(
                      backgroundColor: item.settled
                          ? SakuColors.success
                          : SakuColors.neutral300,
                      foregroundColor: item.settled
                          ? SakuColors.white
                          : SakuColors.neutral600,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      item.settled ? 'Sudah Lunas' : 'Lunas',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoanDetailDialog extends StatelessWidget {
  const _LoanDetailDialog({
    required this.item,
    required this.onDelete,
    required this.onEdit,
    required this.onMarkSettled,
  });

  final DashboardTransaction item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onMarkSettled;

  @override
  Widget build(BuildContext context) {
    final person = item.note
        .replaceFirst('Pinjaman ke ', '')
        .replaceFirst('Minjam uang ke ', '')
        .trim();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: SakuColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Beri Pinjaman',
                            style: TextStyle(
                              color: SakuColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          _PaidBadge(settled: item.settled),
                        ],
                      ),
                    ),
                    Text(
                      'Rp ${formatPlain(item.amountValue.abs())}',
                      style: const TextStyle(
                        color: SakuColors.neutral300,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    Icon(
                      Icons.hourglass_bottom_rounded,
                      color: SakuColors.neutral300,
                      size: 15,
                    ),
                    SizedBox(width: 3),
                    Text(
                      '30 April 2026',
                      style: TextStyle(
                        color: SakuColors.neutral300,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(
                  color: SakuColors.neutral300,
                  thickness: 3,
                  height: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nama',
                            style: TextStyle(
                              color: SakuColors.neutral600,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            person.isEmpty ? 'Nama' : person,
                            style: const TextStyle(
                              color: SakuColors.neutral300,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Catatan',
                            style: TextStyle(
                              color: SakuColors.neutral600,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            item.note,
                            style: const TextStyle(
                              color: SakuColors.neutral300,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Cash',
                          style: TextStyle(
                            color: SakuColors.neutral600,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 10),
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          color: SakuColors.mango500,
                          size: 32,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: SakuColors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Hapus',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_rounded, color: Colors.red),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: onEdit,
                  icon:
                      const Icon(Icons.edit_rounded, color: SakuColors.blue700),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Tandai lunas',
                  onPressed: onMarkSettled,
                  icon: Icon(
                    Icons.check_rounded,
                    color: item.settled ? SakuColors.neutral300 : Colors.green,
                    size: 30,
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

class _PaidBadge extends StatelessWidget {
  const _PaidBadge({required this.settled});

  final bool settled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: settled ? const Color(0xFFD9FBE8) : SakuColors.neutral100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: settled ? SakuColors.success : SakuColors.neutral300,
        ),
      ),
      child: Text(
        settled ? 'Lunas' : 'Belum Lunas',
        style: TextStyle(
          color: settled ? SakuColors.success : SakuColors.neutral600,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                color: SakuColors.neutral300,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: SakuColors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(),
      child: Column(children: children),
    );
  }
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.item,
    this.compactIcon = false,
    this.onTap,
  });

  final DashboardTransaction item;
  final bool compactIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: compactIcon
                      ? SakuColors.white
                      : item.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(compactIcon ? 12 : 14),
                  border: compactIcon
                      ? Border.all(color: SakuColors.neutral300, width: 1.5)
                      : null,
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SakuColors.black,
                        fontSize: compactIcon ? 20 : 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: SakuColors.neutral300),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.amount,
                    style: TextStyle(
                      color: item.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.time,
                    style: const TextStyle(color: SakuColors.neutral300),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SakuColors.blue100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(Icons.chevron_left_rounded, color: SakuColors.blue900),
          Expanded(
            child: Column(
              children: [
                Text(
                  'April',
                  style: TextStyle(
                    color: SakuColors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '2026',
                  style: TextStyle(
                    color: SakuColors.neutral700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: SakuColors.blue900),
        ],
      ),
    );
  }
}
