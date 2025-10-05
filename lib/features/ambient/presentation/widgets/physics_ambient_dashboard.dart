import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/reactive_card_field.dart';

class PhysicsAmbientDashboard extends StatefulWidget {
  const PhysicsAmbientDashboard({super.key});

  @override
  State<PhysicsAmbientDashboard> createState() => _PhysicsAmbientDashboardState();
}

class _PhysicsAmbientDashboardState extends State<PhysicsAmbientDashboard> {
  final List<Map<String, dynamic>> _cards = [
    {
      'title': 'Weather',
      'icon': Icons.wb_sunny,
      'color': Colors.blue,
      'id': 0,
    },
    {
      'title': 'Time',
      'icon': Icons.access_time,
      'color': Colors.green,
      'id': 1,
    },
    {
      'title': 'Calendar',
      'icon': Icons.calendar_today,
      'color': Colors.orange,
      'id': 2,
    },
    {
      'title': 'Notes',
      'icon': Icons.note,
      'color': Colors.purple,
      'id': 3,
    },
    {
      'title': 'Music',
      'icon': Icons.music_note,
      'color': Colors.red,
      'id': 4,
    },
    {
      'title': 'Settings',
      'icon': Icons.settings,
      'color': Colors.grey,
      'id': 5,
    },
  ];

  void _onCardTap(Map<String, dynamic> card) {
    // Add haptic feedback
    HapticFeedback.lightImpact();

    // You can add your existing card tap logic here
    print('Tapped card: ${card['title']}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ReactiveCardField<Map<String, dynamic>>(
        items: _cards,
        cardSize: const Size(120, 80),
        padding: const EdgeInsets.all(24.0),
        seedLayout: ReactiveSeedLayout.grid,
        stiffness: 380.0,
        damping: 22.0,
        repulsion: 9000.0,
        maxSpeed: 2400.0,
        onTapItem: _onCardTap,
        builder: (context, card, isActive) => _PhysicsCard(
          title: card['title'] as String,
          icon: card['icon'] as IconData,
          color: card['color'] as Color,
          isActive: isActive,
        ),
      ),
    );
  }
}

class _PhysicsCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _PhysicsCard({
    required this.title,
    required this.icon,
    required this.color,
    this.isActive = false,
  });

  @override
  State<_PhysicsCard> createState() => _PhysicsCardState();
}

class _PhysicsCardState extends State<_PhysicsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _elevationAnimation = Tween<double>(
      begin: 4.0,
      end: 12.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onHoverEnter() {
    if (!widget.isActive) {
      _animationController.forward();
    }
  }

  void _onHoverExit() {
    if (!widget.isActive) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverEnter(),
      onExit: (_) => _onHoverExit(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isActive ? 1.03 : _scaleAnimation.value,
            child: Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: widget.isActive ? 20.0 : _elevationAnimation.value,
                    offset: Offset(0, widget.isActive ? 10.0 : _elevationAnimation.value / 2),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Colored corner
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.icon,
                          size: 24,
                          color: widget.color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
