import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String token;
  final String? avatar;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.token,
    this.avatar,
  });

  @override
  List<Object?> get props => [id, name, email, token, avatar];

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? token,
    String? avatar,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      token: token ?? this.token,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, token: ${token.substring(0, 8)}...)';
}
