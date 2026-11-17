import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'viewmodels/movie_view_model.dart';
import 'views/movie_list_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MovieViewModel(),
      child: MaterialApp(
        title: 'Movie SQLite MVVM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const MovieListView(),
      ),
    );
  }
}
