extension ListExtension<T> on List<T> {
  T get firstOrNull => this == null || isEmpty ? null : first;
}
