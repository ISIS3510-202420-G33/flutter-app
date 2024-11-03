import '../entities/artist.dart';
import '../model/api_adapter.dart';

class ArtistService {
  static final ArtistService _instance = ArtistService._internal();

  factory ArtistService() {
    return _instance;
  }

  ArtistService._internal();

  final ApiAdapter apiAdapter = ApiAdapter.instance;

  Future<Artist> fetchArtistById(int id) async {
    return await apiAdapter.fetchArtistById(id);
  }

  Future<List<Artist>> fetchAllArtists() async {
    return await apiAdapter.fetchAllArtists();
  }
}
