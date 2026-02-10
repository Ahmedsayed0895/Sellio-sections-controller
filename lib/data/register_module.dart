import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'datasources/sellio_api.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio(
    BaseOptions(
      baseUrl: 'https://app.sell-io.app/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 13),
      validateStatus: (status) => status! < 600,
      headers: {
        'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjNmE1YTQwNy0wM2YzLTRjNzctYWQzZC01NTc5ZDU0MDcyNDUiLCJpYXQiOjE3NzA2MzI1ODYsImV4cCI6MTc3MzIyNDU4Nn0.0c1Fl-nUv93bA4RweV6hpimQ28sxICZT3nevXJOOH30',
      },
    ),
  );

  @lazySingleton
  SellioApi getSellioApi(Dio dio) => SellioApi(dio);
}
