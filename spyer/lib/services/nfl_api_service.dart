import 'package:dio/dio.dart';
import '../models/nfl_scoreboard_model.dart';

class NflApiService {
  static const String _baseUrl = 'https://site.api.espn.com/apis/site/v2/sports/football/nfl/scoreboard';

  static final Dio _defaultDio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  final Dio _dio;

  NflApiService({Dio? dio}) : _dio = dio ?? _defaultDio;

  Future<NflScoreboardResponse> getScoreboard({
    int? limit,
    int? page,
    String? dates,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (page != null) queryParams['page'] = page;
      if (dates != null && dates.isNotEmpty) queryParams['dates'] = dates;

      final response = await _dio.get(
        '',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final data = response.data;
      if (response.statusCode == 200 && data is Map<String, dynamic>) {
        return NflScoreboardResponse.fromJson(data);
      } else if (response.statusCode == 200 && data is Map) {
        final map = data.map((key, value) => MapEntry(key.toString(), value));
        return NflScoreboardResponse.fromJson(map);
      } else {
        throw Exception('Respuesta inválida del servidor (Código ${response.statusCode})');
      }
    } on DioException catch (e) {
      String errorMessage = 'Error al conectar con el servicio de ESPN';
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Tiempo de espera agotado al conectar con el servidor.';
      } else if (e.type == DioExceptionType.badResponse) {
        errorMessage = 'Error del servidor: ${e.response?.statusCode ?? 'Desconocido'}';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Sin conexión a internet. Revisa tu red.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Ocurrió un error inesperado: $e');
    }
  }
}
