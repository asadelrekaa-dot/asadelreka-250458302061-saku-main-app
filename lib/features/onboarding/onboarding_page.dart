import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../auth/login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const routeName = '/';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingContent> _items = const [
    _OnboardingContent(
      image: 'assets/asset onboarding 1.png',
      title: 'Kelola Uangmu Lebih Cepat',
      description:
          'Catat setiap pemasukan dan pengeluaran harianmu dengan cepat dan mudah.',
    ),
    _OnboardingContent(
      image: 'assets/asset onboarding 2.png',
      title: 'Pantau Saku Tanpa Ribet',
      description:
          'Lihat ringkasan keuangan, budget, dan kebiasaan belanjamu dalam satu tempat.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    Navigator.of(context).pushReplacementNamed(LoginPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageHeight = (size.height * 0.34).clamp(230.0, 320.0).toDouble();

    return Scaffold(
      backgroundColor: SakuColors.blue50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 30),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Image.asset(
                          item.image,
                          height: imageHeight,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _items.length,
                            (dotIndex) => _OnboardingDot(
                              isActive: dotIndex == _currentPage,
                            ),
                          ),
                        ),
                        const SizedBox(height: 42),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: SakuColors.black,
                            fontSize: 17,
                            height: 1.45,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: SakuColors.blue300,
                      foregroundColor: SakuColors.white,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      size: 46,
                    ),
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

class _OnboardingDot extends StatelessWidget {
  const _OnboardingDot({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: isActive ? 13 : 12,
      height: isActive ? 13 : 12,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: isActive ? SakuColors.blue300 : Colors.transparent,
        border: Border.all(
          color: isActive ? SakuColors.blue300 : SakuColors.neutral300,
        ),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });

  final String image;
  final String title;
  final String description;
}
