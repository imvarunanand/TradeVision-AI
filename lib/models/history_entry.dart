class HistoryEntry {
  final int? id;
  final String pair;
  final double price;
  final String signal;
  final double confidence;
  final DateTime updatedAt;

  HistoryEntry({this.id, required this.pair, required this.price, required this.signal, required this.confidence, required this.updatedAt});
}
