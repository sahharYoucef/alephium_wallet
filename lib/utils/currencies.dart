class Currency {
  final String currency;
  final String symbole;

  Currency({required this.currency, required this.symbole});

  factory Currency.usd() {
    return Currency(currency: "usd", symbole: "\$");
  }

  factory Currency.eur() {
    return Currency(currency: "eur", symbole: "\$");
  }

  factory Currency.gbp() {
    return Currency(currency: "gbp", symbole: "\$");
  }
}
