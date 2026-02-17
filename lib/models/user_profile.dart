class UserProfile {
  final String name;
  final String address;
  final String phone;
  final String email;
  final double hourlyRate;
  final String telegramChatId;
  final String status;
  final String language1;
  final String language2;
  final String country;
  final String role;
  final String availability;

  UserProfile({
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.hourlyRate,
    required this.telegramChatId,
    required this.status,
    required this.language1,
    required this.language2,
    required this.country,
    required this.role,
    required this.availability,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? 'N/A',
      address: json['address'] as String? ?? 'N/A',
      phone: json['phone']?.toString() ?? 'N/A',
      email: json['email'] as String? ?? 'N/A',
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 0.0,
      telegramChatId: json['telegram_chat_id']?.toString() ?? 'N/A',
      status: json['status'] as String? ?? 'N/A',
      language1: json['language_1'] as String? ?? 'N/A',
      language2: json['language_2'] as String? ?? 'N/A',
      country: json['country'] as String? ?? 'N/A',
      role: json['role'] as String? ?? 'N/A',
      availability: json['availability'] as String? ?? 'N/A',
    );
  }
}
