import 'dart:ui';

class IndustryIdentifierModel{
  final String type;
  final String identifier;

  const IndustryIdentifierModel({
    required this.type,
    required this.identifier,
  });

  factory IndustryIdentifierModel.fromJson(Map<String, dynamic> json) {
    return IndustryIdentifierModel(
      type: json['type'] as String? ?? '', // nullチェックを追加
      identifier: json['identifier'] as String? ?? '', // nullチェックを追加
    );
  }
}

class ImageLinksModel{
  final String thumbnail;
  final String smallThumbnail;

  const ImageLinksModel({
    required this.thumbnail,
    required this.smallThumbnail,
  });

  factory ImageLinksModel.fromJson(Map<String, dynamic> json) {
    return ImageLinksModel(
      thumbnail: json['thumbnail'] as String ? ?? '', // nullチェックを追加
      smallThumbnail: json['smallThumbnail'] as String ? ?? '', // nullチェックを追加
    );
  }
}

class VolumeInfoModel{
  final String title;
  final List<String> authors; // APIではリストだが、nullableにしておく
  final String? publishedDate;
  final String? description;
  final ImageLinksModel? imageLinks; // ネストしたモデル
  final int? pageCount;
  final List<IndustryIdentifierModel> industryIdentifiers; // ネストしたモデルのリスト

  const VolumeInfoModel({
    required this.title,
    required this.authors,
    this.publishedDate,
    this.description,
    this.imageLinks,
    this.pageCount,
    required this.industryIdentifiers,
  });

  factory VolumeInfoModel.fromJson(Map<String, dynamic> json) {
    return VolumeInfoModel(
      title: json['title'] as String? ?? '', // nullチェックを追加
      authors: (json['authors'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [], // nullチェックを追加
      publishedDate: json['publishedDate'] as String?, // nullチェックを追加
      description: json['description'] as String?, // nullチェックを追加
      imageLinks: json['imageLinks'] != null ? ImageLinksModel.fromJson(json['imageLinks']) : null, // nullチェックを追加
      pageCount: json['pageCount'] as int?, // nullチェックを追加
      industryIdentifiers: (json['industryIdentifiers'] as List<dynamic>?)?.map((e) => IndustryIdentifierModel.fromJson(e)).toList() ?? [], // nullチェックを追加
    );
  }
}

class SerchedBookModel{
  final String id;
  final VolumeInfoModel volumeInfo;

  const SerchedBookModel({
    required this.id,
    required this.volumeInfo,
  });

  factory SerchedBookModel.fromJson(Map<String, dynamic> json) {
    if(json['volumeInfo'] == null) {
      print('volumeInfo is null');
      return SerchedBookModel(
          id: json['id'] as String? ?? '',
          volumeInfo: const VolumeInfoModel(title: 'タイトル不明', authors: [], industryIdentifiers: [])
      );
    }
    return SerchedBookModel(
      id: json['id'] as String? ?? '', // nullチェックを追加
      volumeInfo: VolumeInfoModel.fromJson(json['volumeInfo']), // nullチェックを追加
    );
  }
}