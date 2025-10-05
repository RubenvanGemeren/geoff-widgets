# ReactiveCardField

A physics-based interactive card field widget for Flutter that provides smooth, springy interactions between cards.

## Features

- **Physics-based interactions**: Cards push each other away with realistic physics
- **Smooth animations**: 60fps physics simulation with spring forces and damping
- **Drag and drop**: Cards follow your finger/mouse with spring physics
- **Collision detection**: Cards avoid overlapping and stay within bounds
- **Customizable parameters**: Tune stiffness, damping, repulsion, and max speed
- **Performance optimized**: Efficient physics simulation with spatial partitioning

## Usage

```dart
ReactiveCardField<MyItemType>(
  items: myItems,
  cardSize: const Size(140, 100),
  padding: const EdgeInsets.all(12),
  seedLayout: ReactiveSeedLayout.grid, // or .random
  stiffness: 380.0,                 // spring k
  damping: 22.0,                    // velocity damping
  repulsion: 9000.0,                // neighbor push strength
  maxSpeed: 2400.0,
  onTapItem: (item) { /* handle tap */ },
  builder: (context, item, isActive) => MyCardWidget(item: item, highlighted: isActive),
)
```

## Parameters

- `items`: List of data items to display as cards
- `cardSize`: Size of each card
- `padding`: Padding around the field
- `seedLayout`: Initial layout (grid or random)
- `stiffness`: Spring constant for drag interactions (higher = stiffer)
- `damping`: Velocity damping factor (higher = more damping)
- `repulsion`: Force between cards (higher = stronger push)
- `maxSpeed`: Maximum velocity for cards
- `onTapItem`: Callback when a card is tapped
- `builder`: Function to build each card widget

## Physics

The widget implements a simple physics simulation with:

- **Spring forces**: Dragged cards are pulled toward the pointer
- **Repulsion forces**: Cards push each other away based on distance
- **Collision resolution**: Overlapping cards are separated
- **Boundary constraints**: Cards stay within the padded area
- **Damping**: Velocities decay over time for smooth settling

## Performance

- Optimized for 30-60fps with 24+ cards on mid-range devices
- Uses efficient collision detection algorithms
- Minimal object allocation during simulation
- Single `AnimatedBuilder` for smooth updates
