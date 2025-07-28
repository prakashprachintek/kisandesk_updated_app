class UserSession {
  static Map<String, dynamic>? currentUser;

  static void setUser(Map<String, dynamic> userData) {
    currentUser = userData;
  }

  static Map<String, dynamic>? get user => currentUser;

  static String? get userId => currentUser?['_id'];
}
