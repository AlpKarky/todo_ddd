import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/core/errors.dart';
import '../../domain/core/failures.dart';

@immutable
abstract class ValueObject<T> {
  const ValueObject();
  Either<ValueFailure<T>, T> get value;

  /// Throws [UnexpectedValueError] containing the [ValueFailure] if unable to get the value
  T getOrCrash() {
    // id = identity - same as (right) => right
    return value.fold((ValueFailure<T> l) => throw UnexpectedValueError(l), id);
  }

  bool isValid() => value.isRight();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValueObject<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return 'Value($value)';
  }
}
