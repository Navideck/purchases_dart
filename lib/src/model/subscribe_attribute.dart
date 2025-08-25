class SubscriberAttribute {
  final String key;
  final String? value;
  final DateTime setTime;

  SubscriberAttribute(this.key, this.value) : setTime = DateTime.now();

  Map<String, dynamic> toBackendMap() {
    return {
      "value": value,
      "updated_at_ms": setTime.millisecondsSinceEpoch,
    };
  }
}
