import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/theme/app_colors.dart';

enum DashboardSurface {
  main,
  budget,
  insight,
  notifications,
  addExpense,
  addIncome,
  addDebt,
  addLoan,
  editTransaction,
}

enum AddNoteMode { expense, income, debt, loan }

DashboardSurface surfaceForMode(AddNoteMode mode) {
  return switch (mode) {
    AddNoteMode.expense => DashboardSurface.addExpense,
    AddNoteMode.income => DashboardSurface.addIncome,
    AddNoteMode.debt => DashboardSurface.addDebt,
    AddNoteMode.loan => DashboardSurface.addLoan,
  };
}

class DashboardBudget {
  const DashboardBudget({
    required this.title,
    required this.amountValue,
    required this.remaining,
    required this.progress,
    required this.icon,
  });

  final String title;
  final int amountValue;
  final String remaining;
  final double progress;
  final IconData icon;
}

class DashboardTransaction {
  const DashboardTransaction({
    required this.title,
    required this.note,
    required this.amountValue,
    required this.time,
    required this.icon,
    required this.color,
    this.settled = false,
  });

  final String title;
  final String note;
  final int amountValue;
  final String time;
  final IconData icon;
  final Color color;
  final bool settled;

  String get amount {
    final sign = amountValue < 0 ? '-' : '+';
    return '$sign ${_formatPlainAmount(amountValue.abs())}';
  }

  DashboardTransaction copyWith({
    String? title,
    String? note,
    int? amountValue,
    String? time,
    IconData? icon,
    Color? color,
    bool? settled,
  }) {
    return DashboardTransaction(
      title: title ?? this.title,
      note: note ?? this.note,
      amountValue: amountValue ?? this.amountValue,
      time: time ?? this.time,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      settled: settled ?? this.settled,
    );
  }
}

class DashboardState {
  const DashboardState({
    required this.currentIndex,
    required this.surface,
    required this.transactions,
    required this.budgets,
    this.editingTransaction,
  });

  factory DashboardState.initial({bool openAddNote = false}) {
    return DashboardState(
      currentIndex: 0,
      surface:
          openAddNote ? DashboardSurface.addExpense : DashboardSurface.main,
      transactions: _initialTransactions,
      budgets: _initialBudgets,
    );
  }

  static const _initialBalance = 12045000;

  final int currentIndex;
  final DashboardSurface surface;
  final DashboardTransaction? editingTransaction;
  final List<DashboardTransaction> transactions;
  final List<DashboardBudget> budgets;

  int get currentBalance => transactions.fold<int>(
        _initialBalance,
        (balance, item) => balance + item.amountValue,
      );

  int get currentExpense => transactions
      .where((item) => item.amountValue < 0)
      .fold<int>(0, (sum, item) => sum + item.amountValue.abs());

  bool get showBottomNavigation => surface == DashboardSurface.main;

  bool get hidesFloatingActionButton =>
      surface == DashboardSurface.insight ||
      surface == DashboardSurface.notifications ||
      surface == DashboardSurface.addExpense ||
      surface == DashboardSurface.addIncome ||
      surface == DashboardSurface.addDebt ||
      surface == DashboardSurface.addLoan ||
      surface == DashboardSurface.editTransaction;

  DashboardState copyWith({
    int? currentIndex,
    DashboardSurface? surface,
    Object? editingTransaction = _noValue,
    List<DashboardTransaction>? transactions,
    List<DashboardBudget>? budgets,
  }) {
    return DashboardState(
      currentIndex: currentIndex ?? this.currentIndex,
      surface: surface ?? this.surface,
      editingTransaction: editingTransaction == _noValue
          ? this.editingTransaction
          : editingTransaction as DashboardTransaction?,
      transactions: transactions ?? this.transactions,
      budgets: budgets ?? this.budgets,
    );
  }
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({bool openAddNote = false})
      : super(DashboardState.initial(openAddNote: openAddNote));

  static const _homeWidgetProvider = 'SakuSummaryWidgetProvider';

  void showMain() => emit(state.copyWith(surface: DashboardSurface.main));

  void showSurface(DashboardSurface surface) {
    emit(state.copyWith(surface: surface));
  }

  void showAddNote([AddNoteMode mode = AddNoteMode.expense]) {
    emit(state.copyWith(surface: surfaceForMode(mode)));
  }

  void selectTab(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  void addTransaction(DashboardTransaction item) {
    emit(
      state.copyWith(
        transactions: [item, ...state.transactions],
        surface: DashboardSurface.main,
        currentIndex: 1,
      ),
    );
    syncHomeWidget();
  }

  void addBudget(DashboardBudget item) {
    emit(state.copyWith(budgets: [item, ...state.budgets]));
  }

  void deleteTransaction(DashboardTransaction item) {
    emit(
      state.copyWith(
        transactions:
            state.transactions.where((entry) => entry != item).toList(),
      ),
    );
    syncHomeWidget();
  }

  void markTransactionSettled(DashboardTransaction item) {
    final updated = state.transactions
        .map((entry) => entry == item ? entry.copyWith(settled: true) : entry)
        .toList();
    emit(state.copyWith(transactions: updated));
    syncHomeWidget();
  }

  void openEditTransaction(DashboardTransaction item) {
    emit(
      state.copyWith(
        editingTransaction: item,
        surface: DashboardSurface.editTransaction,
      ),
    );
  }

  void updateTransaction(
    DashboardTransaction oldItem,
    DashboardTransaction newItem,
  ) {
    final updated = state.transactions
        .map((entry) => entry == oldItem ? newItem : entry)
        .toList();
    emit(
      state.copyWith(
        transactions: updated,
        editingTransaction: null,
        surface: DashboardSurface.main,
        currentIndex: 1,
      ),
    );
    syncHomeWidget();
  }

  Future<void> syncHomeWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>(
        'balance',
        'Rp ${_formatPlainAmount(state.currentBalance)}',
      );
      await HomeWidget.saveWidgetData<String>(
        'expense',
        'Rp ${_formatPlainAmount(state.currentExpense)}',
      );
      await HomeWidget.saveWidgetData<String>(
        'latest',
        state.transactions.isEmpty
            ? 'Belum ada catatan'
            : '${state.transactions.first.title} ${state.transactions.first.amount}',
      );
      await HomeWidget.updateWidget(name: _homeWidgetProvider);
    } catch (_) {
      // Platform channel is not available on web and widget tests.
    }
  }
}

const _noValue = Object();

const _initialTransactions = [
  DashboardTransaction(
    title: 'Makanan',
    note: 'Beli jajan kopi sama temen',
    amountValue: -30000,
    time: '11:55 AM',
    icon: Icons.restaurant_rounded,
    color: SakuColors.danger,
  ),
  DashboardTransaction(
    title: 'Hadiah',
    note: 'THR dari bos',
    amountValue: 30000,
    time: '11:55 AM',
    icon: Icons.card_giftcard_rounded,
    color: SakuColors.success,
  ),
  DashboardTransaction(
    title: 'Transportasi',
    note: 'Bensin pulang kampus',
    amountValue: -45000,
    time: '09:20 AM',
    icon: Icons.directions_car_rounded,
    color: SakuColors.danger,
  ),
];

const _initialBudgets = [
  DashboardBudget(
    title: 'Transportasi',
    amountValue: 200000,
    remaining: 'sisa 50%',
    progress: 0.5,
    icon: Icons.directions_car_rounded,
  ),
  DashboardBudget(
    title: 'Belanja',
    amountValue: 150000,
    remaining: 'sisa 40%',
    progress: 0.4,
    icon: Icons.shopping_cart_rounded,
  ),
  DashboardBudget(
    title: 'Skincare',
    amountValue: 300000,
    remaining: 'sisa 35%',
    progress: 0.35,
    icon: Icons.spa_rounded,
  ),
];

String _formatPlainAmount(int value) {
  final text = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final position = text.length - i;
    buffer.write(text[i]);
    if (position > 1 && position % 3 == 1) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}
