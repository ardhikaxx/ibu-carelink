import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../child_growth/presentation/pages/child_dashboard_page.dart';
import '../../../education/presentation/pages/education_page.dart';
import '../../../emergency/presentation/widgets/sos_floating_button.dart';
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
      body: Column(
        children: [
          const OfflineBannerWidget(),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
      floatingActionButton: const SosFloatingButton(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: AppTheme.primaryTeal,
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
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
