import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/reactive_card_field.dart';

class AmbientDashboard extends StatefulWidget {
  const AmbientDashboard({super.key});

  @override
  State<AmbientDashboard> createState() => _AmbientDashboardState();
}

class _AmbientDashboardState extends State<AmbientDashboard>
    with TickerProviderStateMixin {
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
        enlargedScale: 1.6,
        singleEnlargedAtOnce: true,
        sizeAnimApprox: const Duration(milliseconds: 180),
        onTapItem: _onCardTap,
        builder: (context, card, isActive) => _AmbientCard(
          title: card['title'] as String,
          icon: card['icon'] as IconData,
          color: card['color'] as Color,
          isActive: isActive,
        ),
      ),
    );
  }
}

class _AmbientCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isActive;

  const _AmbientCard({
    required this.title,
    required this.icon,
    required this.color,
    this.isActive = false,
  });

  @override
  State<_AmbientCard> createState() => _AmbientCardState();
}

class _AmbientCardState extends State<_AmbientCard>
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
              child: widget.isActive ? _buildEnlargedDesign() : _buildNormalDesign(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNormalDesign() {
    return Stack(
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
    );
  }

  Widget _buildEnlargedDesign() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color.withOpacity(0.1),
            widget.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Enlarged corner accent
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.9),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(32),
                ),
              ),
            ),
          ),
          // Close button for enlarged state
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: widget.color,
              ),
            ),
          ),
          // Main content for enlarged design - using Flexible to prevent overflow
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ENLARGED',
                    style: TextStyle(
                      fontSize: 7,
                      color: widget.color.withOpacity(0.7),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
