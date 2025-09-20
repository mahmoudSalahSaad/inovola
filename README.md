# Expenser - Expense Tracking Mobile App

A comprehensive expense tracking mobile application built with Flutter that works offline, integrates with currency conversion APIs, supports pagination, and features a modern, user-friendly design.

## Features

### 🏗️ Architecture & State Management
- **BLoC Pattern**: Uses `flutter_bloc` for state management across all features
- **Clean Architecture**: Organized with separate layers for models, repositories, services, and UI
- **Reactive UI**: UI components react to state changes using BlocBuilder and BlocListener

### 💰 Core Features

#### 1. Dashboard Screen
- User welcome message with profile display
- Total balance, income, and expenses summary
- Filter options (This Month, Last 7 Days, etc.)
- Recent expenses list with pagination
- Floating action button to add new expenses

#### 2. Add Expense Screen
- Category selection with intuitive icons
- Amount input with currency selection
- Date picker for expense date
- Receipt image upload functionality
- Form validation and error handling

#### 3. Currency Conversion
- Real-time exchange rate fetching from open APIs
- Automatic conversion to USD for consistent storage
- Support for multiple popular currencies (USD, EUR, GBP, JPY, etc.)
- Offline fallback rates when API is unavailable

#### 4. Pagination & Filtering
- Infinite scroll pagination (10 items per page)
- Filter by time periods (This Month, Last 7 Days, etc.)
- Search functionality across expenses
- Loading states and error handling

#### 5. Local Storage
- **Hive Database**: Fast, lightweight local storage
- Offline-first approach with data persistence
- Automatic data synchronization

### 🎨 Design Implementation
- **Material Design 3**: Modern UI components and theming
- **Google Fonts**: Inter font family for consistent typography
- **Custom Color Scheme**: Blue-based theme matching the provided design
- **Responsive Layout**: Optimized for mobile devices
- **Smooth Animations**: Loading states and transitions

## Technical Stack

### Dependencies
- **flutter_bloc**: State management
- **hive**: Local database storage
- **http & dio**: API integration
- **image_picker**: Camera/gallery integration
- **google_fonts**: Typography
- **intl**: Internationalization and formatting
- **equatable**: Value equality

### Development Dependencies
- **hive_generator**: Code generation for Hive adapters
- **build_runner**: Build system
- **bloc_test**: Testing BLoC components
- **mockito**: Mocking for tests

## Project Structure

```
lib/
├── blocs/           # BLoC state management
│   ├── expense/     # Expense management BLoC
│   ├── currency/    # Currency conversion BLoC
│   └── user/        # User authentication BLoC
├── models/          # Data models
├── repositories/    # Data access layer
├── services/        # External services (API, storage)
├── screens/         # UI screens
├── widgets/         # Reusable UI components
└── utils/           # Utility functions and helpers

test/
├── models/          # Model tests
├── services/        # Service tests
└── utils/           # Utility tests
```

## API Integration

### Currency Conversion API
- **Primary**: `https://open.er-api.com/v6/latest/USD` (No API key required)
- **Fallback**: Local exchange rates for offline functionality
- **Caching**: 1-hour cache to minimize API calls
- **Error Handling**: Graceful fallback to cached or default rates

## Testing

The project includes comprehensive unit tests covering:

### Test Coverage
- **Model Tests**: Data model creation, validation, and equality
- **Service Tests**: Currency conversion logic and API integration
- **Utility Tests**: Currency formatting and parsing functions
- **Integration Tests**: End-to-end functionality testing

### Running Tests
```bash
flutter test
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd inovola
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   dart run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## Features Demonstration

### Login Screen
- Clean, modern login interface
- Email/password authentication
- Social login options (Google, Apple)
- Form validation and error handling

### Dashboard
- Balance summary with visual indicators
- Recent expenses with category icons
- Filter dropdown for time periods
- Pull-to-refresh functionality

### Add Expense
- Category selection grid with icons
- Currency selector dropdown
- Date picker integration
- Camera integration for receipts
- Real-time validation

### Data Management
- Offline-first architecture
- Automatic data persistence
- Background sync capabilities
- Data export/import ready

## Performance Optimizations

- **Lazy Loading**: Pagination for large expense lists
- **Image Optimization**: Compressed receipt images
- **Caching**: API response caching
- **Memory Management**: Efficient state management with BLoC

## Future Enhancements

- [ ] Data export (CSV, PDF)
- [ ] Expense categories customization
- [ ] Budget tracking and alerts
- [ ] Multi-user support
- [ ] Cloud synchronization
- [ ] Expense analytics and charts
- [ ] Receipt OCR text extraction

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Design inspiration from modern expense tracking apps
- Flutter community for excellent packages and documentation
- Open Exchange Rates API for currency conversion data

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# inovola
