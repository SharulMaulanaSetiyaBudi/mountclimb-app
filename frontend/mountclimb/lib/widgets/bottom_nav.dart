import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/explore_page.dart';
import '../pages/my_ticket_page.dart';
import '../pages/profile_page.dart';

// Bottom navigation utama aplikasi MountClimb.
// StatelessWidget: perpindahan tab dilakukan lewat Navigator.pushReplacement
// menuju halaman tujuan, bukan lewat setState/IndexedStack, supaya semua
// halaman tetap bisa menjadi StatelessWidget.
class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({super.key, required this.currentIndex});

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    late final Widget page;
    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const ExplorePage();
        break;
      case 2:
        page = const MyTicketPage();
        break;
      case 3:
        page = const ProfilePage();
        break;
      default:
        page = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onTap(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1E88E5),
          unselectedItemColor: const Color(0xFF90A4AE),
          showUnselectedLabels: true,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number_outlined),
              activeIcon: Icon(Icons.confirmation_number),
              label: 'My Ticket',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
