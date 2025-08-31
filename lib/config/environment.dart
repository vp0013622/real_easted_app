enum Environment { development, production }

class EnvironmentConfig {
  static Environment _environment = Environment.development;

  static void setEnvironment(Environment env) {
    _environment = env;
  }

  static void toggleEnvironment() {
    _environment = _environment == Environment.development
        ? Environment.production
        : Environment.development;
  }

  static Environment get environment => _environment;

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isProduction => _environment == Environment.production;

  static String get baseUrl {
    // 🏠 FOR LOCAL DEVELOPMENT - Uncomment the local URL and comment the production URL
    return 'http://10.157.94.166:3001/api'; // Local development //my network
    //return 'http://192.168.0.184:3001/api'; // Local development //office network 1 netu
    //return 'http://192.168.0.176:3001/api'; // Local development //office network 2

    // 🌐 FOR PRODUCTION - Uncomment the production URL and comment the local URL
    //////return 'https://insightwaveit-backend-p0cl.onrender.com/api'; // Production
    //return 'https://updatedbackend-bqg8.onrender.com/api';

    // Common local IPs to try:
    // return 'http://10.0.2.2:3001/api'; // Android Emulator
    // return 'http://localhost:3001/api'; // iOS Simulator
    // return 'http://192.168.210.166:3001/api'; // Your local IP
  }

  // Add other environment-specific configurations here
  static int get connectionTimeout =>
      isDevelopment ? 30000 : 15000; // 30s for dev, 15s for prod
  static int get receiveTimeout => isDevelopment ? 30000 : 15000;

  static String get environmentName {
    return isDevelopment ? 'Development (Local)' : 'Production';
  }

  static String get environmentStatus {
    return '${environmentName} - ${baseUrl}';
  }
}
