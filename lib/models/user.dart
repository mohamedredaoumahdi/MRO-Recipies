class User {
  final String uid;
  final String email;
  final String username;
  final bool isAdmin;
  final String? photoUrl;

  User({
    required this.uid,
    required this.email,
    required this.username,
    this.isAdmin = false,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'isAdmin': isAdmin,
      'photoUrl': photoUrl,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      isAdmin: map['isAdmin'] ?? false,
      photoUrl: map['photoUrl'],
    );
  }
} 