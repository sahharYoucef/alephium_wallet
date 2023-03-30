import 'package:alephium_wallet/storage/app_storage.dart';

class Network {
  factory Network.mainnet() {
    return Network._(
      'https://wallet-v17.mainnet.alephium.org',
      'https://backend-v113.mainnet.alephium.org',
      'https://explorer.alephium.org/#',
      NetworkType.mainnet,
    );
  }
  factory Network.testnet() {
    return Network._(
      'https://wallet-v17.testnet.alephium.org',
      'https://backend-v113.testnet.alephium.org',
      'https://explorer.testnet.alephium.org',
      NetworkType.testnet,
    );
  }

  factory Network.localHost() {
    return Network._(
      'http://localhost:12973',
      'http://localhost:9090',
      'http://localhost:3000',
      NetworkType.localhost,
    );
  }

  factory Network.custom() {
    final data = AppStorage.instance.customNetwork!;
    return Network._(
      data['nodeHost'],
      data['explorerApiHost'],
      data['explorerUrl'],
      NetworkType.custom,
    );
  }

  final String nodeHost;
  final String explorerApiHost;
  final String explorerUrl;
  final NetworkType networkType;
  const Network._(
    this.nodeHost,
    this.explorerApiHost,
    this.explorerUrl,
    this.networkType,
  );

  Map<String, String> toMap() {
    return {
      "nodeHost": this.nodeHost,
      "explorerUrl": this.explorerUrl,
      "explorerApiHost": this.explorerApiHost,
    };
  }
}

enum NetworkType {
  mainnet,
  testnet,
  localhost,
  custom;

  static NetworkType network(String value) {
    return NetworkType.values.firstWhere((element) => element.name == value);
  }

  Network get data {
    switch (this) {
      case NetworkType.mainnet:
        return Network.mainnet();
      case NetworkType.testnet:
        return Network.testnet();
      case NetworkType.localhost:
        return Network.localHost();
      case NetworkType.custom:
        return Network.custom();
    }
  }

  @override
  String toString() {
    return name.toUpperCase();
  }
}
