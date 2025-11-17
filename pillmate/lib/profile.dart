import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // PROFILE PHOTO + NAME
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "User Name",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "user@email.com",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // SETTINGS / PROFILE OPTIONS
            _buildOptionTile(
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {
                // TODO: Navigate to Edit Profile Page
              },
            ),

            _buildOptionTile(
              icon: Icons.notifications_active_outlined,
              title: "Notification Settings",
              onTap: () {},
            ),

            _buildOptionTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: () {},
            ),

            _buildOptionTile(
              icon: Icons.history,
              title: "Medicine History",
              onTap: () {},
            ),

            _buildOptionTile(
              icon: Icons.info_outline,
              title: "About PillMate",
              onTap: () {},
            ),

            _buildOptionTile(
              icon: Icons.logout,
              title: "Logout",
              iconColor: Colors.red,
              onTap: () {
                // TODO: Logout logic
              },
            ),
          ],
        ),
      ),
    );
  }

  // OPTION TILE COMPONENT
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.teal,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
