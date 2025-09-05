
class Todo {
  // 1.attributes
  final String id;
  final String title;
  final String? description;
  final DateTime? deadline;
  final bool isCompleted;

  // 2.constructor
  const Todo({
    required this.id,
    required this.title,
    this.description,
    this.deadline,
    this.isCompleted = false,
  });

  // 3.copyWith method WHY??
  // It allows you to create a new instance of the class with some properties changed while keeping the rest unchanged.
  // your attributes is final (immutable) so you can't change them directly after the object is created.
  // Instead, you create a new instance with the desired changes using copyWith.

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // <!..... shared_preferences : save data in phone storage .....!>
  // storage don't match with object  so we need to convert object into String then return to object
  // <serialization // deserialization>
  // serialization (encode) = object → Map → String.
  //    ... converting an object into a format that can be easily stored or transmitted.
  // deserialization (decode) = String → Map → object.
  //    ... converting the stored or transmitted format back into an object.

  // Deserialization

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  // JSON deserialization
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
  // <!.... go to service to complete storage handling ....!>

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Todo &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.deadline == deadline &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      deadline.hashCode ^
      isCompleted.hashCode;

  @override
  String toString() =>
      'Todo(id: $id, title: $title, description: $description, deadline: $deadline, isCompleted: $isCompleted)';
}