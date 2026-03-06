# PropLilly - Property Monitoring Application

A comprehensive Flutter application for property monitoring and management with three user types: Property Owners, Field Agents/Helpers, and Admins.

## Features

### Property Owner Features
- ✅ Account creation and authentication (Login, Sign Up, OTP Verification, Forgot Password)
- ✅ Add Property with location selection via Google Maps
- ✅ Request Documentation services
- ✅ Request Brokering services
- ✅ Property verification status tracking
- ✅ View assigned helper details
- ✅ Property monitoring and visit history
- ✅ Raise emergency service requests
- ✅ Subscription management
- ✅ View reports and visit history

### Field Agent / Helper Features
- ✅ Account creation and authentication
- ✅ View assigned properties
- ✅ Visit schedule and reminders
- ✅ Today's visit list
- ✅ Start/End visit with geo-tagging
- ✅ Visit history tracking
- ✅ Notifications

### Admin Features
- ✅ Account creation and authentication
- ✅ Property verification and approval/rejection
- ✅ Helper management and assignment
- ✅ Visit monitoring dashboard
- ✅ Emergency and issue handling
- ✅ Subscription and billing management
- ✅ Service request management

## Project Structure

```
lib/
├── models/              # Data models
│   ├── user_model.dart
│   ├── property_model.dart
│   ├── visit_model.dart
│   ├── service_request_model.dart
│   └── subscription_model.dart
├── screens/
│   ├── auth/           # Authentication screens
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── otp_verification_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── property_owner/ # Property owner screens
│   │   ├── property_owner_dashboard.dart
│   │   ├── add_property_screen.dart
│   │   ├── request_documentation_screen.dart
│   │   ├── request_brokering_screen.dart
│   │   └── property_details_screen.dart
│   ├── helper/         # Helper screens (to be implemented)
│   └── admin/          # Admin screens (to be implemented)
├── services/           # API services
│   ├── auth_service.dart
│   ├── property_service.dart
│   └── visit_service.dart
├── providers/          # State management
│   └── auth_provider.dart
├── widgets/            # Reusable widgets
│   ├── map_location_picker.dart
│   └── file_upload_widget.dart
└── utils/              # Utilities
    ├── constants.dart
    └── router.dart
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Google Maps API key (for map features)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd proplilly
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Google Maps:
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - For Android: Add your API key in `android/app/src/main/AndroidManifest.xml`
   - For iOS: Add your API key in `ios/Runner/AppDelegate.swift`

4. Update API Base URL:
   - Edit `lib/utils/constants.dart` and update `baseUrl` with your backend API URL

5. Run the application:
```bash
flutter run
```

## Dependencies

- **provider**: State management
- **go_router**: Navigation and routing
- **google_maps_flutter**: Map integration
- **geolocator**: Location services
- **image_picker**: Image selection
- **file_picker**: File selection
- **http/dio**: HTTP client for API calls
- **shared_preferences**: Local storage

## Backend Requirements

The application expects a REST API backend with the following endpoints:

### Authentication
- `POST /auth/signup` - User registration
- `POST /auth/verify-otp` - OTP verification
- `POST /auth/login` - User login
- `POST /auth/forgot-password` - Password reset
- `POST /auth/resend-otp` - Resend OTP

### Properties
- `GET /properties` - Get user's properties
- `POST /properties` - Add new property
- `GET /properties/:id` - Get property details

### Visits
- `GET /visits?propertyId=:id` - Get visits for property
- `GET /visits/today?helperId=:id` - Get today's visits
- `POST /visits/start` - Start a visit
- `POST /visits/:id/end` - End a visit

## Development Status

### Completed ✅
- Project setup and dependencies
- Authentication system (Login, Sign Up, OTP, Forgot Password)
- Data models
- Property Owner dashboard
- Add Property feature with map integration
- Request Documentation feature
- Request Brokering feature
- File upload widgets
- Map location picker

### In Progress 🚧
- Helper/Field Agent features
- Admin features
- Visit tracking
- Subscription management
- Notifications

### To Do 📋
- Complete Helper dashboard and features
- Complete Admin dashboard and features
- Payment integration
- Push notifications
- Reports and analytics
- Testing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

[Add your license here]

## Support

For support, email [your-email] or create an issue in the repository.
