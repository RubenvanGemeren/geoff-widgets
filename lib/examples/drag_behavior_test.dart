import 'package:flutter/material.dart';
import '../core/widgets/reactive_card_field.dart';

/// Test page to verify improved drag behavior
class DragBehaviorTest extends StatelessWidget {
  const DragBehaviorTest({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(12, (index) => {
      'id': index,
      'title': 'Card ${index + 1}',
      'color': Colors.primaries[index % Colors.primaries.length],
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag Behavior Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Drag Behavior Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Drag cards - they should stick to your finger'),
                Text('• Release with momentum - cards should continue moving'),
                Text('• Other cards should react and move away'),
                Text('• Cards should stay within bounds'),
              ],
            ),
          ),
          // Physics field
          Expanded(
            child: ReactiveCardField<Map<String, dynamic>>(
              items: items,
              cardSize: const Size(100, 80),
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
              builder: (context, item, isActive) => _TestCard(
                title: item['title'] as String,
                color: item['color'] as Color,
                isActive: isActive,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TestCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isActive;

  const _TestCard({
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
        border: Border.all(
          color: isActive ? color : Colors.grey.shade300,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: isActive ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.touch_app,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? color : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
