import 'package:appwrite/appwrite.dart';
import '../constants/app_constants.dart';

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

  /// Initialize Appwrite client
  void init() {
    _client = Client()
        .setEndpoint(AppConstants.appwriteEndpoint)
        .setProject(AppConstants.appwriteProjectId)
        .setSelfSigned(status: true); // For development only

    _account = Account(_client);
    _databases = Databases(_client);
    _storage = Storage(_client);
    _realtime = Realtime(_client);
  }

  /// Getters for Appwrite services
  Account get account => _account;
  Databases get databases => _databases;
  Storage get storage => _storage;
  Realtime get realtime => _realtime;
  Client get client => _client;
}
