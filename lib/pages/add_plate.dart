import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddPlatePage extends StatefulWidget {
  const AddPlatePage({super.key});

  @override
  _AddPlatePageState createState() => _AddPlatePageState();
}

class _AddPlatePageState extends State<AddPlatePage> {
  final _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedMoment = 'Midi';
  int _personCount = 2;
  final List<String> _selectedTools = [];

  final List<String> _moments = ['Matin', 'Midi', 'Goûter', 'Soir'];
  final List<Map<String, String>> _availableTools = [
    {'name': 'Casserole', 'icon': '🍳'},
    {'name': 'Poêle', 'icon': '🥘'},
    {'name': 'Four', 'icon': '🔥'},
    {'name': 'Mixeur', 'icon': '🌪️'},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _savePlate() {
    // API logic will go here
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Plat', style: TextStyle(fontFamily: 'Unbounded', fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Détails du repas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Unbounded', color: colorScheme.primary)),
            const SizedBox(height: 24),
            
            // Name
            TextField(
              controller: _nameController,
              style: const TextStyle(fontFamily: 'Poppins'),
              decoration: InputDecoration(
                labelText: 'Nom du plat',
                hintText: 'ex: Pâtes Carbonara',
                prefixIcon: const Icon(Icons.restaurant),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),

            // Date & Moment
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate), style: const TextStyle(fontFamily: 'Poppins')),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMoment,
                    decoration: InputDecoration(
                      labelText: 'Moment',
                      prefixIcon: const Icon(Icons.access_time),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    items: _moments.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) => setState(() => _selectedMoment = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Persons
            Text('Pour combien de personnes ?', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton.filledTonal(onPressed: () => setState(() => _personCount > 1 ? _personCount-- : null), icon: const Icon(Icons.remove)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('$_personCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                IconButton.filledTonal(onPressed: () => setState(() => _personCount++), icon: const Icon(Icons.add)),
                const Spacer(),
                const Icon(Icons.people_outline, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 24),

            // Tools
            Text('Ustensiles nécessaires', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _availableTools.map((tool) {
                final isSelected = _selectedTools.contains(tool['name']);
                return FilterChip(
                  label: Text('${tool['icon']} ${tool['name']}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTools.add(tool['name']!);
                      } else {
                        _selectedTools.remove(tool['name']);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _savePlate,
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Planifier le repas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
