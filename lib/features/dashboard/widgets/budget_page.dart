import 'dashboard_shared.dart';
import 'add_note_page.dart';

class BudgetDashboard extends StatelessWidget {
  const BudgetDashboard({
    super.key,
    required this.budgets,
    required this.onBack,
  });

  final List<DashboardBudget> budgets;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChildPageTopBar(title: 'Budget', onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(32, 28, 32, 120),
            children: [
              const Text(
                'Budget',
                style: TextStyle(
                  color: SakuColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan Nominal Budget..',
                  filled: true,
                  fillColor: SakuColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: SakuColors.neutral300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: SakuColors.neutral300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: SakuColors.mango500),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Katagori budget',
                style: TextStyle(
                  color: SakuColors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              ...budgets.map(_BudgetRow.new),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow(this.item);

  final DashboardBudget item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: SakuColors.neutral100)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: SakuColors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: SakuColors.neutral300, width: 1.4),
            ),
            child: Icon(item.icon, color: SakuColors.blue700, size: 26),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SakuColors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${formatPlain(item.amountValue)}',
                      style: const TextStyle(
                        color: SakuColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: item.progress,
                          minHeight: 14,
                          color: SakuColors.mango500,
                          backgroundColor: SakuColors.neutral100,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item.remaining,
                      style: const TextStyle(
                        color: SakuColors.neutral300,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetFormDialog extends StatefulWidget {
  const BudgetFormDialog({super.key, required this.onSave});

  final ValueChanged<DashboardBudget> onSave;

  @override
  State<BudgetFormDialog> createState() => BudgetFormDialogState();
}

class BudgetFormDialogState extends State<BudgetFormDialog> {
  final _amountController = TextEditingController();
  String _category = 'Kategori';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
        onSelected: (category) {
          setState(() => _category = category);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _save() {
    final amount = parseCurrency(_amountController.text);
    if (_category == 'Kategori' || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi kategori dan nominal budget')),
      );
      return;
    }

    widget.onSave(
      DashboardBudget(
        title: _category,
        amountValue: amount,
        remaining: 'sisa 100%',
        progress: 1,
        icon: categoryIcon(_category),
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
        padding: const EdgeInsets.fromLTRB(16, 34, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Buat budget baru untuk\nmengatur keuangan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SakuColors.black,
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: DialogSelectField(
                    label: 'Dompet',
                    value: 'BSI',
                    icon: Icons.credit_card_rounded,
                    trailing: Icons.keyboard_arrow_down_rounded,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: DialogSelectField(
                    label: 'Kategori',
                    value: _category,
                    icon: Icons.work_rounded,
                    trailing: Icons.chevron_right_rounded,
                    muted: _category == 'Kategori',
                    onTap: _pickCategory,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Budget',
                style: TextStyle(
                  color: SakuColors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Masukkan Nominal Budget..',
                filled: true,
                fillColor: SakuColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: const BorderSide(color: SakuColors.neutral300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: const BorderSide(color: SakuColors.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(26),
                  borderSide: const BorderSide(color: SakuColors.blue300),
                ),
              ),
            ),
            const SizedBox(height: 54),
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
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: SakuColors.blue300,
                      foregroundColor: SakuColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
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
