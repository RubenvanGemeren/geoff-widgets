import 'package:flutter/material.dart';
import '../core/widgets/reactive_card_field.dart';

/// Test page to verify enlarge/shrink functionality
class EnlargeTest extends StatelessWidget {
  const EnlargeTest({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(8, (index) => {
      'id': index,
      'title': 'Card ${index + 1}',
      'color': Colors.primaries[index % Colors.primaries.length],
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enlarge Test'),
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
                  'Enlarge Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Tap a card to enlarge it (anchored at bottom-right)'),
                Text('• Tap background to shrink all cards'),
                Text('• Other cards should be pushed away naturally'),
                Text('• Drag works for both normal and enlarged cards'),
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
              enlargedScale: 1.8, // Make it more obvious
              singleEnlargedAtOnce: true,
              sizeAnimApprox: const Duration(milliseconds: 200),
              onTapItem: (item) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tapped: ${item['title']}')),
                );
              },
              builder: (context, item, isActive) => _EnlargeTestCard(
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

class _EnlargeTestCard extends StatelessWidget {
  final String title;
  final Color color;
  final bool isActive;

  const _EnlargeTestCard({
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
          width: isActive ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isActive ? 0.2 : 0.1),
            blurRadius: isActive ? 12 : 4,
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
              isActive ? Icons.zoom_in : Icons.touch_app,
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
          if (isActive)
            const Text(
              'ENLARGED - DRAGGABLE',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}
