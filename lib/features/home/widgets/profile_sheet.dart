import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:music_diary_new/core/models/user_profile.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';

enum ProfileSheetAction { save, logout }

class ProfileSheetResult {
  const ProfileSheetResult._(this.action, {this.displayName});

  factory ProfileSheetResult.save(String displayName) =>
      ProfileSheetResult._(ProfileSheetAction.save, displayName: displayName);

  factory ProfileSheetResult.logout() =>
      const ProfileSheetResult._(ProfileSheetAction.logout);

  final ProfileSheetAction action;
  final String? displayName;
}

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key, required this.user});
  final UserProfile user;

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late final _nameController =
      TextEditingController(text: widget.user.displayName);
  bool _isDirty = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.surface, AppColors.surfaceAlt],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.user.email,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Display name',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                onChanged: (_) => setState(() => _isDirty = true),
                decoration: InputDecoration(
                  hintText: 'Your name',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context)
                          .pop(ProfileSheetResult.logout()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isDirty
                          ? () => Navigator.of(context).pop(
                                ProfileSheetResult.save(
                                  _nameController.text.trim(),
                                ),
                              )
                          : null,
                      child: const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
