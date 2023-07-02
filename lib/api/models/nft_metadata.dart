class NftMetadata {
  final String name;
  final String description;
  final String image;
  final int totalSupply;
  final String id;
  final String owner;

  NftMetadata({
    required this.name,
    required this.description,
    required this.image,
    required this.totalSupply,
    required this.id,
    required this.owner,
  });

  factory NftMetadata.fromDb(Map<String, dynamic> data) {
    final _name = data["name"] as String;
    final _description = data["description"] as String;
    final _image = data["image"] as String;
    final _totalSupply = int.tryParse(data["totalSupply"]) ?? 1;
    final _id = data["tokenId"] as String;
    final _owner = data["owner"] as String;
    return NftMetadata(
      name: _name,
      description: _description,
      image: _image,
      totalSupply: _totalSupply,
      id: _id,
      owner: _owner,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'totalSupply': totalSupply,
      'id': id,
      'owner': owner,
    };
  }

  Map<String, dynamic> toDB() {
    return {
      'tokenId': id,
      'name': name,
      'description': description,
      'totalSupply': totalSupply.toString(),
      'image': image,
      'type': 'nft',
      'owner': owner,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
