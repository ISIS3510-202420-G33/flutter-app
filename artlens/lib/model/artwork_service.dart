import '../entities/artwork.dart';
import '../model/api_adapter.dart';

class ArtworkService {
  static final ArtworkService _instance = ArtworkService._internal();
  final ApiAdapter apiAdapter = ApiAdapter.instance;

  factory ArtworkService() {
    return _instance;
  }

  ArtworkService._internal();

  Future<Artwork> fetchArtworkById(int id) async {
    return await apiAdapter.fetchArtworkById(id);
  }

  Future<List<Artwork>> fetchArtworksByArtistId(int id) async {
    return await apiAdapter.fetchArtworksByArtistId(id);
  }

  Future<List<Artwork>> fetchArtworksByMuseumId(int museumId) async {
    return await apiAdapter.fetchArtworksByMuseumId(museumId);
  }

  Future<List<Artwork>> fetchAllArtworks() async {
    return await apiAdapter.fetchAllArtworks();
  }

}
