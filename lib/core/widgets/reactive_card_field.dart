import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Body {
  Body({
    required this.id,
    required this.pos,
    required this.size,
    this.mass = 1.0,
  }) : baseSize = size,
       targetSize = size;

  final int id;
  Offset pos;
  Offset vel = Offset.zero;

  // Sizing
  final Size baseSize; // keep original size
  Size size;           // current animated size
  Size targetSize;     // where we're going

  // Existing
  double mass;
  bool dragging = false;
  Offset? dragAnchor;          // finger - topLeft offset at drag start
  Offset? lastPointerLocal;    // last pointer position in field-local coords
  Offset swipeVel = Offset.zero;   // smoothed swipe velocity

  // Enlarge state
  bool enlarged = false;
  Offset? _lockedBR;   // bottom-right anchor while animating

  Rect get rect => Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);
}

class PhysicsParams {
  PhysicsParams({
    required this.bounds,
    this.dt = 1 / 60,
    this.stiffness = 380,
    this.damping = 22,
    this.repulsion = 9000,
    this.maxSpeed = 2400,
    this.enlargedScale = 1.6,
    this.singleEnlargedAtOnce = true,
    this.sizeLerpPerSec = 12.0,
  });

  final Rect bounds;
  final double dt;
  final double stiffness; // spring k
  final double damping;   // linear damping factor
  final double repulsion; // neighbor push
  final double maxSpeed;  // clamp
  final double enlargedScale;
  final bool singleEnlargedAtOnce;
  final double sizeLerpPerSec;
}

enum ReactiveSeedLayout { grid, random }

class ReactiveFieldController extends ChangeNotifier implements TickerProvider {
  ReactiveFieldController({
    required this.itemCount,
    required this.cardSize,
    required this.padding,
    required this.seedLayout,
    required this.params,
  }) {
    _ticker = createTicker(_tick)..start();
    _initBodies();
  }

  final int itemCount;
  final Size cardSize;
  final EdgeInsets padding;
  final ReactiveSeedLayout seedLayout;
  PhysicsParams params;

  late final Ticker _ticker;
  final List<Body> bodies = [];
  bool _needsLayout = true;

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);

  void disposeController() {
    _ticker.dispose();
  }

  void updateBounds(Size size) {
    final Rect b = Offset(padding.left, padding.top) &
        Size(size.width - padding.horizontal, size.height - padding.vertical);
    params = PhysicsParams(
      bounds: b,
      dt: params.dt,
      stiffness: params.stiffness,
      damping: params.damping,
      repulsion: params.repulsion,
      maxSpeed: params.maxSpeed,
    );
    if (_needsLayout) {
      _seedLayout();
      _needsLayout = false;
    }
  }

  void _initBodies() {
    bodies.clear();
    for (int i = 0; i < itemCount; i++) {
      final body = Body(id: i, pos: Offset.zero, size: cardSize, mass: 1.0);
      body.enlarged = false;
      body._lockedBR = null;
      bodies.add(body);
    }
  }

  void _seedLayout() {
    switch (seedLayout) {
      case ReactiveSeedLayout.grid:
        final cols = math.max(1, (params.bounds.width / (cardSize.width + 12)).floor());
        for (int i = 0; i < bodies.length; i++) {
          final r = i ~/ cols;
          final c = i % cols;
          final x = params.bounds.left + c * (cardSize.width + 12);
          final y = params.bounds.top + r * (cardSize.height + 12);
          bodies[i].pos = Offset(
            x.clamp(params.bounds.left, params.bounds.right - cardSize.width),
            y.clamp(params.bounds.top, params.bounds.bottom - cardSize.height),
          );
        }
        break;
      case ReactiveSeedLayout.random:
        final rnd = math.Random(42);
        for (final b in bodies) {
          final x = params.bounds.left +
              rnd.nextDouble() * (params.bounds.width - cardSize.width);
          final y = params.bounds.top +
              rnd.nextDouble() * (params.bounds.height - cardSize.height);
          b.pos = Offset(x, y);
        }
        break;
    }
  }

  // Public interactions
  void tap(int id) {
    final b = bodies[id];
    // Give the tapped card a small outward "burst" by nudging neighbors
    for (final other in bodies) {
      if (other.id == b.id) continue;
      final dir = (other.pos + Offset(other.size.width/2, other.size.height/2)) -
                  (b.pos + Offset(b.size.width/2, b.size.height/2));
      final d2 = math.max(64, dir.distanceSquared);
      final force = params.repulsion / d2;
      other.vel += dir / (math.sqrt(d2)) * force * params.dt;
    }
    // Slight pop to the tapped card too
    b.vel *= 0.8;
    notifyListeners();
  }

  void startDrag(int id, Offset pointerLocal) {
    final b = bodies[id];
    b.dragging = true;
    // Anchor so the card doesn't jump under the finger
    b.dragAnchor = pointerLocal - b.pos;
    b.lastPointerLocal = pointerLocal;
    b.swipeVel = Offset.zero;
  }

  void updateDrag(int id, Offset pointerLocal, {double smoothing = 0.18}) {
    final b = bodies[id];
    if (!b.dragging || b.dragAnchor == null) return;

    // Desired top-left so the card stays under the finger
    Offset desired = pointerLocal - b.dragAnchor!;
    // Clamp inside bounds
    desired = Offset(
      desired.dx.clamp(params.bounds.left, params.bounds.right - b.size.width),
      desired.dy.clamp(params.bounds.top, params.bounds.bottom - b.size.height),
    );

    // Directly set position (kinematic), zero sim velocity while dragging
    b.pos = desired;
    b.vel = Offset.zero;

    // Swipe velocity estimate (EMA of pointer delta / dt)
    final dt = params.dt <= 0 ? (1 / 60) : params.dt;
    final instVel = (pointerLocal - (b.lastPointerLocal ?? pointerLocal)) / dt;
    b.swipeVel = b.swipeVel == Offset.zero
        ? instVel
        : b.swipeVel * (1 - smoothing) + instVel * smoothing;

    b.lastPointerLocal = pointerLocal;
  }

  void endDrag(int id) {
    final b = bodies[id];
    b.dragging = false;
    // Use the measured swipe velocity as the release velocity
    b.vel = _clampMagnitude(b.swipeVel, params.maxSpeed);
    b.dragAnchor = null;
    b.lastPointerLocal = null;
  }

  void toggleEnlarge(int id, {double? scale}) {
    final b = bodies[id];
    final s = scale ?? params.enlargedScale;
    if (!b.enlarged) {
      if (params.singleEnlargedAtOnce) {
        for (final o in bodies) {
          if (o.enlarged) _shrink(o);
        }
      }
      _enlarge(b, s);
    } else {
      _shrink(b);
    }
    notifyListeners();
  }

  void shrinkAll() {
    for (final b in bodies) {
      if (b.enlarged) _shrink(b);
    }
    notifyListeners();
  }

  void _enlarge(Body b, double scale) {
    b.enlarged = true;
    // lock bottom-right corner
    b._lockedBR = b.pos + Offset(b.size.width, b.size.height);
    final newSize = Size(b.baseSize.width * scale, b.baseSize.height * scale);
    b.targetSize = newSize;
  }

  void _shrink(Body b) {
    b.enlarged = false;
    b._lockedBR = b.pos + Offset(b.size.width, b.size.height);
    b.targetSize = b.baseSize;
  }

  // Physics tick
  void _tick(Duration _) {
    final dt = params.dt;

    // Pairwise repulsion + collision resolution (simple AABB)
    for (int i = 0; i < bodies.length; i++) {
      for (int j = i + 1; j < bodies.length; j++) {
        final a = bodies[i];
        final c = bodies[j];

        // Repulsion - only apply to non-dragged bodies
        final ac = (c.pos - a.pos);
        final d2 = math.max(36.0, ac.distanceSquared);
        final f = params.repulsion / d2;
        final n = ac / math.sqrt(d2);
        final fdt = f * dt;

        if (a.dragging && !c.dragging) {
          c.vel += n * (fdt / c.mass);
        } else if (!a.dragging && c.dragging) {
          a.vel -= n * (fdt / a.mass);
        } else if (!a.dragging && !c.dragging) {
          a.vel -= n * (fdt / a.mass);
          c.vel += n * (fdt / c.mass);
        }

        // Collision resolve (AABB overlap)
        final ra = a.rect;
        final rc = c.rect;
        if (ra.overlaps(rc)) {
          final overlapX = math.min(ra.right - rc.left, rc.right - ra.left);
          final overlapY = math.min(ra.bottom - rc.top, rc.bottom - ra.top);

          void push(Body target, {required double dx, required double dy}) {
            target.pos = target.pos.translate(dx, dy);
            target.vel = Offset(target.vel.dx * 0.5, target.vel.dy * 0.5);
          }

          if (overlapX < overlapY) {
            final sep = overlapX / 2;
            final signX = (rc.center.dx - ra.center.dx) >= 0 ? 1 : -1;
            if (a.dragging && !c.dragging) {
              push(c, dx: signX * sep, dy: 0);
            } else if (!a.dragging && c.dragging) {
              push(a, dx: -signX * sep, dy: 0);
            } else if (!a.dragging && !c.dragging) {
              push(a, dx: -signX * sep, dy: 0);
              push(c, dx: signX * sep, dy: 0);
            }
          } else {
            final sep = overlapY / 2;
            final signY = (rc.center.dy - ra.center.dy) >= 0 ? 1 : -1;
            if (a.dragging && !c.dragging) {
              push(c, dx: 0, dy: signY * sep);
            } else if (!a.dragging && c.dragging) {
              push(a, dx: 0, dy: -signY * sep);
            } else if (!a.dragging && !c.dragging) {
              push(a, dx: 0, dy: -signY * sep);
              push(c, dx: 0, dy: signY * sep);
            }
          }
        }
      }
    }

    // Size animation with bottom-right anchor
    for (final b in bodies) {
      if (b.size != b.targetSize) {
        // exponential approach based on rate per second
        final t = (1 - math.exp(-params.sizeLerpPerSec * dt)).clamp(0.0, 1.0);
        final w = b.size.width + (b.targetSize.width - b.size.width) * t;
        final h = b.size.height + (b.targetSize.height - b.size.height) * t;

        // preserve bottom-right anchor when animating
        final br = (b._lockedBR ?? (b.pos + Offset(b.size.width, b.size.height)));
        b.size = Size(w, h);
        b.pos = Offset(br.dx - b.size.width, br.dy - b.size.height);

        // Clean up when animation is complete
        if ((b.size.width - b.targetSize.width).abs() < 0.5 &&
            (b.size.height - b.targetSize.height).abs() < 0.5) {
          b.size = b.targetSize;
          b._lockedBR = null;
        }
      }
    }

    // Integrate + bounds - skip kinematic bodies
    for (final b in bodies) {
      if (b.dragging) {
        // Kinematic while dragging: no integration/damping; ensure still clamped
        b.pos = Offset(
          b.pos.dx.clamp(params.bounds.left, params.bounds.right - b.size.width),
          b.pos.dy.clamp(params.bounds.top, params.bounds.bottom - b.size.height),
        );
        b.vel = Offset.zero;
        continue;
      }

      // Normal integration for non-dragged bodies
      b.vel = _clampMagnitude(b.vel, params.maxSpeed);
      b.pos += b.vel * dt;

      // Damping
      b.vel *= (1 - params.damping * dt).clamp(0.0, 1.0);

      // Bounds clamp with soft bounce
      final r = b.rect;
      double x = b.pos.dx, y = b.pos.dy;
      double vx = b.vel.dx, vy = b.vel.dy;

      if (r.left < params.bounds.left) {
        x = params.bounds.left;
        vx = -vx * 0.1;
      }
      if (r.top < params.bounds.top) {
        y = params.bounds.top;
        vy = -vy * 0.1;
      }
      if (r.right > params.bounds.right) {
        x = params.bounds.right - b.size.width;
        vx = -vx * 0.1;
      }
      if (r.bottom > params.bounds.bottom) {
        y = params.bounds.bottom - b.size.height;
        vy = -vy * 0.1;
      }
      b.pos = Offset(x, y);
      b.vel = Offset(vx, vy);
    }

    notifyListeners();
  }

  Offset _clampMagnitude(Offset v, double max) {
    final m2 = v.distanceSquared;
    if (m2 <= max * max) return v;
    final m = math.sqrt(m2);
    return v * (max / m);
  }
}

typedef ReactiveItemBuilder<T> = Widget Function(BuildContext, T item, bool active);

class ReactiveCardField<T> extends StatefulWidget {
  const ReactiveCardField({
    super.key,
    required this.items,
    required this.builder,
    required this.cardSize,
    required this.padding,
    this.seedLayout = ReactiveSeedLayout.grid,
    this.stiffness = 380,
    this.damping = 22,
    this.repulsion = 9000,
    this.maxSpeed = 2400,
    this.enlargedScale = 1.6,
    this.singleEnlargedAtOnce = true,
    this.sizeAnimApprox = const Duration(milliseconds: 180),
    this.onTapItem,
  });

  final List<T> items;
  final ReactiveItemBuilder<T> builder;
  final Size cardSize;
  final EdgeInsets padding;
  final ReactiveSeedLayout seedLayout;
  final double stiffness, damping, repulsion, maxSpeed;
  final double enlargedScale;
  final bool singleEnlargedAtOnce;
  final Duration sizeAnimApprox;
  final void Function(T item)? onTapItem;

  @override
  State<ReactiveCardField<T>> createState() => _ReactiveCardFieldState<T>();
}

class _ReactiveCardFieldState<T> extends State<ReactiveCardField<T>> with TickerProviderStateMixin {
  late ReactiveFieldController _controller;
  final GlobalKey _stackKey = GlobalKey();

  double _rateFromApprox(Duration d) {
    // time-constant style: reach ~63% per duration
    return d.inMilliseconds == 0 ? 14.0 : 1.0 / (d.inMilliseconds / 1000.0);
  }

  @override
  void initState() {
    super.initState();
    _controller = ReactiveFieldController(
      itemCount: widget.items.length,
      cardSize: widget.cardSize,
      padding: widget.padding,
      seedLayout: widget.seedLayout,
      params: PhysicsParams(
        bounds: Rect.zero,
        stiffness: widget.stiffness,
        damping: widget.damping,
        repulsion: widget.repulsion,
        maxSpeed: widget.maxSpeed,
        enlargedScale: widget.enlargedScale,
        singleEnlargedAtOnce: widget.singleEnlargedAtOnce,
        sizeLerpPerSec: _rateFromApprox(widget.sizeAnimApprox),
      ),
    );
  }

  @override
  void dispose() {
    _controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _controller.updateBounds(Size(c.maxWidth, c.maxHeight));
        });
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _controller.shrinkAll();
          },
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                key: _stackKey,
                clipBehavior: Clip.none,
                children: [
                  for (final b in _controller.bodies)
                    Positioned(
                      left: b.pos.dx,
                      top: b.pos.dy,
                      width: b.size.width,
                      height: b.size.height,
                      child: _CardShell(
                        child: widget.builder(context, widget.items[b.id], b.dragging || b.enlarged),
                        onTap: () {
                          // Toggle enlarge for this card (and also invoke existing onTapItem)
                          _controller.toggleEnlarge(b.id);
                          final item = widget.items[b.id];
                          widget.onTapItem?.call(item);
                        },
                        onPanStart: (d) {
                          final box = _stackKey.currentContext!.findRenderObject() as RenderBox;
                          final local = box.globalToLocal(d.globalPosition);
                          _controller.startDrag(b.id, local);
                        },
                        onPanUpdate: (d) {
                          final box = _stackKey.currentContext!.findRenderObject() as RenderBox;
                          final local = box.globalToLocal(d.globalPosition);
                          _controller.updateDrag(b.id, local);
                        },
                        onPanEnd: (_) => _controller.endDrag(b.id),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.child,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final Widget child;
  final VoidCallback onTap;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 120),
          scale: 1.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: kElevationToShadow[2],
              color: Theme.of(context).cardColor,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
