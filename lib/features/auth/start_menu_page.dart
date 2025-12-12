import 'package:flutter/material.dart';

import 'login_page.dart';
import 'register_page.dart';

class StartMenuPage extends StatelessWidget {
  const StartMenuPage({super.key});

  Future<void> _open(BuildContext context, Widget page) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF241245), Color(0xFF0A0517)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Welcome to Diary Blocks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Capture your memories in music infused journal entries. Start by creating an account or sign in to continue.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _open(context, const RegisterPage()),
                    child: const Text('Create account'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    onPressed: () => _open(context, const LoginPage()),
                    child: const Text('I already have an account'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
