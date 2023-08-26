import 'package:dartz/dartz.dart';

import 'note.dart';
import 'note_failure.dart';

abstract class INoteRepository {
  Stream<Either<NoteFailure, List<Note>>> watchAll();
  Stream<Either<NoteFailure, List<Note>>> watchUncompleted();
  Future<Either<NoteFailure, Unit>> create(Note note);
  Future<Either<NoteFailure, Unit>> update(Note note);
  Future<Either<NoteFailure, Unit>> delete(Note note);
}
