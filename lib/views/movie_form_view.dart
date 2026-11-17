import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../viewmodels/movie_view_model.dart';

class MovieFormView extends StatefulWidget {
  final Movie? movie;

  const MovieFormView({super.key, this.movie});

  @override
  State<MovieFormView> createState() => _MovieFormViewState();
}

class _MovieFormViewState extends State<MovieFormView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _durationController;
  late final TextEditingController _plotController;
  late final TextEditingController _yearController;

  bool get _isEditing => widget.movie != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie?.title ?? '');
    _durationController = TextEditingController(
      text: widget.movie?.duration.toString() ?? '',
    );
    _plotController = TextEditingController(text: widget.movie?.plot ?? '');
    _yearController = TextEditingController(
      text: widget.movie?.year.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _plotController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;

    final movie = Movie(
      id: widget.movie?.id,
      title: _titleController.text.trim(),
      duration: int.parse(_durationController.text.trim()),
      plot: _plotController.text.trim(),
      year: int.parse(_yearController.text.trim()),
    );

    final viewModel = context.read<MovieViewModel>();
    final success = _isEditing
        ? await viewModel.updateMovie(movie)
        : await viewModel.addMovie(movie);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.error ?? 'Operazione non riuscita')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifica film' : 'Nuovo film'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titolo',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci il titolo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Durata (minuti)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci la durata';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Inserisci un numero valido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _yearController,
              decoration: const InputDecoration(
                labelText: 'Anno',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci l\'anno';
                }
                if (int.tryParse(value.trim()) == null) {
                  return 'Inserisci un numero valido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _plotController,
              decoration: const InputDecoration(
                labelText: 'Trama',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Inserisci la trama';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saveMovie,
              child: Text(_isEditing ? 'Salva modifiche' : 'Aggiungi film'),
            ),
          ],
        ),
      ),
    );
  }
}
