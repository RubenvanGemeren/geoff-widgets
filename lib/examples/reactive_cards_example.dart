import 'package:flutter/material.dart';
import '../core/widgets/reactive_card_field.dart';

/// Example usage of ReactiveCardField
class ReactiveCardsExample extends StatelessWidget {
  const ReactiveCardsExample({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(8, (index) => {
      'id': index,
      'title': 'Card ${index + 1}',
      'color': Colors.primaries[index % Colors.primaries.length],
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Physics Cards Example'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ReactiveCardField<Map<String, dynamic>>(
        items: items,
        cardSize: const Size(140, 100),
        padding: const EdgeInsets.all(16),
        seedLayout: ReactiveSeedLayout.grid,
        stiffness: 380.0,
        damping: 22.0,
        repulsion: 9000.0,
        maxSpeed: 2400.0,
        onTapItem: (item) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tapped: ${item['title']}')),
          );
        },
        builder: (context, item, isActive) => _ExampleCard(
          title: item['title'] as String,
          color: item['color'] as Color,
          isActive: isActive,
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isActive;

  const _ExampleCard({
    required this.title,
    required this.color,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isActive ? 12 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive ? color : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
