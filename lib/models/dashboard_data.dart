class DashboardSummary {
  final int totalJobs;
  final int completedJobs;
  final int pendingJobs;
  final int totalHoursThisMonth;
  final int totalHoursAllTime;

  DashboardSummary({
    required this.totalJobs,
    required this.completedJobs,
    required this.pendingJobs,
    required this.totalHoursThisMonth,
    required this.totalHoursAllTime,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalJobs: json['total_jobs'] as int,
      completedJobs: json['completed_jobs'] as int,
      pendingJobs: json['pending_jobs'] as int,
      totalHoursThisMonth: json['total_hours_this_month'] as int,
      totalHoursAllTime: json['total_hours_all_time'] as int,
    );
  }
}

class Job {
  final String jobId;
  final String customerName;
  final String date;
  final String status;
  final int hours;
  final String address;

  Job({
    required this.jobId,
    required this.customerName,
    required this.date,
    required this.status,
    required this.hours,
    required this.address,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['job_id'] as String,
      customerName: json['customer_name'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      hours: json['hours'] as int,
      address: json['address'] as String,
    );
  }
}

class Invoice {
  final String customerName;
  final int invoiceNumber;
  final String issueDate;
  final String invoiceLink;

  Invoice({
    required this.customerName,
    required this.invoiceNumber,
    required this.issueDate,
    required this.invoiceLink,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      customerName: json['customer_name'] as String,
      invoiceNumber: json['invoice_number'] as int,
      issueDate: json['issue_date'] as String,
      invoiceLink: json['invoice_link'] as String,
    );
  }
}

class DashboardResponse {
  final bool success;
  final DashboardSummary summary;
  final List<Job> upcomingJobs;
  final List<Job> recentJobs;
  final List<Invoice> recentInvoices;

  DashboardResponse({
    required this.success,
    required this.summary,
    required this.upcomingJobs,
    required this.recentJobs,
    required this.recentInvoices,
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

    return DashboardResponse(
      success: data['success'] as bool,
      summary: DashboardSummary.fromJson(data['summary'] as Map<String, dynamic>),
      upcomingJobs: (data['upcoming_jobs'] as List)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentJobs: (data['recent_jobs'] as List)
          .map((e) => Job.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentInvoices: (data['recent_invoices'] as List?)
              ?.map((e) => Invoice.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
