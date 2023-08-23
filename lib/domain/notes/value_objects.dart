import 'dart:ui';

import 'package:dartz/dartz.dart';

import '../core/failures.dart';
import '../core/value_objects.dart';
import '../core/value_transformers.dart';
import '../core/value_validators.dart';

class NoteBody extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  static const maxLength = 1000;

  factory NoteBody(String input) {
    return NoteBody._(validateMaxStringLength(input, maxLength)
        .flatMap(validateStringNotEmpty));
  }
  const NoteBody._(this.value);
}

class TodoName extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> value;

  static const maxLength = 30;

  factory TodoName(String input) {
    return TodoName._(validateMaxStringLength(input, maxLength)
        .flatMap(validateStringNotEmpty)
        .flatMap(validateSingleLine));
  }
  const TodoName._(this.value);
}

class NoteColor extends ValueObject<Color> {
  static const List<Color> predefinedColors = [
    Color(0xfffafafa),
    Color(0xfffa8072),
    Color(0xfffedc56),
    Color(0xffd0f0c0),
    Color(0xfffca3b7),
    Color(0xff997950),
    Color(0xfffffdd0),
  ];

  @override
  final Either<ValueFailure<Color>, Color> value;

  factory NoteColor(Color input) {
    return NoteColor._(right(makeColorOpaque(input)));
  }
  const NoteColor._(this.value);
}

class List3<T> extends ValueObject<List<T>> {
  @override
  final Either<ValueFailure<List<T>>, List<T>> value;

  static const maxLength = 3;

  factory List3(List<T> input) {
    return List3._(validateMaxListLength(input, maxLength));
  }
  const List3._(this.value);

  int get length => value.getOrElse(() => []).length;

  bool get isFull => length == maxLength;
}
