// app/lib/core/models/analytics_event.dart

class AnalyticsEvent {
  final String? id;
  final String? userId;
  final String? sessionId;
  final String eventName;
  final String category;
  final Map<String, dynamic> properties;
  final DateTime createdAt;

  AnalyticsEvent({
    this.id,
    this.userId,
    this.sessionId,
    required this.eventName,
    required this.category,
    this.properties = const {},
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      sessionId: json['session_id'] as String?,
      eventName: json['event_name'] as String? ?? 'unknown',
      category: json['category'] as String? ?? 'general',
      properties: (json['properties'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      'event_name': eventName,
      'category': category,
      'properties': properties,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class DeveloperKpiSummary {
  final int totalUsers;
  final int activeUsers;
  final int listsCreated;
  final int routesCompleted;
  final int openErrors;
  final int couponsSynced;
  final double avgSessionSeconds;

  const DeveloperKpiSummary({
    this.totalUsers = 0,
    this.activeUsers = 0,
    this.listsCreated = 0,
    this.routesCompleted = 0,
    this.openErrors = 0,
    this.couponsSynced = 0,
    this.avgSessionSeconds = 0.0,
  });

  factory DeveloperKpiSummary.fromJson(Map<String, dynamic> json) {
    return DeveloperKpiSummary(
      totalUsers: (json['total_users'] as num?)?.toInt() ?? 0,
      activeUsers: (json['active_users'] as num?)?.toInt() ?? 0,
      listsCreated: (json['lists_created'] as num?)?.toInt() ?? 0,
      routesCompleted: (json['routes_completed'] as num?)?.toInt() ?? 0,
      openErrors: (json['open_errors'] as num?)?.toInt() ?? 0,
      couponsSynced: (json['coupons_synced'] as num?)?.toInt() ?? 0,
      avgSessionSeconds: (json['avg_session_seconds'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ClickStatsSummary {
  final Map<String, int> viewsPerScreen;
  final Map<String, int> clicksPerFeature;
  final int totalScreenViews;
  final int totalButtonClicks;

  const ClickStatsSummary({
    required this.viewsPerScreen,
    required this.clicksPerFeature,
    required this.totalScreenViews,
    required this.totalButtonClicks,
  });
}

class UserActivityProfile {
  final String userId;
  final String pseudonym;
  final DateTime registeredAt;
  final DateTime lastActiveAt;
  final int sessionCount;
  final int totalClicks;
  final int listsCreated;
  final int routesCompleted;
  final int connectedAppsCount;
  final List<AnalyticsEvent> recentActivity;

  const UserActivityProfile({
    required this.userId,
    required this.pseudonym,
    required this.registeredAt,
    required this.lastActiveAt,
    required this.sessionCount,
    required this.totalClicks,
    required this.listsCreated,
    required this.routesCompleted,
    required this.connectedAppsCount,
    required this.recentActivity,
  });
}

