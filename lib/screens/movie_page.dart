import 'package:cached_network_image/cached_network_image.dart';
import 'package:cubit_movies/store/movies/movie_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final _scrollController = ScrollController();
  final _scrollThreshold = 200.0;

  _MoviesPageState() {
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          const SliverAppBar(
            pinned: true,
            expandedHeight: 160.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('SliverAppBar'),
              background: FlutterLogo(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 20,
              child: Center(
                child: Text('Scroll to see the SliverAppBar in effect.'),
              ),
            ),
          ),
          BlocBuilder<MoviesCubit, MovieState>(
            builder: (context, state) {
              return state.when(error: (message) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return const Center(
                      child: BottomLoader(),
                    );
                  }, childCount: 1),
                );
              }, loading: () {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return const Center(
                      child: BottomLoader(),
                    );
                  }, childCount: 1),
                );
              }, loaded: (movies, hasReachedMax) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return index >= movies.length
                          ? Skeletons(context)
                          : Card(
                              child: ListTile(
                              title: Text(movies[index].title),
                              subtitle: Text(movies[index].description),
                              leading: CachedNetworkImage(
                                imageUrl: movies[index].urlImage,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                            value: downloadProgress.progress),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              trailing: PopupMenuButton<int>(
                                onSelected: (int result) {
                                  context
                                      .read<MoviesCubit>()
                                      .deleteMovie(movies[index]);
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<int>>[
                                  const PopupMenuItem<int>(
                                      value: 0,
                                      child: ListTile(
                                          leading: Icon(
                                            Icons.delete_outline_rounded,
                                            color: Colors.red,
                                          ),
                                          title: Text('Delete'))),
                                ],
                              ),
                            ));
                    },
                    childCount:
                        hasReachedMax ? movies.length + 1 : movies.length,
                  ),
                );
              }, initial: () {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return const Center(
                      child: BottomLoader(),
                    );
                  }, childCount: 1),
                );
              });
            },
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      // _postBloc.dispatch(Fetch());
      MoviesCubit cubit = context.read<MoviesCubit>();
      cubit.getAll(from: cubit.from + 1);
    }
  }
}

class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}

Widget Skeletons(context) {
  List<Widget> list = [];

  for (int i = 0; i < 10; i++) {
    list.add(Card(
        child: SkeletonListTile(
      contentSpacing: 6,
      verticalSpacing: 6,
      padding: EdgeInsets.all(16),
      leadingStyle: SkeletonAvatarStyle(
          width: 32,
          height: 50,
          borderRadius: BorderRadius.circular(4),
          padding: const EdgeInsets.only(right: 10)),
      titleStyle:
          SkeletonLineStyle(borderRadius: BorderRadius.circular(4), height: 10),
      subtitleStyle: SkeletonLineStyle(
          borderRadius: BorderRadius.circular(4),
          randomLength: true,
          minLength: MediaQuery.of(context).size.width / 3,
          maxLength: MediaQuery.of(context).size.width / 2),
      hasSubtitle: true,
    )));
  }

  return Column(children: list);
}
