class DashboardSummary {
  final int totalJobs;
  final int completedJobs;
  final int pendingJobs;
  final int runningJobs;
  final int cancelledJobs;
  final double totalHoursThisMonth;
  final double totalHoursAllTime;

  DashboardSummary({
    required this.totalJobs,
    required this.completedJobs,
    required this.pendingJobs,
    required this.runningJobs,
    required this.cancelledJobs,
    required this.totalHoursThisMonth,
    required this.totalHoursAllTime,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalJobs: (json['total_jobs'] as num).toInt(),
      completedJobs: (json['completed_jobs'] as num).toInt(),
      pendingJobs: (json['pending_jobs'] as num).toInt(),
      runningJobs: (json['running_jobs'] as num?)?.toInt() ?? 0,
      cancelledJobs: (json['cancelled_jobs'] as num?)?.toInt() ?? 0,
      totalHoursThisMonth: (json['total_hours_this_month'] as num).toDouble(),
      totalHoursAllTime: (json['total_hours_all_time'] as num).toDouble(),
    );
  }
}

class Job {
  final String jobId;
  final String customerName;
  final String date;
  final String status;
  final double hours;
  final String address;
  final String? customerStartTime;
  final String? customerStopTime;
  final String? employeeStartTime;
  final String? employeeEndTime;
  final double? employeeTotalHours;
  final String? cancelledDateTime;

  Job({
    required this.jobId,
    required this.customerName,
    required this.date,
    required this.status,
    required this.hours,
    required this.address,
    this.customerStartTime,
    this.customerStopTime,
    this.employeeStartTime,
    this.employeeEndTime,
    this.employeeTotalHours,
    this.cancelledDateTime,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['job_id'] as String,
      customerName: json['customer_name'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      hours: (json['hours'] as num).toDouble(),
      address: json['address'] as String,
      customerStartTime: json['customer_start_time'] as String?,
      customerStopTime: json['customer_stop_time'] as String?,
      employeeStartTime: json['employee_start_time'] as String?,
      employeeEndTime: json['employee_end_time'] as String?,
      employeeTotalHours: (json['employee_total_hours'] as num?)?.toDouble(),
      cancelledDateTime: json['cancelled_date_time'] as String?,
    );
  }
}


class DashboardResponse {
  final bool success;
  final DashboardSummary summary;
  final List<Job> upcomingJobs; // This might be map to pending_jobs in new schema
  final List<Job> recentJobs;   // This might be map to completed_jobs in new schema
  final List<Job> completedJobs;
  final List<Job> pendingJobs;
  final List<Job> runningJobs;
  final List<Job> cancelledJobs;

  DashboardResponse({
    required this.success,
    required this.summary,
    required this.upcomingJobs,
    required this.recentJobs,
    required this.completedJobs,
    required this.pendingJobs,
    required this.runningJobs,
    required this.cancelledJobs,
  });

  factory DashboardResponse.fromJson(dynamic jsonResponse) {
    // Handle the list wrapping
    final Map<String, dynamic> data;
    if (jsonResponse is List) {
      if (jsonResponse.isEmpty) throw Exception('Empty response list');
      data = jsonResponse[0] as Map<String, dynamic>;
    } else {
      data = jsonResponse as Map<String, dynamic>;
    }

    final List<Job> completed = (data['completed_jobs'] as List?)
            ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final List<Job> pending = (data['pending_jobs'] as List?)
            ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final List<Job> running = (data['running_jobs'] as List?)
            ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final List<Job> cancelled = (data['cancelled_jobs'] as List?)
            ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DashboardResponse(
      success: data['success'] as bool,
      summary:
          DashboardSummary.fromJson(data['summary'] as Map<String, dynamic>),
      completedJobs: completed,
      pendingJobs: pending,
      runningJobs: running,
      cancelledJobs: cancelled,
      // For backward compatibility or renamed fields
      upcomingJobs: (data['upcoming_jobs'] as List?)
              ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
              .toList() ??
          pending,
      recentJobs: (data['recent_jobs'] as List?)
              ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
              .toList() ??
          completed,
    );
  }
}
