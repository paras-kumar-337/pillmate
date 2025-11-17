import 'package:flutter/material.dart';
import 'profile.dart';
import 'addMedication.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(),
              const SizedBox(height: 25),

              _dateSelector(),
              const SizedBox(height: 30),

              _sectionTitle("Taken"),
              const SizedBox(height: 12),
              _medicineRow(["8:00", "9:00"]),
              const SizedBox(height: 30),

              _sectionTitle("Scheduled"),
              const SizedBox(height: 12),
              _medicineRow(["10:00", "11:00"]),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: SizedBox(
        height: 65,
        width: 65,
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF007AFF),
          shape: const CircleBorder(),
          elevation: 0,
          highlightElevation: 0,
          focusElevation: 0,
          hoverElevation: 0,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
          onPressed: () {
            Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMedicationStart()),
                      );
          },
        ),
      ),

      bottomNavigationBar: _bottomNavBar(context),
    );
  }

  Widget _headerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Your Medications",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 6),
        Row(
          children: [
            Text(
              "Welcome, ",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            Text(
              "User!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF007AFF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dateChip("Mar 31", false),
        const SizedBox(width: 10),
        _dateChip("Apr 1", true),
        const SizedBox(width: 10),
        _dateChip("Apr 2", false),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  // Date Chip
  Widget _dateChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007AFF) : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // Circle Medication Row
  Widget _medicineRow(List<String> times) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: times.map((time) => _medicineCard(time)).toList(),
    );
  }

  Widget _medicineCard(String time) {
    return Column(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(45),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(time),
        ),
      ],
    );
  }

  // Bottom Navigation Bar
  Widget _bottomNavBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(
            icon: Icons.medication_liquid,
            label: "Medicines",
            active: true,
            onTap: () {},
          ),
          _navItem(
            icon: Icons.person,
            label: "Profile",
            active: false,
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const ProfilePage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? const Color(0xFF007AFF) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFF007AFF) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
