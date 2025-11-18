import 'package:flutter/material.dart';
import 'profile.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../database/db_helper.dart';
import '../services/notification_service.dart';
import 'dashboard.dart';

class Medicine {
  int? id;
  String name;
  String type;
  String strength;
  String? imagePath;
  String schedule;
  String dosageFrequency;
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  bool reminders;
  DateTime? lastTakenDate;

  Medicine({
    this.id,
    this.name = '',
    this.type = 'Tablet',
    this.strength = '500 mg',
    this.imagePath,
    this.schedule = 'Every day',
    this.dosageFrequency = 'Once a day',
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
    this.reminders = true,
    this.lastTakenDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'strength': strength,
        'imagePath': imagePath,
        'schedule': schedule,
        'dosageFrequency': dosageFrequency,
        'startDate': startDate?.toIso8601String(),
        'startTime': startTime != null ? '${startTime!.hour}:${startTime!.minute}' : null,
        'endDate': endDate?.toIso8601String(),
        'endTime': endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'reminders': reminders ? 1 : 0,
        'lastTakenDate': lastTakenDate?.toIso8601String(),
      };

  factory Medicine.fromMap(Map<String, dynamic> m) {
    TimeOfDay? parseTime(String? s) {
      if (s == null) return null;
      final parts = s.split(':');
      if (parts.length != 2) return null;
      final h = int.tryParse(parts[0]) ?? 0;
      final mm = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: h, minute: mm);
    }

    return Medicine(
      id: m['id'] as int?,
      name: m['name'] as String? ?? '',
      type: m['type'] as String? ?? 'Tablet',
      strength: m['strength'] as String? ?? '500 mg',
      imagePath: m['imagePath'] as String?,
      schedule: m['schedule'] as String? ?? 'Every day',
      dosageFrequency: m['dosageFrequency'] as String? ?? 'Once a day',
      startDate: m['startDate'] != null ? DateTime.parse(m['startDate'] as String) : null,
      startTime: parseTime(m['startTime'] as String?),
      endDate: m['endDate'] != null ? DateTime.parse(m['endDate'] as String) : null,
      endTime: parseTime(m['endTime'] as String?),
      reminders: (m['reminders'] ?? 0) == 1,
      lastTakenDate: m['lastTakenDate'] != null ? DateTime.parse(m['lastTakenDate']) : null,
    );
  }
}

class PopularMedicine {
  final String name;
  final String type;
  final String strength;

  PopularMedicine({required this.name, required this.type, required this.strength});
}

class AddMedicationStart extends StatelessWidget {
  const AddMedicationStart({super.key});

  @override
  Widget build(BuildContext context) {
    return AddMedPage1(medicine: Medicine());
  }
}

class AddMedPage1 extends StatefulWidget {
  final Medicine medicine;
  const AddMedPage1({super.key, required this.medicine});

  @override
  State<AddMedPage1> createState() => _AddMedPage1State();
}

class _AddMedPage1State extends State<AddMedPage1> {
  final _searchController = TextEditingController();
  List<PopularMedicine> _filteredMeds = [];

  final List<PopularMedicine> popularMeds = [
    PopularMedicine(name: 'Paracetamol', type: 'Tablet', strength: '500 mg'),
    PopularMedicine(name: 'Ibuprofen', type: 'Tablet', strength: '200 mg'),
    PopularMedicine(name: 'Aspirin', type: 'Tablet', strength: '100 mg'),
    PopularMedicine(name: 'Amoxicillin', type: 'Capsule', strength: '250 mg'),
    PopularMedicine(name: 'Metformin', type: 'Tablet', strength: '1000 mg'),
    PopularMedicine(name: 'Atorvastatin', type: 'Tablet', strength: '20 mg'),
  ];

  @override
  void initState() {
    super.initState();
    _filteredMeds = popularMeds;
    _searchController.addListener(_filterMeds);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMeds);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMeds() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMeds = popularMeds.where((med) {
        return med.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onPopularMedTapped(BuildContext context, PopularMedicine popularMed) {
    final newMedicine = Medicine(
      name: popularMed.name,
      type: popularMed.type,
      strength: popularMed.strength,
      reminders: true,
      schedule: 'Every day',
      dosageFrequency: 'Once a day',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedPage4(medicine: newMedicine),
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
  
                  IconButton(
                    icon: const Icon(Icons.close, size: 28, color: Colors.black),
                    onPressed: () => Navigator.popUntil(
                        context, ModalRoute.withName(DashboardScreen.routeName)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF007AFF)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search Medicine',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Popular Medicines",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _filteredMeds.length,
                  itemBuilder: (context, index) {
                    final med = _filteredMeds[index];
                    return GestureDetector(
                      onTap: () => _onPopularMedTapped(context, med),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                med.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16, 
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${med.type}, ${med.strength}',
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMedPage2(medicine: widget.medicine),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Add Custom Medicine',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a medicine name'),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }

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
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    (MediaQuery.of(context).padding.vertical + 36), 
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Add New Medicine",
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 28, color: Colors.black),
                            onPressed: () => Navigator.popUntil(
                                context, ModalRoute.withName(DashboardScreen.routeName)),
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
                            icon: const Icon(Icons.clear, color: Color(0xFF007AFF)),
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
                    ],
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                    child: Center(
                      child: TextButton(
                        onPressed: _next,
                        style: TextButton.styleFrom(
                          backgroundColor: Color(0xFF007AFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _simpleBottomNav(context),
    );
  }
}

class AddMedPage3 extends StatefulWidget {
  final Medicine medicine;
  const AddMedPage3({super.key, required this.medicine});

  @override
  State<AddMedPage3> createState() => _AddMedPage3State();
}

class _AddMedPage3State extends State<AddMedPage3> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        widget.medicine.imagePath = pickedFile.path;
      });
    }
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
                    widget.medicine.name.isEmpty ? 'Medicine' : widget.medicine.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 28, color: Colors.black),
                    onPressed: () => Navigator.popUntil(
                        context, ModalRoute.withName(DashboardScreen.routeName)),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const Text(
                'Choose Look',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 150),
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
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageFile == null
                      ? const Icon(Icons.medication_liquid, size: 60, color: Colors.grey)
                      : null,
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Column(
                  children: [
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text(
                        'Choose from Gallery',
                        style: TextStyle(color: Color(0xFF007AFF), fontWeight: FontWeight.bold),
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
                        builder: (context) => AddMedPage4(medicine: widget.medicine),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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
    if (d == null) return;
    
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: widget.medicine.startTime ?? TimeOfDay.now(),
    );
    if (t == null) return;
    
    setState(() {
      widget.medicine.startDate = d;
      widget.medicine.startTime = t;
    });
  }

  Future<void> _pickEndDate() async {
    final DateTime today = DateTime.now();
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: widget.medicine.endDate ?? today,
      firstDate: today,
      lastDate: DateTime(2100),
    );
    if (d == null) return;

    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: widget.medicine.endTime ?? TimeOfDay.now(),
    );
    if (t == null) return;
    
    setState(() {
      widget.medicine.endDate = d;
      widget.medicine.endTime = t;
    });
  }

  void _next() {
    widget.medicine.schedule = _schedule;
    widget.medicine.dosageFrequency = _dosage;
    widget.medicine.reminders = _reminders;

    if (_reminders && widget.medicine.startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a start time for the reminder'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
                    onPressed: () => Navigator.popUntil(
                        context, ModalRoute.withName(DashboardScreen.routeName)),
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
                      backgroundColor: Color(0xFF007AFF),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                      backgroundColor: Color(0xFF007AFF),
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
                    backgroundColor: Color(0xFF007AFF),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
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

class AddMedPage5 extends StatefulWidget {
  final Medicine medicine;
  const AddMedPage5({super.key, required this.medicine});

  @override
  State<AddMedPage5> createState() => _AddMedPage5State();
}

class _AddMedPage5State extends State<AddMedPage5> {
  final DBHelper _db = DBHelper();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  Future<void> _saveMedicine() async {
    setState(() => _isLoading = true);
    
    final newId = await _db.insertMedicine(widget.medicine.toMap());

    if (widget.medicine.reminders) {
      await _notificationService.scheduleMedicineReminder(widget.medicine, newId);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medicine saved'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.popUntil(
        context, ModalRoute.withName(DashboardScreen.routeName));
  }

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
                  IconButton(
                    icon: const Icon(Icons.close, size: 28, color: Colors.black),
                    onPressed: () => Navigator.popUntil(
                        context, ModalRoute.withName(DashboardScreen.routeName)),
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
                        image: widget.medicine.imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(widget.medicine.imagePath!)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: widget.medicine.imagePath == null
                          ? const Icon(Icons.medication_liquid, size: 40, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      height: 320,
                      padding: const EdgeInsets.all(16),
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
                      child: ListView(
                        children: [
                          _reviewTile('Name:', widget.medicine.name),
                          _reviewTile('Type:', widget.medicine.type),
                          _reviewTile('Strength:', widget.medicine.strength),
                          _reviewTile('Schedule:', widget.medicine.schedule),
                          _reviewTile('Dosage:', widget.medicine.dosageFrequency),
                          _reviewTile('Reminders:', widget.medicine.reminders ? 'On' : 'Off'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedicine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Save'),
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

  Widget _reviewTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

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
          onTap: () => Navigator.popUntil(
              context, ModalRoute.withName(DashboardScreen.routeName)),
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