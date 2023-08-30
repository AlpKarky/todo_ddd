import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/notes/i_note_repository.dart';
import '../../domain/notes/note.dart';
import '../../domain/notes/note_failure.dart';
import '../core/firestore_helpers.dart';
import 'note_dtos.dart';

@LazySingleton(as: INoteRepository)
class NoteRepository implements INoteRepository {
  final FirebaseFirestore _firestore;

  NoteRepository(this._firestore);
  @override
  Stream<Either<NoteFailure, List<Note>>> watchAll() async* {
    final userDoc = await _firestore.userDocument();
    yield* userDoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map((snapshot) => right<NoteFailure, List<Note>>(snapshot.docs
            .map((doc) => NoteDTO.fromFirestore(doc.data()
                    as DocumentSnapshot<Map<String, dynamic>>) //TODO:Check!
                .toDomain())
            .toList()))
        .onErrorReturnWith(
      (error, stackTrace) {
        if (error is FirebaseException &&
            error.message != null &&
            error.message!.contains('permission-denied')) {
          return left(const NoteFailure.insufficientPermissions());
        } else {
          //log('Unexpected Error: ${error.toString()}');
          return left(const NoteFailure.unExpected());
        }
      },
    );
  }

  @override
  Stream<Either<NoteFailure, List<Note>>> watchUncompleted() async* {
    final userDoc = await _firestore.userDocument();
    yield* userDoc.noteCollection
        .orderBy('serverTimeStamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => NoteDTO.fromFirestore(doc
                .data() as DocumentSnapshot<Map<String, dynamic>>) //TODO:Check!
            .toDomain()))
        .map(
          (notes) => right<NoteFailure, List<Note>>(
            notes
                .where((note) =>
                    note.todos.getOrCrash().any((todoItem) => !todoItem.isDone))
                .toList(),
          ),
        )
        .onErrorReturnWith(
      (error, stackTrace) {
        if (error is FirebaseException &&
            error.message != null &&
            error.message!.contains('permission-denied')) {
          return left(const NoteFailure.insufficientPermissions());
        } else {
          //log('Unexpected Error: ${error.toString()}');
          return left(const NoteFailure.unExpected());
        }
      },
    );
  }

  @override
  Future<Either<NoteFailure, Unit>> create(Note note) async {
    try {
      final userDoc = await _firestore.userDocument();
      final noteDTO = NoteDTO.fromDomain(note);

      await userDoc.noteCollection.doc(noteDTO.noteId).set(noteDTO.toJson());

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.message != null && e.message!.contains('permission-denied')) {
        return left(const NoteFailure.insufficientPermissions());
      } else {
        return left(const NoteFailure.unExpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> update(Note note) async {
    try {
      final userDoc = await _firestore.userDocument();
      final noteDTO = NoteDTO.fromDomain(note);

      await userDoc.noteCollection.doc(noteDTO.noteId).update(noteDTO.toJson());

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.message != null && e.message!.contains('permission-denied')) {
        return left(const NoteFailure.insufficientPermissions());
      } else if (e.message != null && e.message!.contains('not-found')) {
        return left(const NoteFailure.unableToUpdate());
      } else {
        return left(const NoteFailure.unExpected());
      }
    }
  }

  @override
  Future<Either<NoteFailure, Unit>> delete(Note note) async {
    try {
      final userDoc = await _firestore.userDocument();
      final noteId = note.id.getOrCrash();

      await userDoc.noteCollection.doc(noteId).delete();

      return right(unit);
    } on FirebaseException catch (e) {
      if (e.message != null && e.message!.contains('permission-denied')) {
        return left(const NoteFailure.insufficientPermissions());
      } else if (e.message != null && e.message!.contains('not-found')) {
        return left(const NoteFailure.unableToUpdate());
      } else {
        return left(const NoteFailure.unExpected());
      }
    }
  }
}
