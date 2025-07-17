# Inhabit - Real Estate App

A full-stack real estate application built with Flutter frontend and Node.js backend.

## Features

### User Features
- **Property Search & Browse**: Search and filter properties by location, price, type, and more
- **Property Details**: View detailed property information with photos, descriptions, and amenities
- **Favorites**: Save and manage favorite properties
- **User Profile**: Manage personal information and preferences
- **Activity Tracking**: View your property search and interaction history
- **Theme Support**: Light and dark mode with customizable colors
- **Settings**: App preferences, notifications, and account management

### Authentication
- User registration and login
- Password change functionality
- Secure authentication with JWT tokens

### Real Estate Features
- Property listings with detailed information
- Lead management system
- Property status tracking (active, pending, sold)
- Interactive property cards and details

## Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile app development
- **Dart**: Programming language
- **Provider**: State management
- **HTTP**: API communication

### Backend
- **Node.js**: Server runtime
- **Express.js**: Web framework
- **MongoDB**: Database
- **JWT**: Authentication
- **bcrypt**: Password hashing

## Project Structure

```
real_easted_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── assets/
└── pubspec.yaml

Backend/
├── controllers/
├── models/
├── routes/
├── middleware/
└── server.js
```

## Getting Started

### Prerequisites
- Flutter SDK
- Node.js
- MongoDB

### Frontend Setup
1. Navigate to the Flutter app directory:
   ```bash
   cd real_easted_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd Backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the server:
   ```bash
   npm start
   ```

## Features Overview

### Home Page
- Property listings with search functionality
- Theme toggle (light/dark mode)
- Navigation drawer with app features

### Profile Page
- User information display
- Activity statistics (leads, favorites, searches)
- Clickable activity cards for detailed views

### Settings Page
- Theme selection (light/dark)
- Font size adjustment
- Notifications toggle
- App version display
- Change password functionality
- Feedback option

### Property Management
- Browse properties with filters
- View property details
- Add/remove favorites
- Lead tracking system

## API Endpoints

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/change-password` - Change password

### Properties
- `GET /api/properties` - Get all properties
- `GET /api/properties/:id` - Get property details
- `POST /api/properties/:id/favorite` - Add to favorites
- `DELETE /api/properties/:id/favorite` - Remove from favorites

### User
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update user profile
- `GET /api/user/activities` - Get user activities

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.
