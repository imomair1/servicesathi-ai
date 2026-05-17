class ServiceProvider {
  final String id;
  final String name;
  final String nameUrdu;
  final String serviceType;
  final String specialty;
  final String city;
  final String area;
  final double rating;
  final int totalReviews;
  final int priceMin;
  final int priceMax;
  final int experienceYears;
  final bool verified;
  final String imageUrl;
  final double distance;
  final int aiMatchScore;
  final String aiReasoning;
  final bool available;
  final String estimatedArrival;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.nameUrdu,
    required this.serviceType,
    required this.specialty,
    required this.city,
    required this.area,
    required this.rating,
    required this.totalReviews,
    required this.priceMin,
    required this.priceMax,
    required this.experienceYears,
    required this.verified,
    required this.imageUrl,
    required this.distance,
    required this.aiMatchScore,
    required this.aiReasoning,
    required this.available,
    required this.estimatedArrival,
  });
}

class Booking {
  final String id;
  final String providerId;
  final String providerName;
  final String serviceType;
  final String status;
  final String scheduledTime;
  final int estimatedCost;
  final String aiReasoning;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    required this.status,
    required this.scheduledTime,
    required this.estimatedCost,
    required this.aiReasoning,
    required this.createdAt,
  });
}

class AgentStep {
  final String agentName;
  final String agentIcon;
  final String action;
  final String status; // pending, running, completed, error
  final int durationMs;
  final double confidence;
  final String outputSummary;
  final Map<String, String> details;

  const AgentStep({
    required this.agentName,
    required this.agentIcon,
    required this.action,
    required this.status,
    required this.durationMs,
    required this.confidence,
    required this.outputSummary,
    this.details = const {},
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // booking, reminder, ai_insight, system
  final DateTime? time;
  final bool read;
  final String? icon;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    required this.read,
    this.icon,
  });
}

class IntentResult {
  final String serviceType;
  final String location;
  final String urgency;
  final String? budgetRange;
  final String? preferredTime;
  final String language;
  final double confidence;

  const IntentResult({
    required this.serviceType,
    required this.location,
    required this.urgency,
    this.budgetRange,
    this.preferredTime,
    required this.language,
    required this.confidence,
  });
}
