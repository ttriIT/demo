/// Centralized string constants for easy localization
class AppStrings {
  AppStrings._();
  
  // App Info
  static const String appName = 'Video Call';
  static const String appTagline = 'Connect with friends';
  
  // Authentication
  static const String login = 'Login';
  static const String register = 'Sign Up';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  
  // Validation
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Invalid email format';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort = 'Password must be at least 6 characters';
  static const String passwordsMismatch = 'Passwords do not match';
  static const String nameRequired = 'Name is required';
  
  // Navigation
  static const String chats = 'Chats';
  static const String friends = 'Friends';
  static const String profile = 'Profile';
  
  // Chat
  static const String typeMessage = 'Type a message...';
  static const String noMessages = 'No messages yet';
  static const String startConversation = 'Start a conversation!';
  
  // Friends
  static const String allFriends = 'All Friends';
  static const String requests = 'Requests';
  static const String addFriend = 'Add Friend';
  static const String searchFriends = 'Search friends...';
  static const String noFriends = 'No friends yet';
  static const String noRequests = 'No pending requests';
  static const String sendRequest = 'Send Request';
  static const String accept = 'Accept';
  static const String decline = 'Decline';
  static const String pending = 'Pending';
  
  // Profile
  static const String editProfile = 'Edit Profile';
  static const String about = 'About';
  static const String settings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String notifications = 'Notifications';
  
  // Call
  static const String videoCall = 'Video Call';
  static const String calling = 'Calling...';
  static const String incomingCall = 'Incoming call';
  
  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String search = 'Search';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String retry = 'Retry';
  
  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorNetwork = 'Network error. Please check your connection';
  static const String errorAuth = 'Authentication failed';
}
