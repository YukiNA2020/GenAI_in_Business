// 负责人：成员 E / 成员 5 — 登录占位（阶段三·任务 4）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../providers/profile_providers.dart';
import 'register_placeholder_page.dart';

class LoginPlaceholderPage extends ConsumerStatefulWidget {
  const LoginPlaceholderPage({super.key});

  @override
  ConsumerState<LoginPlaceholderPage> createState() =>
      _LoginPlaceholderPageState();
}

class _LoginPlaceholderPageState extends ConsumerState<LoginPlaceholderPage> {
  final _emailController = TextEditingController(text: 'demo@collection-journey.app');
  final _passwordController = TextEditingController(text: 'demo-password');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    ref.read(authSessionProvider.notifier).signIn(
          email: _emailController.text,
        );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Signed in (mock session).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CollectoryColors.bgApp,
      appBar: AppBar(
        title: const Text('Sign in'),
        backgroundColor: CollectoryColors.bgApp,
        foregroundColor: CollectoryColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(CollectoryColors.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Login placeholder',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: CollectoryColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'JWT not wired yet. Mock sign-in sets local session only.',
              style: CollectoryHandoffHeader.bodySecondary().copyWith(fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _signIn,
              style: FilledButton.styleFrom(
                backgroundColor: CollectoryColors.btnPrimaryBg,
                foregroundColor: CollectoryColors.btnPrimaryText,
              ),
              child: const Text('Sign in (mock)'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => const RegisterPlaceholderPage(),
                  ),
                );
              },
              child: const Text('Create an account'),
            ),
          ],
        ),
      ),
    );
  }
}
