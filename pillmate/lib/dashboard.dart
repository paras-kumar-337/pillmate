import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "PillMate Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // TOP CARD - NEXT MEDICINE
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Row(
                  children: [
                    const Icon(Icons.alarm, size: 40, color: Colors.teal),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Next Medicine",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Paracetamol – 2:00 PM",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // QUICK ACTIONS
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionCard(Icons.add_circle, "Add Medicine", Colors.teal,
                    () {
                  // TODO: Navigate to add medicine screen
                }),

                _buildActionCard(Icons.history, "History", Colors.blue, () {
                  // TODO: Navigate to history screen
                }),

                _buildActionCard(Icons.list_alt, "My Medicines", Colors.orange,
                    () {
                  // TODO: Navigate to list screen
                }),
              ],
            ),

            const SizedBox(height: 30),

            // TODAY'S MEDICINES LIST
            const Text(
              "Today's Medicines",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildMedicineTile("Vitamin D", "9:00 AM"),
            _buildMedicineTile("Paracetamol", "2:00 PM"),
            _buildMedicineTile("Cough Syrup", "9:00 PM"),
          ],
        ),
      ),
    );
  }

  // QUICK ACTION BUTTON COMPONENT
  Widget _buildActionCard(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 28,
            child: Icon(icon, size: 30, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(title)
        ],
      ),
    );
  }

  // MEDICINE LIST TILE COMPONENT
  Widget _buildMedicineTile(String medName, String medTime) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.medication, color: Colors.teal),
        title: Text(
          medName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Time: $medTime"),
        trailing:
            const Icon(Icons.check_circle_outline, color: Colors.grey),
      ),
    );
  }
}
