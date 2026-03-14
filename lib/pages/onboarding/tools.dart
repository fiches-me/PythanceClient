import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingToolsPage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onNext;
  const OnboardingToolsPage({super.key, required this.onNext});

  @override
  State<OnboardingToolsPage> createState() => _OnboardingToolsPageState();
}

class _OnboardingToolsPageState extends State<OnboardingToolsPage> {
  final List<Map<String, dynamic>> _availableTools = [
    {'id': 't1', 'name': 'Casserole', 'icon': '🍳', 'description': 'Une casserole basique.'},
    {'id': 't2', 'name': 'Poêle', 'icon': '🥘', 'description': 'Une poêle antiadhésive.'},
    {'id': 't3', 'name': 'Faitout', 'icon': '🍲', 'description': 'Idéal pour les soupes.'},
    {'id': 't4', 'name': 'Mixeur', 'icon': '🌪️', 'description': 'Pour vos smoothies et soupes.'},
    {'id': 't5', 'name': 'Four', 'icon': 'assets/icon/logo.svg', 'description': 'Un four classique.'},
    {'id': 't6', 'name': 'Balance', 'icon': '⚖️', 'description': 'Pour peser vos ingrédients.'},
  ];

  final List<Map<String, dynamic>> _userTools = [];

  void _addTool(Map<String, dynamic> tool) {
    setState(() {
      _userTools.add(Map.from(tool));
    });
    Navigator.pop(context); // Close bottom sheet after selection
  }

  void _removeToolAt(int index) {
    setState(() {
      _userTools.removeAt(index);
    });
  }

  // Helper to render either an emoji or an image
  Widget _buildToolIcon(String iconData, {double size = 24, Color? color}) {
    if (iconData.length <= 2) {
      return Text(iconData, style: TextStyle(fontSize: size));
    }
    
    if (iconData.endsWith('.svg')) {
      return SvgPicture.asset(
        iconData,
        width: size,
        height: size,
        colorFilter: color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      );
    }
    
    return Image.asset(
      iconData,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Icon(Icons.kitchen, size: size),
    );
  }

  void _showToolSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Ajouter un ustensile',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Unbounded'),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableTools.length,
                  itemBuilder: (context, index) {
                    final tool = _availableTools[index];
                    return ListTile(
                      leading: _buildToolIcon(tool['icon'], size: 24),
                      title: Text(tool['name'], style: const TextStyle(fontWeight: FontWeight.w500, fontFamily: 'Poppins')),
                      subtitle: Text(tool['description'], style: const TextStyle(fontFamily: 'Poppins')),
                      onTap: () => _addTool(tool),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Cuisine', style: TextStyle(fontFamily: 'Unbounded', fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quels outils\npossédez-vous ?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Unbounded', height: 1.2),
                ),
                const SizedBox(height: 8),
                Text(
                  'Listez vos ustensiles pour adapter vos recettes.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _userTools.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.kitchen_outlined, size: 80, color: colorScheme.outlineVariant),
                        const SizedBox(height: 16),
                        Text(
                          'Votre inventaire est vide',
                          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16, fontFamily: 'Poppins'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _userTools.length,
                    itemBuilder: (context, index) {
                      final tool = _userTools[index];
                      return Card(
                        elevation: 0,
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: _buildToolIcon(tool['icon'], size: 24),
                          title: Text(tool['name'], style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
                          trailing: IconButton(
                            icon: Icon(Icons.remove_circle_outline, color: colorScheme.error),
                            onPressed: () => _removeToolAt(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showToolSelector,
        label: const Text('Ajouter', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        icon: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 80,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _userTools.isEmpty ? null : () => widget.onNext(_userTools),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Confirmer & Terminer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          ),
        ),
      ),
    );
  }
}
