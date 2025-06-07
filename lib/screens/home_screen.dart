import 'package:flutter/material.dart';
import 'barang_screen.dart';
import 'riwayat_peminjaman_screen.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final Color primaryColor = const Color(0xFF7e57c2);

  void _onItemTapped(int index) async {
    if (index == 3) {
      final logout = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Logout'),
          content: const Text('Yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (logout == true) {
        await AuthService.deleteToken();
        Navigator.pushReplacementNamed(context, '/');
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.school, size: 80, color: Color(0xFF7e57c2)),
              SizedBox(height: 20),
              Text(
                "Selamat Datang di SISFO SARPRAS!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                "Aplikasi ini digunakan untuk melihat data barang, peminjaman, dan pengembalian sarana & prasarana sekolah.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      const BarangScreen(),
      const RiwayatPeminjamanScreen(), // ⬅️ udah aktif ya bro
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}
