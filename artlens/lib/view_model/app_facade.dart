// /lib/view_model/app_facade.dart

import '../view_model/artwork_cubit.dart';

class AppFacade {
  final ArtworkCubit artworkCubit;

  AppFacade(this.artworkCubit);

  // Método para que la vista obtenga la obra de arte y los comentarios
  void fetchArtworkAndComments(int id) {
    artworkCubit.fetchArtworkAndComments(id);
    }
}