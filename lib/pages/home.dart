import 'package:flutter/material.dart';
import '../requests.dart';
import '../config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _plates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPlates();
  }

  Future<void> _fetchPlates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await fetchWithHeaders('${Config.apiBaseUrl}/plates/');
      if (data is Map<String, dynamic>) {
        if (data['success'] == true) {
          setState(() => _plates = data['plates'] ?? []);
        } else {
          setState(() => _errorMessage = data['message'] ?? 'Failed to load plates');
        }
      } else if (data is List) {
        // Some backends may directly return a list
        setState(() => _plates = data);
      } else {
        setState(() => _errorMessage = 'Unexpected response format');
      }
    } catch (e) {
      // In case there is no API yet, show some placeholder data, but we still capture the error
      setState(() {
        _errorMessage = 'Could not connect to API. Showing offline mockup.';
        _plates = [
          {'id': 1, 'name': 'Pâtes Carbonara', 'date': '2026-03-14', 'image': '🍝'},
          {'id': 2, 'name': 'Salade César', 'date': '2026-03-15', 'image': '🥗'},
          {'id': 3, 'name': 'Steak Frites', 'date': '2026-03-16', 'image': '🥩'}
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchPlates,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 30.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                      title: Text(
                        'Plats prévus',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontFamily: 'Unbounded',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Container(color: colorScheme.surface),
                    ),
                  ),
                  if (_errorMessage != null && _plates.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
                                const SizedBox(width: 12),
                                Expanded(child: Text(_errorMessage!, style: TextStyle(color: colorScheme.onErrorContainer))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_plates.isEmpty && _errorMessage == null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restaurant_outlined, size: 64, color: colorScheme.outlineVariant),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun plat de prévu.\nAppuyez sur le + pour en ajouter un !',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16, fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final plate = _plates[index];
                          return Card(
                            elevation: 0,
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  plate['image'] ?? '🍽️',
                                  style: const TextStyle(fontSize: 28),
                                ),
                              ),
                              title: Text(
                                plate['name'] ?? 'Plat inconnu',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins', fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Prévu pour le ${plate['date'] ?? 'Bientôt'}',
                                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontFamily: 'Poppins'),
                                ),
                              ),
                              trailing: IconButton.filledTonal(
                                icon: const Icon(Icons.check_circle_outline),
                                onPressed: () {
                                  // Action to mark as done
                                },
                              ),
                            ),
                          );
                        },
                        childCount: _plates.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Space for FAB
                  )
                ],
              ),
            ),
    );
  }
}
