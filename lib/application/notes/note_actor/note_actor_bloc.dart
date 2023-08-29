import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/notes/i_note_repository.dart';
import '../../../domain/notes/note.dart';
import '../../../domain/notes/note_failure.dart';

part 'note_actor_event.dart';
part 'note_actor_state.dart';

part 'note_actor_bloc.freezed.dart';

@injectable
class NoteActorBloc extends Bloc<NoteActorEvent, NoteActorState> {
  final INoteRepository _noteRepository;
  NoteActorBloc(this._noteRepository) : super(const NoteActorState.initial()) {
    on<NoteActorEvent>((event, emit) async {
      emit(const NoteActorState.actionInProgress());
      final deletionOrFailure = await _noteRepository.delete(event.note);
      emit(deletionOrFailure.fold(
        (failure) => NoteActorState.deleteFailure(failure),
        (_) => const NoteActorState.deleteSuccess(),
      ));
    });
  }
}
