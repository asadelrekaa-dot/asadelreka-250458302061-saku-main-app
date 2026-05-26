import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/app_logo.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SakuColors.blue100,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/bg-ilst11.png',
              height: 158,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final panelMinHeight = (constraints.maxHeight - 190)
                    .clamp(0.0, double.infinity)
                    .toDouble();

                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      children: [
                        const SizedBox(height: 44),
                        const AppLogo(width: 148),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: panelMinHeight,
                              maxWidth: 430,
                            ),
                            padding: const EdgeInsets.fromLTRB(28, 30, 28, 30),
                            decoration: const BoxDecoration(
                              color: SakuColors.white,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(36),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  subtitle,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: SakuColors.black,
                                    fontSize: 15,
                                    height: 1.42,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ...children,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
