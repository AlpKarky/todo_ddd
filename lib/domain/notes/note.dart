import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/failures.dart';
import '../core/value_objects.dart';
import 'todo_item.dart';
import 'value_objects.dart';

part 'note.freezed.dart';

@freezed
abstract class Note implements _$Note {
  const Note._();

  const factory Note(
      {required UniqueId id,
      required NoteBody body,
      required NoteColor color,
      required List3<TodoItem> todos}) = _Note;

  factory Note.empty() => Note(
      id: UniqueId(),
      body: NoteBody(''),
      color: NoteColor(NoteColor.predefinedColors.first),
      todos: List3(const []));

  Option<ValueFailure<dynamic>> get failureOption {
    return body.failureOrUnit
        .andThen(todos.failureOrUnit)
        .andThen(todos
            .getOrCrash()
            .map((todoItem) => todoItem.failureOption)
            .firstWhere((o) => o.isSome(), orElse: none)
            .fold(() => right(unit), left))
        .fold(some, (_) => none());
  }
}
