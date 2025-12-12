import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:music_diary_new/core/data/json_file_repo.dart';
import 'package:provider/provider.dart';
import 'package:music_diary_new/core/theme/app_theme.dart';
import 'package:music_diary_new/features/auth/logic/auth_service.dart';
import 'package:music_diary_new/features/home/logic/home_provider.dart';
import 'package:music_diary_new/features/home/widgets/entry_tile.dart';
import 'package:music_diary_new/features/home/widgets/logout_dialog.dart';
import 'package:music_diary_new/features/home/widgets/profile_sheet.dart';
import 'package:music_diary_new/features/inside_diary/inside_diary_page.dart';

class DiaryHomePage extends StatefulWidget {
  const DiaryHomePage({super.key});

  @override
  State<DiaryHomePage> createState() => _DiaryHomePageState();
}

class _DiaryHomePageState extends State<DiaryHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;
  late final Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..forward();
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final entries = provider.entries; // CachedEntry list
        final user = provider.currentUser;

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text('My Diary'),
            flexibleSpace: _AppBarBackground(),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: AvatarButton(
                  imageAsset: user?.avatarAsset,
                  visible: provider.showAvatarImage && user != null,
                  onTap: () => HomeUIActions().openUserMenu(context),
                  onError: provider.hideAvatarImage,
                ),
              ),
            ],
          ),

          body: entries.isEmpty
              ? const EmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (_, i) {
                    final e = entries[i]; // CachedEntry
                    return EntryTile(
                      entry: e,        // CachedEntry
                      animationDelay: i * 0.06,
                      onTap: () =>
                          HomeUIActions().openEntry(context, e),
                      onLongPress: (pos) =>
                          HomeUIActions().showContextMenu(context, e, pos),
                    );
                  },
                ),

          floatingActionButton: ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton(
              onPressed: () => HomeUIActions().createNewEntry(context),
              tooltip: 'Add entry',
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.add, size: 30),
            ),
          ),
        );
      },
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appBarTop, AppColors.appBarBottom],
        ),
      ),
    );
  }
}

/// AVATAR BUTTON
class AvatarButton extends StatelessWidget {
  final String? imageAsset;
  final bool visible;
  final VoidCallback onTap;
  final VoidCallback onError;

  const AvatarButton({
    required this.imageAsset,
    required this.visible,
    required this.onTap,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: visible && imageAsset != null
                ? Image.asset(
                    imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      WidgetsBinding.instance.addPostFrameCallback((_) => onError());
                      return _defaultIcon();
                    },
                  )
                : _defaultIcon(),
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon() => const Icon(Icons.person_outline_rounded);
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Text(
          'No entries yet. Start by adding your first memory.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class HomeUIActions {
  Future<void> openEntry(BuildContext context, CachedEntry cached) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InsideDiaryPage(entryId: cached.id),
      ),
    );

    if (context.mounted) {
      context.read<HomeProvider>().refreshEntries();
    }
  }


  // CREATE NEW ENTRY
  Future<void> createNewEntry(BuildContext context) async {
    final provider = context.read<HomeProvider>();
    final cached = await provider.createEntry();
    if (cached == null) return;

    openEntry(context, cached);
  }

  // USER MENU
  Future<void> openUserMenu(BuildContext context) async {
    final provider = context.read<HomeProvider>();
    final user = provider.currentUser;
    if (user == null) return;

    final result = await showModalBottomSheet<ProfileSheetResult>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileSheet(user: user),
    );

    if (result?.action == ProfileSheetAction.logout) {
      await confirmLogout(context);
    }
  }

  Future<void> confirmLogout(BuildContext context) async {
    final provider = context.read<HomeProvider>();
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (_) => const LogoutDialog(),
        ) ??
        false;

    if (shouldLogout) {
      await AuthService.instance.signOut();
      provider.refreshEntries();
    }
  }

  // CONTEXT MENU
  Future<void> showContextMenu(
      BuildContext context, CachedEntry entry, Offset pos) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(pos.dx, pos.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: 'delete', child: Text('Delete')),
        PopupMenuItem(value: 'rename', child: Text('Rename')),
      ],
    );

    switch (result) {
      case 'delete':
        await context.read<HomeProvider>().deleteEntry(entry);
        break;

      case 'rename':
        await _renameEntry(context, entry);
        break;
    }
  }

  Future<void> _renameEntry(BuildContext context, CachedEntry entry) async {
    final controller = TextEditingController(text: entry.title);

    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename entry'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle == null || newTitle.isEmpty) return;

    await context.read<HomeProvider>().renameEntry(entry, newTitle);
  }
}
