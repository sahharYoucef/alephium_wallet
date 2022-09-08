import 'transaction_build_dto.dart';

class SweepResultDTO {
  final List<TransactionBuildDto>? unsignedTxs;
  final num? fromGroup;
  final num? toGroup;

  SweepResultDTO({
    this.unsignedTxs,
    this.fromGroup,
    this.toGroup,
  });
}
