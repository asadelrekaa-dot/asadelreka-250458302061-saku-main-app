import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:saku_pengeluaran/core/theme/app_theme.dart';
import 'package:saku_pengeluaran/features/dashboard/dashboard_page.dart';
import 'package:saku_pengeluaran/main.dart';

void main() {
  testWidgets('shows onboarding and navigates to login', (tester) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(const SakuApp());
    await _pumpPastSplash(tester);

    expect(find.text('Kelola Uangmu Lebih Cepat'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Pantau Saku Tanpa Ribet'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('Masuk dengan Google'), findsOneWidget);
  });

  testWidgets('dashboard flows stay interactive', (tester) async {
    _setMobileViewport(tester);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const DashboardPage(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hei, Asadel!'), findsOneWidget);
    expect(find.text('Catatan Terakhir'), findsOneWidget);

    await tester.tap(find.text('Budgeting'));
    await tester.pumpAndSettle();

    expect(find.text('Budget'), findsWidgets);
    expect(find.text('Katagori budget'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(
        find.text('Buat budget baru untuk\nmengatur keuangan'), findsOneWidget);
    expect(find.text('Dompet'), findsOneWidget);
    expect(find.text('Kategori'), findsWidgets);

    await tester.tap(find.text('Kategori').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makanan').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Masukkan Nominal Budget..').last,
      '500000',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Rp 500.000'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saku Insight'));
    await tester.pumpAndSettle();

    expect(find.text('Saku AI'), findsOneWidget);
    expect(find.text('Pertanyaan Cepat'), findsOneWidget);
    expect(find.text('Tanya AI...'), findsOneWidget);
    expect(find.text('Cara bikin budget?'), findsOneWidget);
    expect(find.text('Widget homescreen apa?'), findsOneWidget);

    await tester.tap(find.text('Tips hemat buat aku dong'));
    await tester.pumpAndSettle();
    expect(find.text('Tips hemat buat aku dong'), findsWidgets);
    expect(find.textContaining('Mulai dari aturan 3 langkah'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Tanya AI...'),
      'Cara bikin budget?',
    );
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining('Buka menu Budgeting'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Tanya AI...'),
        'Bulan ini boros dimana?');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Bulan ini boros dimana?'), findsWidgets);
    expect(
        find.textContaining('pengeluaran yang paling terasa'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded).first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Catatan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
    expect(find.byIcon(Icons.payments_outlined), findsOneWidget);
    expect(find.byIcon(Icons.request_quote_outlined), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);

    await tester.tap(find.text('Makanan'));
    await tester.pumpAndSettle();
    expect(find.text('Kategori Pengeluaran'), findsOneWidget);
    await tester.tap(find.text('Transportasi'));
    await tester.pumpAndSettle();

    expect(find.text('Transportasi'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.savings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Gaji'), findsOneWidget);

    await tester.tap(find.text('Gaji'));
    await tester.pumpAndSettle();
    expect(find.text('Kategori Pemasukan'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    await tester.tap(find.text('Freelance'));
    await tester.pumpAndSettle();

    expect(find.text('Freelance'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.payments_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Hutang'), findsOneWidget);
    expect(find.text('Jatuh Tempo'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.request_quote_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Dompet'), findsOneWidget);
    expect(find.text('BSI'), findsOneWidget);

    await tester.tap(find.text('2'));
    await tester.tap(find.text('000'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Beri Pinjaman'), findsOneWidget);
    expect(find.text('- 2.000'), findsOneWidget);

    await tester.tap(find.text('Beri Pinjaman'));
    await tester.pumpAndSettle();

    expect(find.text('30 April 2026'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.byIcon(Icons.delete_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Edit Catatan'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(1), 'Sudah ditagih');
    await tester.enterText(find.byType(TextField).at(2), '3500');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('- 3.500'), findsOneWidget);

    await tester.tap(find.text('Beri Pinjaman'));
    await tester.pumpAndSettle();

    expect(find.text('Sudah ditagih'), findsWidgets);

    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Beri Pinjaman'));
    await tester.pumpAndSettle();

    expect(find.text('Lunas'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Beri Pinjaman'), findsNothing);

    await tester.tap(find.text('Riwayat').last);
    await tester.pumpAndSettle();

    expect(find.text('Cari catatan...'), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_alt_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Cari berdasarkan filter\ntanggal dan kategori'),
        findsOneWidget);
    expect(find.text('Pilih tanggal'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grafik').last);
    await tester.pumpAndSettle();

    expect(find.text('Pilih Periode'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    await tester.tap(find.text('Lihat Lainnya'));
    await tester.pumpAndSettle();
    expect(find.text('Semua Kategori Pengeluaran'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();

    expect(find.text('List Dompet'), findsOneWidget);
    expect(find.text('Informasi Akun'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.camera_alt_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Foto Profil'), findsOneWidget);
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nama'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Nama'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Yahya');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Yahya'), findsWidgets);

    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Email'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'yahya@saku.test');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('yahya@saku.test'), findsOneWidget);

    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();
    expect(find.text('Ganti Password'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Masukkan password lama'),
      'oldsecret',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Masukkan password baru'),
      'secret123',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    expect(find.text('Sudah diperbarui'), findsOneWidget);

    await tester.tap(find.text('BSI'));
    await tester.pumpAndSettle();
    expect(find.text('Saldo Rp 12.000.000'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Tambah dompet baru'));
    await tester.tap(find.text('Tambah dompet baru'));
    await tester.pumpAndSettle();

    expect(find.text('Buat Dompet baru'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Nama dompet'),
      'Cash',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Masukkan saldo awal..'),
      '25000',
    );
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Rp 25.000'), findsOneWidget);

    await tester.ensureVisible(find.text('Widget Homescreen'));
    await tester.tap(find.text('Widget Homescreen'));
    await tester.pumpAndSettle();
    expect(find.text('Widget Homescreen'), findsWidgets);

    await tester.ensureVisible(find.text('Notifikasi'));
    await tester.tap(find.text('Notifikasi'));
    await tester.pumpAndSettle();

    expect(find.text('Jangan lupa catat ya. sudah ada\npengeluaran hari ini?'),
        findsOneWidget);
    expect(
        find.text(
            'Pengeluaran meningkat kamu\nmenghabiskan lebih banyak dari pada\nbiasanya'),
        findsOneWidget);
  });
}

void _setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(412, 917);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _pumpPastSplash(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 1300));
  await tester.pumpAndSettle();
}
