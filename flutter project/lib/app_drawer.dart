import 'package:flutter/material.dart';

enum AppPage { home, prediction, guide, about, settings }

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String prediction = '/prediction';
  static const String guide = '/guide';
  static const String about = '/about';
  static const String settings = '/settings';
}

class AppDrawer extends StatelessWidget {
  final AppPage currentPage;

  const AppDrawer({super.key, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),

            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_outlined,
                    selectedIcon: Icons.home,
                    title: 'Home',
                    page: AppPage.home,
                    routeName: AppRoutes.home,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.camera_alt_outlined,
                    selectedIcon: Icons.camera_alt,
                    title: 'Detection',
                    page: AppPage.prediction,
                    routeName: AppRoutes.prediction,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.menu_book_outlined,
                    selectedIcon: Icons.menu_book,
                    title: 'ASL Guide',
                    page: AppPage.guide,
                    routeName: AppRoutes.guide,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.info_outline,
                    selectedIcon: Icons.info,
                    title: 'About',
                    page: AppPage.about,
                    routeName: AppRoutes.about,
                  ),
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings,
                    title: 'Settings',
                    page: AppPage.settings,
                    routeName: AppRoutes.settings,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(
                    Icons.sign_language,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'ASL Translator',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 24, 18, 22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.65),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.sign_language,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'ASL Translator',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            'Hands that speak, The clarity we seek',
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
    required AppPage page,
    required String routeName,
  }) {
    final bool isSelected = currentPage == page;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Theme.of(
          context,
        ).colorScheme.primaryContainer.withOpacity(0.55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.pop(context);

          if (isSelected) return;

          Navigator.pushReplacementNamed(context, routeName);
        },
      ),
    );
  }
}
