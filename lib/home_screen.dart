import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task1/components/text_cont..dart';
import 'dart:convert';

late List<Map<String, String>> branches = [];
late int branchCounter = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController arabicNameController = TextEditingController();
  final TextEditingController englishNameController = TextEditingController();
  final TextEditingController arabicDescriptionController = TextEditingController();
  final TextEditingController englishDescriptionController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  @override
  void dispose() {
    arabicNameController.dispose();
    englishNameController.dispose();
    arabicDescriptionController.dispose();
    englishDescriptionController.dispose();
    noteController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _loadBranches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      branchCounter = prefs.getInt('branchCounter') ?? 0;
      List<String>? branchList = prefs.getStringList('branches');
      if (branchList != null) {
        branches = branchList
            .map((branch) => Map<String, String>.from(jsonDecode(branch)))
            .toList();
      }
    });
    if (branches.isNotEmpty) _loadBranchDetails(currentIndex);
  }

  Future<void> _saveBranches() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('branchCounter', branchCounter);
    await prefs.setStringList('branches', branches.map((branch) => jsonEncode(branch)).toList());
  }

  void _addBranch() {
    setState(() {
      branchCounter++;
      branches.add({
        'id': branchCounter.toString(),
        'arabicName': '',
        'englishName': '',
        'arabicDescription': '',
        'englishDescription': '',
        'note': '',
        'address': '',
      });
      currentIndex = branches.length - 1;
    });
    _saveBranches();
    _clearTextFields();
  }

  Future<void> _saveBranch(int index) async {
    branches[index] = {
      'id': branches[index]['id']!,
      'arabicName': arabicNameController.text,
      'englishName': englishNameController.text,
      'arabicDescription': arabicDescriptionController.text,
      'englishDescription': englishDescriptionController.text,
      'note': noteController.text,
      'address': addressController.text,
    };
    await _saveBranches();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ النص بنجاح!')));
  }

  void _loadBranchDetails(int index) {
    final selectedBranch = branches[index];
    arabicNameController.text = selectedBranch['arabicName']!;
    englishNameController.text = selectedBranch['englishName']!;
    arabicDescriptionController.text = selectedBranch['arabicDescription']!;
    englishDescriptionController.text = selectedBranch['englishDescription']!;
    noteController.text = selectedBranch['note']!;
    addressController.text = selectedBranch['address']!;
  }

  void _clearTextFields() {
    arabicNameController.clear();
    englishNameController.clear();
    arabicDescriptionController.clear();
    englishDescriptionController.clear();
    noteController.clear();
    addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF005EAA),
          toolbarHeight: height * 0.10,
          title: const Text(
            'Branch / Store / Cashier',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.white),
              onPressed: _addBranch,
            ),
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: () async {
                await _saveBranch(currentIndex);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView(
            children: [
              Container(
                height: height * 1.5,
                width: width * 0.6,
                child: Column(
                  children: [
                    _buildBranchSection(),
                    const SizedBox(height: 5),
                    _buildTextFieldSection('Arabic Name', 'مباني المؤسسة', arabicNameController, height, width),
                    _buildTextFieldSection('Arabic Description', 'وصف باللغة العربية', arabicDescriptionController, height, width),
                    _buildTextFieldSection('English Name', 'Company Branches', englishNameController, height, width),
                    _buildTextFieldSection('English Description', '', englishDescriptionController, height, width),
                    _buildTextFieldSection('Note', 'Any notes', noteController, height, width),
                    _buildTextFieldSection('Address', 'KSA', addressController, height, width),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: branches.length >= 2
            ? BottomNavigationBar(
          items: branches.map((branch) {
            return BottomNavigationBarItem(
              label: branch['id'],
              icon: const Icon(Icons.store,color: Color(0xFF005EAA),),
            );
          }).toList(),
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
              _loadBranchDetails(index);
            });
          },
        )
            : null,
      ),
    );
  }

  Widget _buildBranchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Branch', style: TextStyle(fontSize: 15)),
        const SizedBox(height: 8),
        Container(
          height: 40,
          width: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          alignment: Alignment.center,
          child: Text(
            'Branch ${branchCounter}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldSection(String label, String hint, TextEditingController controller, double height, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        CustomContainer(
          height: height * 0.08,
          width: screenWidth * 0.9,
          textFieldLabel: hint,
          inputKey: '',
          controller: controller,
        ),
      ],
    );
  }
}
