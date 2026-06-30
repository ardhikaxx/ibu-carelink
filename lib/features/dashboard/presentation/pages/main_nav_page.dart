import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../child_growth/presentation/pages/child_dashboard_page.dart';
import '../../../education/presentation/pages/education_page.dart';
import '../../../pregnancy/presentation/pages/pregnancy_dashboard_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../sync/presentation/widgets/offline_banner_widget.dart';

class MainNavPage extends StatefulWidget {
  final UserEntity user;
  const MainNavPage({super.key, required this.user});

  @override
  State<MainNavPage> createState() => _MainNavPageState();
}

class _MainNavPageState extends State<MainNavPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      PregnancyDashboardPage(userId: widget.user.uid),
      ChildDashboardPage(userId: widget.user.uid),
      const EducationPage(),
      ProfilePage(user: widget.user),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: (_currentIndex == 0 || _currentIndex == 1)
          ? CustomFloatingHeader(
              title: 'Ibu CareLink',
              showBackButton: false,
              leading: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14, top: 4),
          child: Container(
            height: 66,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.favorite_outline_rounded, Icons.favorite_rounded, 'Kehamilan'),
                _buildNavItem(1, Icons.child_friendly_outlined, Icons.child_friendly_rounded, 'Bayi & Anak'),
                _buildNavItem(2, Icons.menu_book_outlined, Icons.menu_book_rounded, 'Edukasi'),
                _buildNavItem(3, Icons.person_outline_rounded, Icons.person_rounded, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRose : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryRose.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : const Color(0xFF94A3B8),
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
