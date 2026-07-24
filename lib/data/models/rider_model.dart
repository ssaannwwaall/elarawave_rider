import '../../domain/entities/rider.dart';

class RiderModel extends Rider {
  const RiderModel({
    required super.id,
    required super.name,
    required super.username,
    required super.email,
  });

  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
      };
}
