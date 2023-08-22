import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/auth/user.dart' as entity;
import '../../domain/core/value_objects.dart';

extension FirebaseUserDomainX on User {
  entity.User toDomain() {
    return entity.User(id: UniqueId.fromUniqueString(uid));
  }
}
