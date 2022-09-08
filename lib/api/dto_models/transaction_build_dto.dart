class TransactionBuildDto {
  final String? unsignedTx;
  num? fromGroup;
  num? toGroup;
  final String? txId;
  final String? gasPrice;
  final String? gasAmount;

  TransactionBuildDto({
    this.unsignedTx,
    this.fromGroup,
    this.toGroup,
    this.txId,
    this.gasPrice,
    this.gasAmount,
  });

  TransactionBuildDto.fromSweep({
    this.unsignedTx,
    this.txId,
    this.gasPrice,
    this.gasAmount,
  });
}
