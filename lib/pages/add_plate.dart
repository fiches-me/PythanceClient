import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../requests.dart';

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

  bool _isSubmitting = false;

  Future<void> _savePlate() async {
    final name = _nameController.text.trim();

    // Basic validations
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nom du plat est requis')));
      return;
    }

    final today = DateTime.now();
    final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (selectedDateOnly.isBefore(todayOnly)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La date sélectionnée est dans le passé')));
      return;
    }

    if (_personCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le nombre de personnes doit être au moins 2')));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await sendPlate(
        name: name,
        date: _selectedDate,
        moment: _selectedMoment,
        personCount: _personCount,
        tools: _selectedTools,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plat planifié avec succès')));
      Navigator.pop(context, result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'envoi: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouveau Plat', style: TextStyle(fontFamily: 'Unbounded', fontSize: 20, color: colorScheme.primary)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 20),

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
                    initialValue: _selectedMoment,
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
                IconButton.filledTonal(
                    onPressed: _personCount > 2 ? () => setState(() => _personCount--) : null, icon: const Icon(Icons.remove)),
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
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _savePlate,
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Planifier le repas', style: TextStyle(fontFamily: 'Unbounded', fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
