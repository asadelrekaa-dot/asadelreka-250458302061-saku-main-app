import 'dashboard_shared.dart';
import 'add_note_page.dart';
import 'budget_page.dart';
import 'chart_page.dart';
import 'edit_transaction_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'insight_page.dart';
import 'notifications_page.dart';
import 'profile_page.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({
    super.key,
    required this.state,
    required this.userName,
    required this.userEmail,
    required this.onRequestHomeWidget,
  });

  final DashboardState state;
  final String userName;
  final String userEmail;
  final VoidCallback onRequestHomeWidget;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    return switch (state.surface) {
      DashboardSurface.budget => BudgetDashboard(
          budgets: state.budgets,
          onBack: cubit.showMain,
        ),
      DashboardSurface.insight => InsightDashboard(onBack: cubit.showMain),
      DashboardSurface.notifications => NotificationsDashboard(
          onBack: cubit.showMain,
        ),
      DashboardSurface.addExpense => AddNoteDashboard(
          mode: AddNoteMode.expense,
          onBack: cubit.showMain,
          onSwitchMode: cubit.showAddNote,
          onSave: cubit.addTransaction,
        ),
      DashboardSurface.addIncome => AddNoteDashboard(
          mode: AddNoteMode.income,
          onBack: cubit.showMain,
          onSwitchMode: cubit.showAddNote,
          onSave: cubit.addTransaction,
        ),
      DashboardSurface.addDebt => AddNoteDashboard(
          mode: AddNoteMode.debt,
          onBack: cubit.showMain,
          onSwitchMode: cubit.showAddNote,
          onSave: cubit.addTransaction,
        ),
      DashboardSurface.addLoan => AddNoteDashboard(
          mode: AddNoteMode.loan,
          onBack: cubit.showMain,
          onSwitchMode: cubit.showAddNote,
          onSave: cubit.addTransaction,
        ),
      DashboardSurface.editTransaction => EditTransactionDashboard(
          item: state.editingTransaction,
          onBack: cubit.showMain,
          onSave: cubit.updateTransaction,
        ),
      DashboardSurface.main => switch (state.currentIndex) {
          0 => HomeDashboard(
              userName: userName,
              transactions: state.transactions,
              onOpenHistory: () => cubit.selectTab(1),
              onOpenBudget: () => cubit.showSurface(DashboardSurface.budget),
              onOpenInsight: () => cubit.showSurface(DashboardSurface.insight),
            ),
          1 => HistoryDashboard(
              transactions: state.transactions,
              onDelete: cubit.deleteTransaction,
              onEdit: cubit.openEditTransaction,
              onMarkSettled: cubit.markTransactionSettled,
            ),
          2 => ChartDashboard(transactions: state.transactions),
          _ => ProfileDashboard(
              initialName: userName,
              initialEmail: userEmail,
              onOpenNotifications: () =>
                  cubit.showSurface(DashboardSurface.notifications),
              onAddHomeWidget: onRequestHomeWidget,
            ),
        },
    };
  }
}
