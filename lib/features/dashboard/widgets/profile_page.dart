import 'dashboard_shared.dart';
import '../../auth/google_auth_service.dart';
import '../../auth/login_page.dart';

class ProfileDashboard extends StatefulWidget {
  const ProfileDashboard({
    super.key,
    required this.initialName,
    required this.initialEmail,
    required this.onOpenNotifications,
    required this.onAddHomeWidget,
  });

  final String initialName;
  final String initialEmail;
  final VoidCallback onOpenNotifications;
  final VoidCallback onAddHomeWidget;

  @override
  State<ProfileDashboard> createState() => ProfileDashboardState();
}

class ProfileDashboardState extends State<ProfileDashboard> {
  late String _profileName;
  late String _profileEmail;
  bool _passwordChanged = false;
  bool _photoUpdated = false;
  final List<WalletItem> _wallets = [
    const WalletItem(name: 'BSI', balance: 12000000),
  ];

  @override
  void initState() {
    super.initState();
    _profileName = widget.initialName;
    _profileEmail = widget.initialEmail;
  }

  void _openAddWalletDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => _WalletFormDialog(
        onSave: (wallet) {
          setState(() => _wallets.add(wallet));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openProfileEditDialog(_ProfileEditField field) {
    showDialog<void>(
      context: context,
      builder: (context) => _ProfileEditDialog(
        field: field,
        currentName: _profileName,
        currentEmail: _profileEmail,
        onSaveName: (value) {
          setState(() => _profileName = value);
          Navigator.of(context).pop();
        },
        onSaveEmail: (value) {
          setState(() => _profileEmail = value);
          Navigator.of(context).pop();
        },
        onSavePassword: () {
          setState(() => _passwordChanged = true);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showProfilePhotoInfo() {
    setState(() => _photoUpdated = true);
    showInfoDialog(
      context,
      title: 'Foto Profil',
      message:
          'Untuk demo tanpa database, foto profil ditandai sudah diperbarui. Nanti bisa disambungkan ke galeri/kamera perangkat.',
    );
  }

  void _showWalletDetail(WalletItem item) {
    showDialog<void>(
      context: context,
      builder: (context) => _WalletDetailDialog(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _ProfileHeader(
          name: _profileName,
          photoUpdated: _photoUpdated,
          onEditPhoto: _showProfilePhotoInfo,
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 12),
          decoration: const BoxDecoration(
            color: SakuColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ProfileSectionTitle('List Dompet'),
              const SizedBox(height: 12),
              ..._wallets.map(
                (wallet) => _WalletCard(
                  wallet,
                  onTap: () => _showWalletDetail(wallet),
                ),
              ),
              if (_wallets.isNotEmpty) const SizedBox(height: 12),
              _AddWalletCard(onTap: _openAddWalletDialog),
              const SizedBox(height: 24),
              const _ProfileSectionTitle('Informasi Akun'),
              const SizedBox(height: 12),
              _ProfileMenuTile(
                icon: Icons.person_rounded,
                title: 'Nama',
                subtitle: _profileName,
                onTap: () => _openProfileEditDialog(_ProfileEditField.name),
              ),
              const SizedBox(height: 12),
              _ProfileMenuTile(
                icon: Icons.mail_rounded,
                title: 'Email',
                subtitle: _profileEmail,
                onTap: () => _openProfileEditDialog(_ProfileEditField.email),
              ),
              const SizedBox(height: 12),
              _ProfileMenuTile(
                icon: Icons.lock_rounded,
                title: 'Password',
                subtitle: _passwordChanged ? 'Sudah diperbarui' : '********',
                onTap: () => _openProfileEditDialog(_ProfileEditField.password),
              ),
              const SizedBox(height: 24),
              const _ProfileSectionTitle('Pengaturan'),
              const SizedBox(height: 12),
              _NotificationTile(onTap: widget.onOpenNotifications),
              const SizedBox(height: 12),
              _ProfileMenuTile(
                icon: Icons.widgets_rounded,
                title: 'Widget Homescreen',
                subtitle: 'Ringkasan saldo di layar utama',
                iconColor: SakuColors.blue700,
                onTap: widget.onAddHomeWidget,
              ),
              const SizedBox(height: 12),
              _ProfileMenuTile(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                subtitle: 'Kembali ke halaman masuk',
                iconColor: SakuColors.mango500,
                trailing: Icons.chevron_right_rounded,
                onTap: () async {
                  await GoogleAuthService.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context)
                      .pushReplacementNamed(LoginPage.routeName);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _ProfileEditField { name, email, password }

class _ProfileEditDialog extends StatefulWidget {
  const _ProfileEditDialog({
    required this.field,
    required this.currentName,
    required this.currentEmail,
    required this.onSaveName,
    required this.onSaveEmail,
    required this.onSavePassword,
  });

  final _ProfileEditField field;
  final String currentName;
  final String currentEmail;
  final ValueChanged<String> onSaveName;
  final ValueChanged<String> onSaveEmail;
  final VoidCallback onSavePassword;

  @override
  State<_ProfileEditDialog> createState() => _ProfileEditDialogState();
}

class _ProfileEditDialogState extends State<_ProfileEditDialog> {
  late final TextEditingController _primaryController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool get _isName => widget.field == _ProfileEditField.name;
  bool get _isEmail => widget.field == _ProfileEditField.email;
  bool get _isPassword => widget.field == _ProfileEditField.password;

  String get _title {
    return switch (widget.field) {
      _ProfileEditField.name => 'Edit Nama',
      _ProfileEditField.email => 'Edit Email',
      _ProfileEditField.password => 'Ganti Password',
    };
  }

  @override
  void initState() {
    super.initState();
    _primaryController = TextEditingController(
      text: _isName
          ? widget.currentName
          : _isEmail
              ? widget.currentEmail
              : '',
    );
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _save() {
    if (_isPassword) {
      final password = _passwordController.text.trim();
      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password baru minimal 6 karakter'),
          ),
        );
        return;
      }
      widget.onSavePassword();
      return;
    }

    final value = _primaryController.text.trim();
    if (value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data belum diisi')),
      );
      return;
    }

    if (_isEmail && !value.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Format email belum benar')),
      );
      return;
    }

    if (_isName) {
      widget.onSaveName(value);
    } else {
      widget.onSaveEmail(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      backgroundColor: SakuColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SakuColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 22),
            if (!_isPassword)
              _ProfileEditFieldInput(
                label: _isEmail ? 'Email' : 'Nama',
                controller: _primaryController,
                keyboardType:
                    _isEmail ? TextInputType.emailAddress : TextInputType.text,
                icon: _isEmail ? Icons.mail_rounded : Icons.person_rounded,
              )
            else ...[
              _ProfileEditFieldInput(
                label: 'Password lama',
                controller: _primaryController,
                obscureText: true,
                icon: Icons.edit_rounded,
                hintText: 'Masukkan password lama',
              ),
              const SizedBox(height: 14),
              _ProfileEditFieldInput(
                label: 'Password baru',
                controller: _passwordController,
                obscureText: true,
                icon: Icons.edit_rounded,
                hintText: 'Masukkan password baru',
              ),
            ],
            const SizedBox(height: 34),
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

class _ProfileEditFieldInput extends StatelessWidget {
  const _ProfileEditFieldInput({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SakuColors.black,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: Icon(icon, color: SakuColors.black),
            filled: true,
            fillColor: SakuColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: SakuColors.neutral300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: SakuColors.blue300),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.photoUpdated,
    required this.onEditPhoto,
  });

  final String name;
  final bool photoUpdated;
  final VoidCallback onEditPhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: const BoxDecoration(
        color: SakuColors.blue100,
        image: DecorationImage(
          image: AssetImage('assets/background beranda biru.png'),
          fit: BoxFit.cover,
          opacity: 0.32,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 34,
            child: Container(
              width: 94,
              height: 94,
              decoration: BoxDecoration(
                color: SakuColors.blue50,
                shape: BoxShape.circle,
                border: Border.all(color: SakuColors.white, width: 4),
              ),
              child: Icon(
                photoUpdated ? Icons.check_rounded : Icons.person_rounded,
                color: SakuColors.blue700,
                size: 62,
              ),
            ),
          ),
          Positioned(
            top: 104,
            right: 165,
            child: Material(
              color: SakuColors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onEditPhoto,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.camera_alt_rounded),
                ),
              ),
            ),
          ),
          Positioned(
            top: 140,
            child: Text(
              name,
              style: const TextStyle(
                color: SakuColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: SakuColors.black,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard(this.item, {required this.onTap});

  final WalletItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: SakuColors.blue50,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SakuColors.blue100),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: SakuColors.blue300,
                  child:
                      Icon(Icons.credit_card_rounded, color: SakuColors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: SakuColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Rp ${formatPlain(item.balance)}',
                        style: const TextStyle(
                          color: SakuColors.neutral600,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletDetailDialog extends StatelessWidget {
  const _WalletDetailDialog({required this.item});

  final WalletItem item;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: SakuColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: SakuColors.blue300,
              child: Icon(Icons.credit_card_rounded, color: SakuColors.white),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(
                color: SakuColors.black,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Saldo Rp ${formatPlain(item.balance)}',
              style: const TextStyle(
                color: SakuColors.neutral600,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Detail dompet masih berupa data lokal demo. Nanti bagian ini bisa dipakai untuk edit nama dompet, arsip, dan melihat transaksi dompet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SakuColors.neutral600,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: SakuColors.blue300,
                  foregroundColor: SakuColors.white,
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWalletCard extends StatelessWidget {
  const _AddWalletCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SakuColors.neutral100,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SakuColors.neutral300),
          ),
          child: const Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: SakuColors.neutral300,
                child:
                    Icon(Icons.add_rounded, color: SakuColors.white, size: 34),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Tambah dompet baru',
                  style: TextStyle(
                    color: SakuColors.neutral600,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor = SakuColors.blue700,
    this.trailing = Icons.chevron_right_rounded,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final IconData trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SakuColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SakuColors.neutral300),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 27),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: SakuColors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
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
              Icon(trailing, color: SakuColors.neutral600, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletFormDialog extends StatefulWidget {
  const _WalletFormDialog({required this.onSave});

  final ValueChanged<WalletItem> onSave;

  @override
  State<_WalletFormDialog> createState() => _WalletFormDialogState();
}

class _WalletFormDialogState extends State<_WalletFormDialog> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  bool _isPrimary = false;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final balance = parseCurrency(_balanceController.text);
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dompet belum diisi')),
      );
      return;
    }
    widget.onSave(WalletItem(name: name, balance: balance));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.bottomCenter,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: SakuColors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 38, 22, 38),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Buat Dompet baru',
              style: TextStyle(
                color: SakuColors.black,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: _WalletDialogField(
                    label: 'Nama Dompet',
                    child: TextField(
                      controller: _nameController,
                      decoration: _walletInputDecoration('Nama dompet'),
                    ),
                  ),
                ),
                const SizedBox(width: 26),
                Expanded(
                  child: _WalletDialogField(
                    label: 'Pilih Icon',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Pilihan icon tersedia di versi demo'),
                          ),
                        );
                      },
                      child: Container(
                        height: 55,
                        decoration: BoxDecoration(
                          color: SakuColors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: SakuColors.neutral300),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_rounded,
                              color: SakuColors.mango500,
                            ),
                            SizedBox(width: 20),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: SakuColors.black,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            _WalletDialogField(
              label: 'Saldo Awal',
              child: TextField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: _walletInputDecoration('Masukkan saldo awal..'),
              ),
            ),
            const SizedBox(height: 20),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() => _isPrimary = !_isPrimary),
              child: Row(
                children: [
                  Checkbox(
                    value: _isPrimary,
                    onChanged: (value) {
                      setState(() => _isPrimary = value ?? false);
                    },
                    shape: const CircleBorder(),
                    side: const BorderSide(color: SakuColors.neutral300),
                    activeColor: SakuColors.blue300,
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Jadikan Dompet Utama',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: SakuColors.neutral300,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 46),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SakuColors.mango500,
                      side: const BorderSide(
                        color: SakuColors.mango500,
                        width: 2.4,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 26),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: SakuColors.blue300,
                      foregroundColor: SakuColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
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

class _WalletDialogField extends StatelessWidget {
  const _WalletDialogField({
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SakuColors.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration _walletInputDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: SakuColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: SakuColors.neutral300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: SakuColors.neutral300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: SakuColors.blue300),
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SakuColors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: SakuColors.neutral300),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.notifications_rounded,
                color: SakuColors.mango500,
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: SakuColors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Switch(
                value: true,
                onChanged: (_) => onTap(),
                activeThumbColor: SakuColors.white,
                activeTrackColor: SakuColors.mango500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
