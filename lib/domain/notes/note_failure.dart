import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_failure.freezed.dart';

@freezed
abstract class NoteFailure with _$NoteFailure {
  const factory NoteFailure.unExpected() = _UnExpected;
  const factory NoteFailure.insufficientPermissions() =
      _InsufficientPermissions;
}
