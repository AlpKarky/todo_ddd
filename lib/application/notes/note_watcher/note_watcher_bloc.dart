import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/notes/i_note_repository.dart';
import '../../../domain/notes/note.dart';
import '../../../domain/notes/note_failure.dart';

part 'note_watcher_bloc.freezed.dart';
part 'note_watcher_event.dart';
part 'note_watcher_state.dart';

@injectable
class NoteWatcherBloc extends Bloc<NoteWatcherEvent, NoteWatcherState> {
  final INoteRepository _noteRepository;

  late StreamSubscription<Either<NoteFailure, List<Note>>>?
      _noteStreamSubscription;

  NoteWatcherBloc(this._noteRepository)
      : super(const NoteWatcherState.initial()) {
    on<NoteWatcherEvent>((event, emit) async {
      await event.map(
          watchAllStarted: (event) async => await _watchAllStarted(event, emit),
          watchUncompletedStarted: (event) async =>
              await _watchUncompletedStarted(event, emit),
          notesReceived: (event) async => await _notesReceived(event, emit));
    });
  }

  Future<void> _watchAllStarted(
      _WatchAllStarted event, Emitter<NoteWatcherState> emit) async {
    emit(const NoteWatcherState.loadInProgress());

    await _noteStreamSubscription?.cancel();
    _noteStreamSubscription = _noteRepository.watchAll().listen(
        (failureOrNotes) =>
            add(NoteWatcherEvent.notesReceived(failureOrNotes)));
  }

  Future<void> _watchUncompletedStarted(
      _WatchUncompletedStarted event, Emitter<NoteWatcherState> emit) async {
    emit(const NoteWatcherState.loadInProgress());

    await _noteStreamSubscription?.cancel();
    _noteStreamSubscription = _noteRepository.watchUncompleted().listen(
        (failureOrNotes) =>
            add(NoteWatcherEvent.notesReceived(failureOrNotes)));
  }

  Future<void> _notesReceived(
      _NotesReceived event, Emitter<NoteWatcherState> emit) async {
    emit(
      event.failureOrNotes.fold(
        (f) => NoteWatcherState.loadFailure(f),
        (notes) => NoteWatcherState.loadSuccess(notes),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _noteStreamSubscription?.cancel();
    return super.close();
  }
}
