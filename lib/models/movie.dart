class Movie {
  final int? id;
  final String title;
  final int duration;
  final String plot;
  final int year;

  Movie({
    this.id,
    required this.title,
    required this.duration,
    required this.plot,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'plot': plot,
      'year': year,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] as int?,
      title: map['title'] as String,
      duration: map['duration'] as int,
      plot: map['plot'] as String,
      year: map['year'] as int,
    );
  }

  Movie copyWith({
    int? id,
    String? title,
    int? duration,
    String? plot,
    int? year,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      plot: plot ?? this.plot,
      year: year ?? this.year,
    );
  }
}
