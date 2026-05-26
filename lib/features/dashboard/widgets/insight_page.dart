import 'dashboard_shared.dart';

class InsightDashboard extends StatefulWidget {
  const InsightDashboard({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<InsightDashboard> createState() => InsightDashboardState();
}

class InsightDashboardState extends State<InsightDashboard> {
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = const [
    ChatMessage(
      text:
          'Halo, aku Saku AI. Untuk demo ini aku bisa bantu baca pola catatan, kasih tips hemat, dan bikin arahan budgeting sederhana.',
      fromUser: false,
      time: '1:27',
    ),
  ].toList();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    final message = text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis pertanyaan dulu sebelum dikirim')),
      );
      return;
    }

    setState(() {
      _messages
          .add(ChatMessage(text: message, fromUser: true, time: 'Sekarang'));
      _messages.add(
        ChatMessage(
          text: _buildDemoReply(message),
          fromUser: false,
          time: 'Sekarang',
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _buildDemoReply(String message) {
    final lower = message.toLowerCase();
    if (_containsAny(lower, const ['budget', 'batas', 'limit'])) {
      return 'Buka menu Budgeting, isi nominal, pilih kategori, lalu simpan. Untuk demo, budget akan tampil sebagai daftar limit agar user tahu sisa ruang belanjanya.';
    }
    if (_containsAny(lower, const ['grafik', 'laporan', 'kategori'])) {
      return 'Di tab Grafik, user bisa melihat ringkasan pengeluaran per kategori. Cocok buat menjawab kategori mana yang paling sering menghabiskan saldo.';
    }
    if (_containsAny(lower, const ['widget', 'homescreen', 'home screen'])) {
      return 'Widget homescreen menampilkan saldo, pengeluaran, dan catatan terbaru. Di Android, tambah dari Profil > Widget Homescreen atau dari daftar widget launcher.';
    }
    if (_containsAny(lower, const ['dompet', 'rekening', 'wallet'])) {
      return 'Dompet dipakai untuk memisahkan sumber uang, misalnya BSI, Cash, atau e-wallet. Untuk demo, dompet baru bisa ditambahkan dari halaman Profil.';
    }
    if (_containsAny(lower, const ['hutang', 'pinjaman', 'lunas'])) {
      return 'Catatan hutang dan pinjaman bisa dibuat dari tombol tambah. Detailnya bisa dibuka dari riwayat, lalu ditandai lunas saat sudah selesai.';
    }
    if (_containsAny(lower, const ['export', 'excel', 'pdf', 'unduh'])) {
      return 'Untuk sementara export belum aktif. Nanti bisa ditambahkan sebagai tombol laporan bulanan ke PDF atau Excel setelah format laporan disepakati.';
    }
    if (lower.contains('boros') || lower.contains('bulan')) {
      return 'Dari contoh data, pengeluaran yang paling terasa ada di Makanan dan Transportasi. Coba pasang limit mingguan kecil dulu, lalu cek ulang di tab Grafik.';
    }
    if (lower.contains('hemat') || lower.contains('tips')) {
      return 'Mulai dari aturan 3 langkah: catat pengeluaran kecil, pisahkan dompet kebutuhan dan jajan, lalu set budget harian. Yang penting konsisten dulu, bukan langsung sempurna.';
    }
    if (lower.contains('catatan') || lower.contains('pembelian')) {
      return 'Untuk catatan cepat, pakai tombol tambah di tengah, pilih kategori, isi nominal, lalu simpan. Nanti ringkasannya ikut masuk ke widget homescreen Android.';
    }
    return 'Aku catat pertanyaanmu. Versi demo ini menjawab secara lokal dulu; nanti bisa disambungkan ke AI beneran kalau customer sudah siap pakai API.';
  }

  bool _containsAny(String text, List<String> keywords) {
    return keywords.any(text.contains);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChildPageTopBar(title: 'Saku AI', onBack: widget.onBack),
        Expanded(
          child: Container(
            color: SakuColors.blue50,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(42, 30, 42, 24),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _QuickQuestionBubble(onQuestion: _sendMessage),
                      ),
                      const SizedBox(height: 18),
                      ..._messages.map(_ChatBubble.new),
                    ],
                  ),
                ),
                _InsightComposer(onSend: _sendMessage),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickQuestionBubble extends StatelessWidget {
  const _QuickQuestionBubble({required this.onQuestion});

  final ValueChanged<String> onQuestion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: SakuColors.blue100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pertanyaan Cepat',
            style: TextStyle(
              color: SakuColors.blue700,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final question in _quickQuestions) ...[
            _QuestionPill(question, onTap: onQuestion),
            if (question != _quickQuestions.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

const _quickQuestions = [
  'Catatan pembelian cepat',
  'Tips hemat buat aku dong',
  'Bulan ini boros dimana?',
  'Cara bikin budget?',
  'Grafik itu buat apa?',
  'Tambah dompet gimana?',
  'Widget homescreen apa?',
  'Hutang bisa ditandai lunas?',
];

class _QuestionPill extends StatelessWidget {
  const _QuestionPill(this.text, {required this.onTap});

  final String text;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SakuColors.blue300,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: () => onTap(text),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SakuColors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble(this.message);

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.fromUser ? SakuColors.blue300 : SakuColors.white;
    final textColor = message.fromUser ? SakuColors.white : SakuColors.black;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 286),
          child: Column(
            crossAxisAlignment: message.fromUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(message.fromUser ? 18 : 4),
                    bottomRight: Radius.circular(message.fromUser ? 4 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: SakuColors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.38,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.time,
                style: const TextStyle(
                  color: SakuColors.neutral300,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightComposer extends StatefulWidget {
  const _InsightComposer({required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<_InsightComposer> createState() => _InsightComposerState();
}

class _InsightComposerState extends State<_InsightComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final message = _controller.text.trim();
    widget.onSend(message);
    if (message.isNotEmpty) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SakuColors.white,
      padding: const EdgeInsets.fromLTRB(32, 14, 32, 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Tanya AI...',
                filled: true,
                fillColor: SakuColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
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
                  borderSide: const BorderSide(color: SakuColors.blue300),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton.filled(
              onPressed: _send,
              style: IconButton.styleFrom(backgroundColor: SakuColors.blue300),
              icon: const Icon(
                Icons.send_rounded,
                color: SakuColors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
