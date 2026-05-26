import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'widgets/budget_page.dart';
import 'widgets/dashboard_content.dart';
import 'widgets/dashboard_shared.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    super.key,
    this.userName = 'Asadel',
    this.userEmail = 'adel123@gmail.com',
    this.openAddNote = false,
  });

  static const routeName = '/home';
  final String userName;
  final String userEmail;
  final bool openAddNote;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _homeWidgetProvider = 'SakuSummaryWidgetProvider';

  Future<void> _requestHomeWidget() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      showInfoDialog(
        context,
        title: 'Widget Homescreen',
        message:
            'Widget ringkasan siap untuk Android. Tambahkan dari homescreen perangkat Android setelah aplikasi diinstal.',
      );
      return;
    }

    try {
      await HomeWidget.updateWidget(name: _homeWidgetProvider);
      final supported = await HomeWidget.isRequestPinWidgetSupported() ?? false;
      if (supported) {
        await HomeWidget.requestPinWidget(name: _homeWidgetProvider);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permintaan widget dikirim ke homescreen')),
        );
      } else {
        if (!mounted) return;
        showInfoDialog(
          context,
          title: 'Tambahkan Widget',
          message:
              'Tekan lama area kosong di homescreen, pilih Widget, lalu pilih Saku Ringkasan.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      showInfoDialog(
        context,
        title: 'Tambahkan Widget',
        message:
            'Tekan lama area kosong di homescreen, pilih Widget, lalu pilih Saku Ringkasan.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          DashboardCubit(openAddNote: widget.openAddNote)..syncHomeWidget(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final cubit = context.read<DashboardCubit>();
          return Scaffold(
            backgroundColor: SakuColors.neutral50,
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final pageWidth =
                      constraints.maxWidth > 430 ? 430.0 : constraints.maxWidth;

                  return Center(
                    child: SizedBox(
                      width: pageWidth,
                      height: constraints.maxHeight,
                      child: DashboardContent(
                        state: state,
                        userName: widget.userName,
                        userEmail: widget.userEmail,
                        onRequestHomeWidget: _requestHomeWidget,
                      ),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: state.hidesFloatingActionButton
                ? null
                : FloatingActionButton(
                    onPressed: () {
                      if (state.surface == DashboardSurface.budget) {
                        showDialog<void>(
                          context: context,
                          builder: (context) => BudgetFormDialog(
                            onSave: (item) {
                              cubit.addBudget(item);
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                        return;
                      }
                      cubit.showAddNote();
                    },
                    backgroundColor: SakuColors.mango500,
                    foregroundColor: SakuColors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.add_rounded, size: 34),
                  ),
            floatingActionButtonLocation: state.showBottomNavigation
                ? FloatingActionButtonLocation.centerDocked
                : FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: state.showBottomNavigation
                ? Container(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Center(
                      heightFactor: 1,
                      child: SizedBox(
                        width: 430,
                        child: NavigationBar(
                          selectedIndex: state.currentIndex,
                          onDestinationSelected: cubit.selectTab,
                          indicatorColor: SakuColors.blue100,
                          destinations: const [
                            NavigationDestination(
                              icon: Icon(Icons.home_outlined),
                              selectedIcon: Icon(Icons.home_rounded),
                              label: 'Beranda',
                            ),
                            NavigationDestination(
                              icon: Icon(Icons.receipt_long_outlined),
                              selectedIcon: Icon(Icons.receipt_long_rounded),
                              label: 'Riwayat',
                            ),
                            NavigationDestination(
                              icon: Icon(Icons.pie_chart_outline_rounded),
                              selectedIcon: Icon(Icons.pie_chart_rounded),
                              label: 'Grafik',
                            ),
                            NavigationDestination(
                              icon: Icon(Icons.person_outline_rounded),
                              selectedIcon: Icon(Icons.person_rounded),
                              label: 'Profil',
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}
