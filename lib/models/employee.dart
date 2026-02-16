class Employee {
  final String rowNumber;
  final String name;
  final String email;

  Employee({required this.rowNumber, required this.name, required this.email});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      rowNumber: json['row_number'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}

class LoginResponse {
  final bool success;
  final Employee employee;
  final String token;

  LoginResponse({
    required this.success,
    required this.employee,
    required this.token,
  });

  factory LoginResponse.fromJson(dynamic jsonResponse) {
    // Handle the list wrapping
    final Map<String, dynamic> data;
    if (jsonResponse is List) {
      if (jsonResponse.isEmpty) throw Exception('Empty response list');
      data = jsonResponse[0] as Map<String, dynamic>;
    } else {
      data = jsonResponse as Map<String, dynamic>;
    }

    return LoginResponse(
      success: data['success'] as bool,
      employee: Employee.fromJson(data['employee'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}
