class Env {
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );
  
  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';
  
  // MCP Servers
  static String get recipeMcpUrl => isProduction 
    ? 'https://api.yemekyardimci.com/mcp/recipes'
    : 'http://localhost:8080/mcp/recipes';
    
  // API Keys (fetched from dart-define for security in production)
  static const String mem0ApiKey = String.fromEnvironment('MEM0_API_KEY');
  static const String spoonacularApiKey = String.fromEnvironment('SPOONACULAR_API_KEY');
  
  // Feature flags
  static bool get enableAIAssistant => true;
  static bool get enableMultiModelAnalysis => isProduction;
  static bool get enableMemoryLearning => true;
  
  // Sentry
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
}
