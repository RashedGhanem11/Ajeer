class SubscriptionPlan {
  final int id;
  final String name;
  final double price;
  final int durationInDays;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.durationInDays,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationInDays: json['durationInDays'] ?? 0,
    );
  }
}

class SubscriptionStatus {
  final bool hasActiveSubscription;
  final DateTime? expiryDate;
  final String? planName;
  final bool isProviderActive;

  SubscriptionStatus({
    required this.hasActiveSubscription,
    this.expiryDate,
    this.planName,
    required this.isProviderActive,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      hasActiveSubscription: json['hasActiveSubscription'] ?? false,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      planName: json['planName'],
      isProviderActive: json['isProviderActive'] ?? false,
    );
  }
}

class PaymentIntentData {
  final String clientSecret;
  final String publishableKey;

  PaymentIntentData({required this.clientSecret, required this.publishableKey});

  factory PaymentIntentData.fromJson(Map<String, dynamic> json) {
    return PaymentIntentData(
      clientSecret: json['clientSecret'] ?? '',
      publishableKey: json['publishableKey'] ?? '',
    );
  }
}
