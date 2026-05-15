enum CommandType {
  keyboardPress,
  keyboardHold,
  macro,
  custom,
}

class Command {
  final String id;
  final String label;
  final String icon;
  final CommandType type;
  final Map<String, dynamic> payload;
  final String category;
  final String? description;
  final CommandType? longPressType;
  final Map<String, dynamic>? longPressPayload;

  const Command({
    required this.id,
    required this.label,
    required this.icon,
    required this.type,
    required this.payload,
    required this.category,
    this.description,
    this.longPressType,
    this.longPressPayload,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon,
      'type': type.name,
      'payload': payload,
      'category': category,
      'description': description,
      'longPressType': longPressType?.name,
      'longPressPayload': longPressPayload,
    };
  }

  factory Command.fromJson(Map<String, dynamic> json) {
    return Command(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      type: CommandType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CommandType.keyboardPress,
      ),
      payload: json['payload'] as Map<String, dynamic>,
      category: json['category'] as String,
      description: json['description'] as String?,
      longPressType: json['longPressType'] != null
          ? CommandType.values.firstWhere(
              (e) => e.name == json['longPressType'],
              orElse: () => CommandType.keyboardPress,
            )
          : null,
      longPressPayload: json['longPressPayload'] as Map<String, dynamic>?,
    );
  }

  Command copyWith({
    String? id,
    String? label,
    String? icon,
    CommandType? type,
    Map<String, dynamic>? payload,
    String? category,
    String? description,
    CommandType? longPressType,
    Map<String, dynamic>? longPressPayload,
  }) {
    return Command(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      category: category ?? this.category,
      description: description ?? this.description,
      longPressType: longPressType ?? this.longPressType,
      longPressPayload: longPressPayload ?? this.longPressPayload,
    );
  }
}
