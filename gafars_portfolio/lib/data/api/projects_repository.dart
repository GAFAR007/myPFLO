import 'api_client.dart';
import 'models/project.dart';

class ProjectsRepository {
  final ApiClient _client = ApiClient.instance;

  Future<List<PortfolioProject>> fetchProjects() async {
    final response = await _client.getJson('/api/projects');
    final rawProjects = response['projects'] as List<dynamic>? ?? const [];
    return rawProjects
        .whereType<Map<String, dynamic>>()
        .map(PortfolioProject.fromMap)
        .toList();
  }

  Future<PortfolioProject> createProject({
    required String title,
    String? subtitle,
    String? description,
    String? url,
    List<String> tags = const <String>[],
    bool isActive = true,
    int sortOrder = 0,
  }) async {
    final response = await _client.postJson(
      '/api/projects',
      body: {
        'title': title,
        'subtitle': subtitle,
        'description': description,
        'url': url,
        'tags': tags,
        'isActive': isActive,
        'sortOrder': sortOrder,
      }..removeWhere((_, value) => value == null),
    );

    return PortfolioProject.fromMap(
      response['project'] as Map<String, dynamic>,
    );
  }
}
