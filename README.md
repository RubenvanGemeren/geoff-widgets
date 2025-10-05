# Geoff Widgets - Ambient Tablet App

A modular Flutter application designed for Android tablets, featuring an ambient dashboard with customizable theming inspired by shadcn-vue design system.

## 🌟 Features

- **Modular Architecture**: Clean separation between backend services and frontend components
- **Customizable Theming**: Multiple theme options (Default, Dark, Light, Ambient) with easy switching
- **Ambient Dashboard**: Real-time widgets for weather, time, notifications, and quick actions
- **Responsive Design**: Optimized for tablet screens with grid-based layout
- **Service Layer**: Modular backend with dependency injection for easy maintenance

## 🏗️ Project Structure

```
lib/
├── core/                          # Core application infrastructure
│   ├── api/                       # External API services
│   │   ├── weather_service.dart
│   │   └── notification_service.dart
│   ├── services/                  # Service locator for dependency injection
│   │   └── service_locator.dart
│   ├── storage/                   # Local storage services
│   │   └── local_storage_service.dart
│   └── theme/                     # Theming system
│       ├── theme_manager.dart
│       └── themes/
│           ├── default_theme.dart
│           ├── dark_theme.dart
│           ├── light_theme.dart
│           └── ambient_theme.dart
├── features/                      # Feature modules
│   └── ambient/                   # Ambient dashboard feature
│       ├── data/                  # Data layer
│       │   └── repositories/
│       │       └── ambient_repository_impl.dart
│       ├── domain/                # Domain layer
│       │   └── repositories/
│       │       └── ambient_repository.dart
│       └── presentation/           # Presentation layer
│           ├── pages/
│           │   └── ambient_page.dart
│           └── widgets/
│               ├── ambient_dashboard.dart
│               ├── theme_selector.dart
│               ├── weather_widget.dart
│               ├── time_widget.dart
│               ├── notifications_widget.dart
│               └── quick_actions_widget.dart
└── main.dart                      # Application entry point
```

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android tablet with USB debugging enabled

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd geoff-widgets
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate required files**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Connect your Android tablet**
   - Enable Developer Options on your tablet
   - Enable USB Debugging
   - Connect via USB cable

5. **Run the application**
   ```bash
   flutter run
   ```

## 🎨 Theming System

The app features a flexible theming system with four built-in themes:

### Available Themes

- **Default**: Clean, professional design with blue accents
- **Dark**: Dark mode with high contrast
- **Light**: Bright, minimal design
- **Ambient**: Glowing, atmospheric design perfect for ambient displays

### Customizing Themes

To create a custom theme:

1. Create a new theme file in `lib/core/theme/themes/`
2. Follow the existing theme structure
3. Add your theme to the `ThemeManager` class
4. Update the theme selector widget

Example custom theme:
```dart
class CustomTheme {
  static const Color primaryColor = Color(0xFFYOUR_COLOR);
  // ... other color definitions

  static ThemeData get theme {
    return ThemeData(
      // ... theme configuration
    );
  }
}
```

## 🔧 Backend Services

### Service Locator Pattern

The app uses a service locator pattern for dependency injection:

```dart
// Get a service
final weatherService = serviceLocator<WeatherService>();

// Services are automatically injected
```

### Available Services

- **WeatherService**: Fetches weather data from OpenWeatherMap API
- **NotificationService**: Manages in-app notifications
- **LocalStorageService**: Handles local data persistence

### Adding New Services

1. Create your service class
2. Register it in `ServiceLocator.setup()`
3. Inject it where needed using `serviceLocator<YourService>()`

## 📱 Frontend Components

### Widget Architecture

Each widget is self-contained and follows the single responsibility principle:

- **WeatherWidget**: Displays current weather information
- **TimeWidget**: Shows real-time clock with greeting
- **NotificationsWidget**: Lists and manages notifications
- **QuickActionsWidget**: Provides quick action buttons

### Adding New Widgets

1. Create widget file in `lib/features/ambient/presentation/widgets/`
2. Add to the dashboard grid in `ambient_dashboard.dart`
3. Follow the existing widget structure

## 🛠️ Development

### Running in Debug Mode

```bash
flutter run --debug
```

### Building for Release

```bash
flutter build apk --release
```

### Hot Reload

The app supports hot reload for rapid development:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart

## 📦 Dependencies

### Core Dependencies

- **provider**: State management
- **http**: HTTP requests
- **shared_preferences**: Local storage
- **hive**: NoSQL database
- **google_fonts**: Typography
- **intl**: Internationalization

### Development Dependencies

- **flutter_lints**: Code linting
- **build_runner**: Code generation
- **hive_generator**: Hive code generation

## 🔌 API Configuration

### Weather API Setup

1. Get a free API key from [OpenWeatherMap](https://openweathermap.org/api)
2. Replace `your_openweather_api_key_here` in `lib/core/api/weather_service.dart`
3. The app will use mock data if no API key is provided

### Adding New APIs

1. Create service class in `lib/core/api/`
2. Register in service locator
3. Use dependency injection to access the service

## 🎯 Customization Guide

### Changing Colors

Edit the theme files in `lib/core/theme/themes/`:

```dart
static const Color primaryColor = Color(0xFFYOUR_COLOR);
```

### Modifying Layout

Update the grid configuration in `ambient_dashboard.dart`:

```dart
GridView.count(
  crossAxisCount: 2,        // Number of columns
  childAspectRatio: 1.2,    // Widget aspect ratio
  // ... other properties
)
```

### Adding New Features

1. Create feature module in `lib/features/`
2. Follow the existing architecture pattern
3. Register services in service locator
4. Add UI components to dashboard

## 🐛 Troubleshooting

### Common Issues

1. **Build errors**: Run `flutter clean && flutter pub get`
2. **Hot reload not working**: Restart the app
3. **Android connection issues**: Check USB debugging settings
4. **Theme not applying**: Restart the app after theme changes

### Debug Mode

Enable debug logging by setting:
```dart
debugPrint('Your debug message');
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For issues and questions:
- Check the troubleshooting section
- Review the Flutter documentation
- Open an issue on GitHub

---

**Happy coding! 🚀**
