// test/user_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:moroccan_recipies_app/models/user.dart';

void main() {
  group('User Model', () {
    test('toMap() converts User to Map correctly', () {
      final user = User(
        uid: 'test-uid',
        email: 'test@example.com',
        username: 'testUser',
        isAdmin: true,
        photoUrl: 'https://example.com/photo.jpg',
      );
      
      final map = user.toMap();
      
      expect(map['uid'], 'test-uid');
      expect(map['email'], 'test@example.com');
      expect(map['username'], 'testUser');
      expect(map['isAdmin'], true);
      expect(map['photoUrl'], 'https://example.com/photo.jpg');
    });
    
    test('fromMap() creates User from Map correctly', () {
      final map = {
        'uid': 'test-uid',
        'email': 'test@example.com',
        'username': 'testUser',
        'isAdmin': true,
        'photoUrl': 'https://example.com/photo.jpg',
      };
      
      final user = User.fromMap(map);
      
      expect(user.uid, 'test-uid');
      expect(user.email, 'test@example.com');
      expect(user.username, 'testUser');
      expect(user.isAdmin, true);
      expect(user.photoUrl, 'https://example.com/photo.jpg');
    });
  });
}