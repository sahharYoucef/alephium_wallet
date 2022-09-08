enum Network {
  mainnet(
    'https://mainnet-wallet.alephium.org',
    'https://mainnet-backend.alephium.org',
    'https://explorer.alephium.org',
  ),
  testnet(
    'https://testnet-wallet.alephium.org',
    'https://testnet-backend.alephium.org',
    'https://testnet.alephium.org',
  ),
  localhost(
    'http://localhost:12973',
    'http://localhost:9090',
    'http://localhost:3000',
  );

  final String nodeHost;
  final String explorerApiHost;
  final String explorerUrl;
  const Network(this.nodeHost, this.explorerApiHost, this.explorerUrl);
}
