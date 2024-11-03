import '../entities/museum.dart';
import '../model/api_adapter.dart';

class MuseumService {
  static final MuseumService _instance = MuseumService._internal();

  factory MuseumService() {
    return _instance;
  }

  MuseumService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<Museum> fetchMuseumById(int id) async {
    return await apiAdapter.fetchMuseumById(id);
  }

  Future<List<Museum>> fetchAllMuseums() async {
    return await apiAdapter.fetchAllMuseums();
  }
}
