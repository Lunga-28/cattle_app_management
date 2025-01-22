# Cattle Farm Management System

A comprehensive farm management solution built with Node.js/Express backend and Flutter frontend, designed to help farmers efficiently manage their cattle operations.

## Features

- **User Authentication**
  - Secure login and registration system
  - Google authentication support
  - Profile management
  - Password change functionality

- **Cattle Management**
  - Add and track individual cattle
  - Maintain health records
  - Monitor cattle inventory
  - Individual cattle profile tracking

- **Feed Management**
  - Track feed inventory
  - Monitor low stock alerts
  - Adjust stock levels
  - Feed consumption tracking

- **Health Records**
  - Record and track animal health data
  - Maintain vaccination records
  - Track medical history by individual cattle
  - Health record management system

- **Financial Management**
  - Track farm expenses
  - Financial record keeping
  - Revenue and expense monitoring

- **Weather Integration**
  - Real-time weather updates
  - Weather forecast integration
  - Farm-specific weather data

## Technical Stack

### Backend
- Node.js
- Express.js
- MongoDB (with Mongoose)
- JWT Authentication
- CORS enabled

### Frontend
- Flutter
- Material Design
- Shared Preferences for local storage
- Responsive UI with custom theming

## Project Structure

### Backend Routes
- `/api/auth` - Authentication routes
- `/api/user` - User profile management
- `/api/cattle` - Cattle management
- `/api/feed` - Feed inventory management
- `/api/finances` - Financial records
- `/api/health` - Health records
- `/api/weather` - Weather information

### Frontend Screens
- Welcome Screen
- Login Screen
- Dashboard Screen
- Inventory Screen
- Health Screen
- Feed Screen
- Finances Screen
- Weather Screen
- Profile Screen

## Installation

### Backend Setup
1. Clone the repository
2. Install dependencies:
   ```bash
   cd backend
   npm install
   ```
3. Create a `.env` file with the following variables:
   ```
    OPENWEATHER_API_KEY="yourkey"
MONGO = "Mongodbkey"
JWT_SECRET = "jwtsecret"
JWT_EXPIRES_IN=1h
PORT=3000
   ```
4. Start the server:
   ```bash
   npm start
   ```

### Frontend Setup
1. Navigate to the Flutter project directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

## Security Features

- JWT-based authentication
- Protected API routes
- CORS configuration for allowed origins
- Secure password handling
- HTTP security headers

## Development Environment

### Backend Requirements
- Node.js
- MongoDB
- npm or yarn

### Frontend Requirements
- Flutter SDK
- Dart
- Android Studio / VS Code with Flutter extensions

## API Documentation

### Authentication Endpoints
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/signin` - User login
- `POST /api/auth/google` - Google authentication

### User Endpoints
- `GET /api/user/profile` - Get user profile
- `PUT /api/user/profile` - Update profile
- `PUT /api/user/change-password` - Change password

### Cattle Endpoints
- `POST /api/cattle` - Add new cattle
- `GET /api/cattle` - Get all cattle
- `GET /api/cattle/:id` - Get specific cattle
- `PUT /api/cattle/:id` - Update cattle
- `DELETE /api/cattle/:id` - Delete cattle

### Feed Endpoints
- `POST /api/feed` - Add new feed
- `GET /api/feed` - Get all feeds
- `GET /api/feed/low-stock` - Get low stock alerts
- `PUT /api/feed/:id` - Update feed
- `DELETE /api/feed/:id` - Delete feed

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Support

For support, email [support@cattlefarm.com](mailto:support@cattlefarm.com) or raise an issue in the repository.