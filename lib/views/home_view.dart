import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../viewmodels/movie_view_model.dart';
import 'movie_form_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();
  bool _hasRequestedMovies = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      final viewModel = context.read<MovieViewModel>();
      await viewModel.deleteMovie(movie.id!);
      if (_searchController.text.isNotEmpty && mounted) {
        viewModel.filterMovies(_searchController.text);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hasRequestedMovies) return;
      _hasRequestedMovies = true;
      context.read<MovieViewModel>().fecthMovies();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Collection APP'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Cerca film',
                hintText: 'Titolo o trama',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                context.read<MovieViewModel>().filterMovies(query);
              },
            ),
          ),
          Expanded(
            child: Consumer<MovieViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.movies.isEmpty) {
                  return const Center(
                    child: Text(
                      'Non hai inserito alcun film',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  );
                }

                if (viewModel.filteredMovies.isEmpty) {
                  return const Center(
                    child: Text('Nessun film trovato per questa ricerca'),
                  );
                }

                return RefreshIndicator(
                  onRefresh: viewModel.fecthMovies,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: viewModel.filteredMovies.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final movie = viewModel.filteredMovies[index];
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
