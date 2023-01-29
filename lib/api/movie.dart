import 'dart:convert';

import 'package:cubit_movies/models/movie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class MovieRepository {
  const MovieRepository(this.client);

  final Dio client;

  Future<dynamic> readJson() async {
    //print("Read json");
    final String response = await rootBundle.loadString('assets/fakedata.json');
    //print(response);
    final data = await jsonDecode(response);
    return data;
  }

  Future<List<Movie>> getAll({int from = 0}) async {
    try {
      final response = await readJson();

      await Future.delayed(const Duration(seconds: 2));

      final movies = List<Movie>.of(
        // Add .data to response if using Dio
        response['results'].map<Movie>((json) {
          // debugPrint("id ${json['id']}");
          String path = json['poster_path'];
          return Movie(
            id: json['id'],
            title: json['title'],
            description: json['overview'],
            urlImage: 'https://image.tmdb.org/t/p/w185$path',
          );
        }),
      );

      return movies;
    } catch (e) {
      rethrow;
    }
  }
}
