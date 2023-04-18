enum Subscription {
  free,
  premium
}

extension ToString on Subscription {
  String toDisplayString() {
    switch (this) {
      case Subscription.free:
        return "Free";
      case Subscription.premium:
        return "Premium";
      default:
        return "Free";
    }
  }
}

Subscription toSubscriptionEnumValue(String value) {
  switch (value) {
    case "Free":
      return Subscription.free;
    case "Premium":
      return Subscription.premium;
    default:
      return Subscription.free;
  }
}