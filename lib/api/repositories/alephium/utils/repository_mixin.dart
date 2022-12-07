part of "../alephium_api_repository.dart";

mixin RepositoryMixin {
  NetworkType get network;

  AddressStore updateAddressBalance(Balance data,
      {required AddressStore address}) {
    return AddressStore(
      group: address.group,
      privateKey: address.privateKey,
      publicKey: address.publicKey,
      address: address.address,
      walletId: address.walletId,
      index: address.index,
      warning: data.warning,
      balance: BalanceStore(
          balance: data.balance,
          balanceHint: data.balanceHint,
          lockedBalance: data.lockedBalance,
          lockedBalanceHint: data.lockedBalanceHint,
          address: address.address,
          network: network,
          tokens: data.tokenBalances
              ?.map((e) => TokenStore(id: e.id, amount: e.amount))
              .toList()),
    );
  }

  List<TransactionStore> parseAddressTransactions(
      List<ExplorerTransaction> data,
      {required String address,
      required String walletId}) {
    return data
        .map((transaction) => TransactionStore(
              transactionID: "",
              address: address,
              walletId: walletId,
              gasPrice: transaction.gasPrice,
              status: TXStatus.completed,
              network: network,
              refsIn: transaction.inputs
                      ?.map((e) => TransactionRefStore(
                          hint: e.outputRef?.hint,
                          key: e.outputRef?.key,
                          address: e.address,
                          amount: e.attoAlphAmount,
                          hash: e.txHashRef,
                          unlockScript: e.unlockScript,
                          tokens: e.tokens
                              ?.map(
                                  (e) => TokenStore(id: e.id, amount: e.amount))
                              .toList()))
                      .toList() ??
                  [],
              refsOut: transaction.outputs
                      ?.map((e) => TransactionRefStore(
                          address: e.address,
                          amount: e.attoAlphAmount,
                          type: e.type,
                          spent: e.spent,
                          key: e.key,
                          message: e.message,
                          lockTime: e.lockTime,
                          hint: e.hint,
                          tokens: e.tokens
                              ?.map(
                                  (e) => TokenStore(id: e.id, amount: e.amount))
                              .toList()))
                      .toList() ??
                  [],
              txHash: transaction.hash!,
              blockHash: transaction.blockHash,
              timeStamp: transaction.timeStamp!.toInt(),
              gasAmount: transaction.gasAmount,
            ))
        .toList();
  }
}
