import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart' hide Headers;

part 'coingecko_repository.g.dart';

@RestApi(baseUrl: "")
abstract class CoingeckoClient {
  factory CoingeckoClient(Dio dio, {String baseUrl}) = _CoingeckoClient;

  @GET("https://api.coingecko.com/api/v3/simple/price")
  Future getPrice(
      @Query("ids") String ids, @Query("vs_currencies") String currencies);
}
