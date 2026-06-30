import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
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
          ? AppBar(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              elevation: 0,
              centerTitle: false,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: const Color(0xFFF1F5F9), height: 1),
              ),
              title: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.35), width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ibu CareLink',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w900,
                      fontSize: 19,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppTheme.primaryRose,
          unselectedItemColor: const Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.pregnant_woman_rounded), label: 'Kehamilan'),
            BottomNavigationBarItem(icon: Icon(Icons.child_friendly_rounded), label: 'Bayi & Anak'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Edukasi KIA'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
