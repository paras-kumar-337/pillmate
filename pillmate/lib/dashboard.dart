import 'package:flutter/material.dart';
import 'profile.dart';
import 'addMedication.dart';
import '../database/db_helper.dart';
import 'addMedication.dart' show Medicine; // Import the updated model
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class DashboardScreen extends StatefulWidget {
  static const String routeName = '/dashboard';
  
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DBHelper _db = DBHelper();
  final NotificationService _notificationService = NotificationService();
  
  String _userName = "User";
  // This will be set to today's date at midnight
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  List<Medicine> _allMeds = [];
  List<Medicine> _takenMeds = [];
  List<Medicine> _scheduledMeds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // --- Helper function to check if two DateTimes are on the same day ---
  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _loadAllData() async {
    await _notificationService.init();
    await _loadUserData();
    await _loadMedicines();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString("user_name") ?? "User";
      });
    }
  }

  Future<void> _loadMedicines() async {
    if (mounted) setState(() => _isLoading = true);
    
    final data = await _db.getMedicines();
    // This now uses the new Medicine.fromMap with lastTakenDate
    _allMeds = data.map((item) => Medicine.fromMap(item)).toList();
    
    _filterMeds(); 
    
    if (mounted) setState(() => _isLoading = false);
  }

  // --- THIS IS THE CORE LOGIC FIX ---
  void _filterMeds() {
    // 1. Filter all meds to get only meds for the _selectedDate
    final List<Medicine> todaysMeds = _allMeds.where((med) {
      if (med.startDate == null) return false; 

      // 1. Check if start date is after the selected date
      if (_selectedDate.isBefore(med.startDate!) &&
          !_isSameDay(_selectedDate, med.startDate)) {
        return false;
      }

      // 2. Check if end date is before the selected date
      if (med.endDate != null &&
          _selectedDate.isAfter(med.endDate!) &&
          !_isSameDay(_selectedDate, med.endDate)) {
        return false;
      }

      // 3. Check schedule
      if (med.schedule == 'Weekdays' &&
          (_selectedDate.weekday == DateTime.saturday ||
              _selectedDate.weekday == DateTime.sunday)) {
        return false;
      }
      
      return true;
    }).toList();

    // 2. Filter that list into "taken" and "scheduled"
    // A med is "taken" *only if* its last taken date is the same as the selected date
    _takenMeds = todaysMeds.where((med) => 
        _isSameDay(med.lastTakenDate, _selectedDate)
    ).toList();
    
    // A med is "scheduled" *only if* its last taken date is NOT the same as the selected date
    _scheduledMeds = todaysMeds.where((med) => 
        !_isSameDay(med.lastTakenDate, _selectedDate)
    ).toList();
  }
  // --- END OF LOGIC FIX ---


  // --- UPDATED THIS FUNCTION ---
  Future<void> _markAsTaken(Medicine med) async {
    if (med.id == null) return;
    
    // Set the last taken date to the *selected date*
    await _db.updateMedicineLastTaken(med.id!, _selectedDate);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${med.name} marked as taken."),
        backgroundColor: Colors.green,
      ),
    );
    
    _loadMedicines(); // This re-fetches and re-filters
  }

  // --- ADDED NEW FUNCTION ---
  Future<void> _markAsUntaken(Medicine med) async {
    if (med.id == null) return;
    
    // Set the last taken date to null
    await _db.updateMedicineLastTaken(med.id!, null);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${med.name} marked as not taken."),
        backgroundColor: Colors.blueGrey,
      ),
    );
    
    _loadMedicines();
  }
  // --- END OF NEW FUNCTION ---

  Future<void> _deleteMedicine(Medicine med) async {
    if (med.id == null) return;
    await _db.deleteMedicine(med.id!);
    await _notificationService.cancelReminder(med.id!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${med.name} has been removed."),
        backgroundColor: Colors.red,
      ),
    );
    _loadMedicines();
  }

  Future<void> _showDeleteDialog(Medicine med) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Medicine?'),
          content: Text('Are you sure you want to remove ${med.name}?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
              onPressed: () {
                _deleteMedicine(med);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
              _headerSection(_userName),
              const SizedBox(height: 25),
              _dateSelector(),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _scheduledMeds.isEmpty && _takenMeds.isEmpty
                      ? _emptyState()
                      : _medicineLists(),
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
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMedicationStart()),
            );
            _loadMedicines();
          },
        ),
      ),
      bottomNavigationBar: _bottomNavBar(context),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 50.0),
        child: Text(
          "No scheduled medications for this day.",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _medicineLists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Taken"),
        const SizedBox(height: 12),
        _medicineRow(_takenMeds, isTakenList: true),
        const SizedBox(height: 30),
        _sectionTitle("Scheduled"),
        const SizedBox(height: 12),
        _medicineRow(_scheduledMeds, isTakenList: false),
      ],
    );
  }

  Widget _headerSection(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Your Medications",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Text(
              "Welcome, ",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            Text(
              "$name!",
              style: const TextStyle(
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
    // These dates are now final and based on the *actual* current time
    final DateTime today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime tomorrow = today.add(const Duration(days: 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Yesterday Chip
        GestureDetector(
          onTap: () => setState(() {
            _selectedDate = yesterday;
            _filterMeds();
          }),
          child: _dateChip(
            DateFormat('MMM d').format(yesterday),
            "Yesterday",
            _isSameDay(_selectedDate, yesterday),
          ),
        ),
        const SizedBox(width: 10),
        
        // Today Chip
        GestureDetector(
          onTap: () => setState(() {
            _selectedDate = today;
            _filterMeds();
          }),
          child: _dateChip(
            DateFormat('MMM d').format(today),
            "Today",
            _isSameDay(_selectedDate, today),
          ),
        ),
        const SizedBox(width: 10),
        
        // Tomorrow Chip
        GestureDetector(
          onTap: () => setState(() {
            _selectedDate = tomorrow;
            _filterMeds();
          }),
          child: _dateChip(
            DateFormat('MMM d').format(tomorrow),
            "Tomorrow",
            _isSameDay(_selectedDate, tomorrow),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _dateChip(String date, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF007AFF) : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          Text(
            date,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicineRow(List<Medicine> meds, {bool isTakenList = false}) {
    if (meds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Center(
          child: Text(
            isTakenList ? "No medicines taken yet." : "No medicines scheduled.",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
            meds.map((med) => _medicineCard(med, isTakenList: isTakenList)).toList(),
      ),
    );
  }

  Widget _medicineCard(Medicine med, {bool isTakenList = false}) {
    String time = "Anytime";
    if (med.startTime != null) {
      final h = med.startTime!.hourOfPeriod == 0 ? 12 : med.startTime!.hourOfPeriod;
      final m = med.startTime!.minute.toString().padLeft(2, '0');
      final ampm = med.startTime!.period == DayPeriod.am ? 'AM' : 'PM';
      time = "$h:$m $ampm";
    }

    return GestureDetector(
      onLongPress: () {
        _showDeleteDialog(med);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
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
                image: (med.imagePath != null && File(med.imagePath!).existsSync())
                    ? DecorationImage(
                        image: FileImage(File(med.imagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (med.imagePath == null || !File(med.imagePath!).existsSync())
                  ? const Icon(Icons.medication,
                      size: 45, color: Color(0xFF007AFF))
                  : null,
            ),
            const SizedBox(height: 10),
            Text(
              med.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(time),
            ),
            
            // --- UPDATED BUTTON LOGIC ---
            if (!isTakenList)
              // Show "Take" button
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: () => _markAsTaken(med),
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF007AFF).withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Take",
                    style: TextStyle(
                        color: Color(0xFF007AFF), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            
            if (isTakenList)
              // Show "Undo" button
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextButton(
                  onPressed: () => _markAsUntaken(med),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "Undo",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            // --- END OF BUTTON LOGIC ---
          ],
        ),
      ),
    );
  }

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