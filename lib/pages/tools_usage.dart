import 'package:flutter/material.dart';

class ToolsUsagePage extends StatelessWidget {
  const ToolsUsagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Mock data for who is using tools
    final List<Map<String, dynamic>> usages = [
      {
        'user': 'Alice',
        'tool': 'Mixeur',
        'icon': '🌪️',
        'status': 'En cours',
        'time': 'depuis 10 min'
      },
      {
        'user': 'Bob',
        'tool': 'Four',
        'icon': '🔥',
        'status': 'Réservé',
        'time': 'à 19:00'
      },
      {
        'user': 'Charlie',
        'tool': 'Balance',
        'icon': '⚖️',
        'status': 'Libre',
        'time': 'maintenant'
      },
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Ustensiles',
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
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final usage = usages[index];
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
                        child: Text(usage['icon'], style: const TextStyle(fontSize: 24)),
                      ),
                      title: Text(
                        usage['tool'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                      subtitle: Text(
                        'Utilisé par ${usage['user']}',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            usage['status'],
                            style: TextStyle(
                              color: usage['status'] == 'En cours' ? Colors.orange : colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            usage['time'],
                            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant, fontFamily: 'Poppins'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: usages.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
