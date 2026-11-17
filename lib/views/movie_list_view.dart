import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../viewmodels/movie_view_model.dart';
import 'movie_form_view.dart';

class MovieListView extends StatefulWidget {
  const MovieListView({super.key});

  @override
  State<MovieListView> createState() => _MovieListViewState();
}

class _MovieListViewState extends State<MovieListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MovieViewModel>().loadMovies();
    });
  }

  Future<void> _openForm({Movie? movie}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieFormView(movie: movie),
      ),
    );
  }

  Future<void> _confirmDelete(Movie movie) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina film'),
        content: Text('Vuoi eliminare "${movie.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirmed == true && movie.id != null && mounted) {
      await context.read<MovieViewModel>().deleteMovie(movie.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('I miei film'),
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null && viewModel.movies.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(viewModel.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: viewModel.loadMovies,
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (viewModel.movies.isEmpty) {
            return const Center(
              child: Text(
                'Nessun film presente.\nAggiungine uno con il pulsante +',
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.loadMovies,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: viewModel.movies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final movie = viewModel.movies[index];
                return Card(
                  child: ListTile(
                    title: Text(movie.title),
                    subtitle: Text(
                      '${movie.year} • ${movie.duration} min\n${movie.plot}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    onTap: () => _openForm(movie: movie),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(movie),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
