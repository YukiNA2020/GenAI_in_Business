// 负责人：成员 E / 成员 5 — 注册占位（阶段三·任务 4）

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/collectory_theme.dart';
import '../../collection_browse/widgets/collectory_handoff_header.dart';
import '../providers/profile_providers.dart';

class RegisterPlaceholderPage extends ConsumerStatefulWidget {
  const RegisterPlaceholderPage({super.key});

  @override
  ConsumerState<RegisterPlaceholderPage> createState() =>
      _RegisterPlaceholderPageState();
}

class _RegisterPlaceholderPageState extends ConsumerState<RegisterPlaceholderPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }
    ref.read(authSessionProvider.notifier).register(email: email);
    ref.read(userProfileProvider.notifier).updateProfile(
          displayName: email.split('@').first,
        );
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account created (mock).')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CollectoryColors.bgApp,
      appBar: AppBar(
        title: const Text('Register'),
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
              'Register placeholder',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: CollectoryColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No server account is created. This updates mock session state only.',
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
              onPressed: _register,
              style: FilledButton.styleFrom(
                backgroundColor: CollectoryColors.btnPrimaryBg,
                foregroundColor: CollectoryColors.btnPrimaryText,
              ),
              child: const Text('Create account (mock)'),
            ),
          ],
        ),
      ),
    );
  }
}
