import 'package:cubit_movies/models/movie.dart';
import 'package:cubit_movies/api/movie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_state.dart';
part 'movie_cubit.freezed.dart';

class MoviesCubit extends Cubit<MovieState> {
  MoviesCubit({required this.movies}) : super(const MovieState.initial()) {
    getAll();
  }

  final MovieRepository movies;
  List<Movie> _movies = [];
  bool hasReachedMax = false;
  int from = 0;
// List<Apple>.from(Appless)..remove(appleToDelete)
  Future<void> getAll({int from = 0}) async {
    try {
      from = from;
      emit(MovieState.loaded(_movies, true));
      final allMovies = await movies.getAll();
      if (from == 0) {
        _movies = allMovies;
      } else {
        _movies = [..._movies, ...allMovies];
      }

      await Future.delayed(const Duration(seconds: 2));
      emit(MovieState.loaded(_movies, false));
    } catch (e) {
      emit(MovieState.error(e.toString()));
    }
  }

  Future<void> deleteMovie(Movie movie) async {
    int idx = _movies.indexWhere((element) => element.id == movie.id);

    if (idx > -1) {
      emit(MovieState.loaded(_movies, true));
      _movies.removeAt(idx);
      emit(MovieState.loaded(_movies, false));
    }
  }
}
