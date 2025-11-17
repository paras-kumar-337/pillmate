import 'package:flutter/material.dart';
import 'package:pillmate/Dashboard.dart';
import 'profile.dart';

class Medicine {
  String name;
  String type;
  String strength;
  String look; // placeholder, e.g. asset path or description
  String schedule;
  String dosageFrequency;
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  bool reminders;

  Medicine({
    this.name = '',
    this.type = 'Tablet',
    this.strength = '500 mg',
    this.look = '',
    this.schedule = 'Every day',
    this.dosageFrequency = 'Once a day',
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.reminders = true,
  });
}

/// ENTRY POINT WIDGET: launch this from your Dashboard FAB
class AddMedicationStart extends StatelessWidget {
  const AddMedicationStart({super.key});

  @override
  Widget build(BuildContext context) {
    return AddMedPage1(medicine: Medicine());
  }
}

/// Page 1: Search + big card + Add Custom
class AddMedPage1 extends StatelessWidget {
  final Medicine medicine;
  const AddMedPage1({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add New Medicine",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  // X button
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search Medicine',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: Colors.grey),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Voice input not implemented'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Big rounded card
              Expanded(
                child: Center(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    height: 320,
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMedPage2(medicine: medicine),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Color(0xFF007AFF)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _simpleBottomNav(context),
    );
  }
}

/// Page 2: Name / Type / Strength
class AddMedPage2 extends StatefulWidget {
  final Medicine medicine;
  const AddMedPage2({super.key, required this.medicine});

  @override
  State<AddMedPage2> createState() => _AddMedPage2State();
}

class _AddMedPage2State extends State<AddMedPage2> {
  late TextEditingController _nameCtrl;
  String _selectedType = 'Tablet';
  String _selectedStrength = '500 mg';
  final List<String> types = ['Tablet', 'Capsule', 'Syrup', 'Inhaler'];
  final List<String> strengths = ['250 mg', '500 mg', '650 mg', '1000 mg'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.medicine.name);
    _selectedType = widget.medicine.type;
    _selectedStrength = widget.medicine.strength;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    widget.medicine.name = _nameCtrl.text.trim();
    widget.medicine.type = _selectedType;
    widget.medicine.strength = _selectedStrength;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedPage3(medicine: widget.medicine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add New Medicine",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  // X button
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),

              const Text(
                'Medicine Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: 'Paracetamol',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _nameCtrl.clear(),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Text(
                'Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                items: types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedType = v ?? _selectedType),
                decoration: const InputDecoration(border: InputBorder.none),
              ),

              const SizedBox(height: 20),
              const Text(
                'Strength',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedStrength,
                items: strengths
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedStrength = v ?? _selectedStrength),
                decoration: const InputDecoration(border: InputBorder.none),
              ),

              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: _next,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Color(0xFF007AFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _simpleBottomNav(context),
    );
  }
}

/// Page 3: Choose look (gallery/recents)
class AddMedPage3 extends StatelessWidget {
  final Medicine medicine;
  const AddMedPage3({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    medicine.name.isEmpty ? 'Medicine' : medicine.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // X button
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose Look',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gallery chooser not implemented'),
                          ),
                        );
                      },
                      child: const Text(
                        'Choose from Gallery',
                        style: TextStyle(color: Color(0xFF007AFF)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Recents chooser not implemented'),
                          ),
                        );
                      },
                      child: const Text(
                        'Choose Recents',
                        style: TextStyle(color: Color(0xFF007AFF)),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMedPage4(medicine: medicine),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Color(0xFF007AFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _simpleBottomNav(context),
    );
  }
}

/// Page 4: Schedule, dosage, date/time, reminders
class AddMedPage4 extends StatefulWidget {
  final Medicine medicine;
  const AddMedPage4({super.key, required this.medicine});

  @override
  State<AddMedPage4> createState() => _AddMedPage4State();
}

class _AddMedPage4State extends State<AddMedPage4> {
  String _schedule = 'Every day';
  String _dosage = 'Once a day';
  final List<String> schedules = ['Every day', 'Weekdays', 'Custom'];
  final List<String> dosages = ['Once a day', 'Twice a day', 'Thrice a day'];
  bool _reminders = true;

  @override
  void initState() {
    super.initState();
    _schedule = widget.medicine.schedule;
    _dosage = widget.medicine.dosageFrequency;
    _reminders = widget.medicine.reminders;
  }

  Future<void> _pickStartDate() async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: widget.medicine.startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      final TimeOfDay? t = await showTimePicker(
        context: context,
        initialTime: widget.medicine.startTime ?? TimeOfDay.now(),
      );
      setState(() {
        widget.medicine.startDate = d;
        widget.medicine.startTime = t;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime today = DateTime.now();
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: widget.medicine.endDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (d != null) {
      final TimeOfDay? t = await showTimePicker(
        context: context,
        initialTime: widget.medicine.endTime ?? TimeOfDay.now(),
      );
      setState(() {
        widget.medicine.endDate = d;
        widget.medicine.endTime = t;
      });
    }
  }

  void _next() {
    widget.medicine.schedule = _schedule;
    widget.medicine.dosageFrequency = _dosage;
    widget.medicine.reminders = _reminders;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedPage5(medicine: widget.medicine),
      ),
    );
  }

  String _prettyDate(DateTime? d) {
    if (d == null) return 'Date';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _prettyTime(TimeOfDay? t) {
    if (t == null) return 'and time';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.medicine.name.isEmpty
                        ? 'Medicine'
                        : widget.medicine.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              const Text(
                'Set Schedule',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _schedule,
                items: schedules
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _schedule = v ?? _schedule),
                decoration: const InputDecoration(border: InputBorder.none),
              ),

              const SizedBox(height: 20),
              const Text(
                'Set Dosage',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _dosage,
                items: dosages
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _dosage = v ?? _dosage),
                decoration: const InputDecoration(border: InputBorder.none),
              ),

              const SizedBox(height: 20),
              const Text(
                'Set Start and End Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Column(
                children: [
                  ElevatedButton(
                    onPressed: _pickStartDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'Start: ${_prettyDate(widget.medicine.startDate)} ${_prettyTime(widget.medicine.startTime)}',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickEndDate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    child: Text(
                      'End: ${_prettyDate(widget.medicine.endDate)} ${_prettyTime(widget.medicine.endTime)}',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                'Set Reminders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Switch.adaptive(
                    value: _reminders,
                    onChanged: (v) => setState(() => _reminders = v),
                    activeColor: Color(0xFF007AFF),
                  ),
                  const SizedBox(width: 8),
                  Text(_reminders ? 'On' : 'Off'),
                ],
              ),

              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: _next,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Color(0xFF007AFF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _simpleBottomNav(context),
    );
  }
}

/// Page 5: Review & Save
class AddMedPage5 extends StatelessWidget {
  final Medicine medicine;
  const AddMedPage5({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Review & Save",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  // X button
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 28,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      height: 320,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medicine saved')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _simpleBottomNav(context),
    );
  }
}

/// Common bottom nav used on all pages
Widget _simpleBottomNav(BuildContext context) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(40),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.medication_liquid, color: Color(0xFF007AFF)),
              Text(
                'Medicines',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.person, color: Colors.grey),
              Text('Profile', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );
}
