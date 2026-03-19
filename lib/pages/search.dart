import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config.dart';
import '../requests.dart';

enum SearchInputType { text, date }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  SearchInputType _type = SearchInputType.text;

  final TextEditingController _textController = TextEditingController();
  DateTime? _selectedDate;

  bool _loading = false;
  List<dynamic>? _results;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _performSearch() async {
    // validate
    String? value;
    if (_type == SearchInputType.date) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner une date.')),
        );
        return;
      }
      value = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    } else {
      if (_textController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez saisir un texte.')),
        );
        return;
      }
      value = _textController.text.trim();
    }


    setState(() {
      _loading = true;
      _results = null;
    });

    final url = '${Config.apiBaseUrl}/search';
    final body = {
      'type': _type.name,
      'value': value,
    };

    try {
      final resp = await postWithHeaders(url, body, requireAuth: false);
      setState(() {
        _results = resp is List ? resp : [resp];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la recherche : ${e.toString()}')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Recherche', style: TextStyle(fontFamily: 'Unbounded', fontSize: 20),)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search area: either a compact text field (with toggle) or a large
            // primary action button when in date mode.
            Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _type == SearchInputType.text
                        ? Material(
                            key: const ValueKey('textField'),
                            color: colorScheme.surface,
                            elevation: 0,
                            borderRadius: BorderRadius.circular(12),
                            child: TextField(
                              controller: _textController,
                              style: const TextStyle(fontFamily: 'Poppins'),
                              decoration: InputDecoration(
                                hintText: 'Rechercher...',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                prefixIcon: Icon(Icons.search_outlined, color: colorScheme.onSurfaceVariant),
                              ),
                              onSubmitted: (_) {
                                if (!_loading) _performSearch();
                              },
                            ),
                          )
                        : SizedBox(
                            key: const ValueKey('dateBigAction'),
                            height: 56,
                            child: FilledButton(
                              onPressed: () async {
                                // If no date chosen, open picker first
                                if (_selectedDate == null) {
                                  await _pickDate();
                                  return;
                                }
                                if (!_loading) await _performSearch();
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined),
                                      const SizedBox(width: 12),
                                      Text(
                                        _selectedDate != null
                                            ? DateFormat.yMMMMd().format(_selectedDate!)
                                            : 'Sélectionner une date',
                                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.search, size: 20),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                // Toggle button
                Tooltip(
                  message: _type == SearchInputType.text ? 'Basculer en date' : 'Basculer en texte',
                  child: IconButton(
                    style: IconButton.styleFrom(backgroundColor: colorScheme.surface, foregroundColor: colorScheme.onSurface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => setState(() {
                      _type = _type == SearchInputType.text ? SearchInputType.date : SearchInputType.text;
                    }),
                    icon: Icon(_type == SearchInputType.text ? Icons.calendar_today : Icons.text_snippet),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Big search button for text mode. In date mode the large action
            // is placed in the top area to replace the search bar.
            if (_type == SearchInputType.text) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _loading ? null : _performSearch,
                icon: _loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary),
                      )
                    : const Icon(Icons.search),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Text('Lancer la recherche', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],

            const SizedBox(height: 18),

            // Results
            if (_results != null) ...[
              const SizedBox(height: 8),
              Text('Résultats :', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _results!.length,
                  itemBuilder: (context, index) {
                    final item = _results![index];
                    final colorScheme = Theme.of(context).colorScheme;
                    return Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withAlpha(77),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.search, size: 20),
                        ),
                        title: Text(item.toString(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


