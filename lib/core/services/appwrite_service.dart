import 'package:appwrite/appwrite.dart';

/// Singleton class to manage Appwrite client
class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late final Client _client;
  late final Account _account;
  late final Databases _databases;
  late final Storage _storage;
  late final Realtime _realtime;

  /// Initialize Appwrite client with hardcoded project details
  void init() {
    _client = Client()
        .setProject("692ea196003c16a4b465")
        .setEndpoint("https://sfo.cloud.appwrite.io/v1")
        .setSelfSigned(status: true); // For development only

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
    _realtime = Realtime(_client);
  }

  /// Ping the Appwrite server
  Future<void> ping() async {
    await _client.ping();
  }

  /// Getters for Appwrite services
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;
  Realtime get realtime => _realtime;
  Client get client => _client;
}
