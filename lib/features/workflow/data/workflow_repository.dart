import 'package:dio/dio.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/networking/api_exceptions.dart';
import 'models/workflow_dto.dart';

class WorkflowRepository {
  final ApiClient _apiClient;

  WorkflowRepository(this._apiClient);

  Future<WorkflowStartResponse> startWorkflow(WorkflowStartRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/orchestrate',
        data: request.toJson(),
      );
      
      return WorkflowStartResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(e.toString());
    }
  }
}
