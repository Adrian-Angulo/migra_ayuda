import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:migra_ayuda/features/auth/data/models/user_model.dart';
import 'package:migra_ayuda/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

class MockUserCredential extends Mock implements firebase_auth.UserCredential {}

// Test data
final testUser = UserModel(
  id: 'test-uid-123',
  name: 'Juan',
  lastname: 'Pérez',
  email: 'juan@example.com',
  password: 'password123',
  age: "30",
  destinationCountry: 'España',
  originCountry: 'México',
  role: 'Migrante',
  profileComplete: true,
);

final testIncompleteUser = UserModel(
  id: 'test-uid-456',
  name: 'María',
  lastname: 'García',
  email: 'maria@example.com',
  password: 'password456',
  role: 'Migrante',
  profileComplete: false,
);

final testNewUser = UserModel(
  name: 'Carlos',
  lastname: 'López',
  email: 'carlos@example.com',
  password: 'password789',
  age: "25",
  destinationCountry: 'USA',
  originCountry: 'Colombia',
);
