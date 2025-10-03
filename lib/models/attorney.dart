class Attorney {
  final int? id;
  final String name;
  final String n8nWebhookUrl;
  final int? phone;

  Attorney({
    this.id,
    required this.name,
    required this.n8nWebhookUrl,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'n8n_webhook_url': n8nWebhookUrl,
      'phone': phone,
    };
  }

  factory Attorney.fromMap(Map<String, dynamic> map) {
    return Attorney(
      id: map['id'] as int?,
      name: map['name'] as String,
      n8nWebhookUrl: map['n8n_webhook_url'] as String,
      phone: map['phone'] as int?,
    );
  }
}