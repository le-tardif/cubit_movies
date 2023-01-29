part of 'movie_cubit.dart';

@freezed
abstract class MovieState with _$MovieState {
  const factory MovieState.initial() = _Initial;
  const factory MovieState.loading() = _Loading;
  const factory MovieState.loaded(List<Movie> movies, bool hasReachedMax) = _Loaded;
  const factory MovieState.error(String message) = _Error;
}