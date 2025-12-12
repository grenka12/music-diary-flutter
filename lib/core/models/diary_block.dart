abstract class DiaryBlock {
  final String id;

  DiaryBlock({required this.id});

  Map<String, dynamic> toJson();

  static DiaryBlock fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'text':
        return TextBlock(
          id: json['id'] as String,
          text: (json['text'] ?? '').toString(),
        );

      case 'song':
        return SongBlock(
          id: json['id'] as String,
          songId: json['songId'] as String,
        );

      default:
        throw "Unknown block type: ${json['type']}";
    }
  }
}

class TextBlock extends DiaryBlock {
  String text;

  TextBlock({required super.id, required this.text});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'text',
        'id': id,
        'text': text,
      };
}

class SongBlock extends DiaryBlock {
  final String songId;

  SongBlock({required super.id, required this.songId});

  @override
  Map<String, dynamic> toJson() => {
        'type': 'song',
        'id': id,
        'songId': songId,
      };
}
