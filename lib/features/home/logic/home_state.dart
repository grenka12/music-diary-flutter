enum HomeStatus { loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final List entries; // DiaryEntry list
  final String? error;

  const HomeState({
    required this.status,
    required this.entries,
    this.error,
  });

  HomeState copyWith({
    HomeStatus? status,
    List? entries,
    String? error,
  }) {
    return HomeState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      error: error ?? this.error,
    );
  }
}
