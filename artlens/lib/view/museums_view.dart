import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes.dart';
import '../view_model/facade.dart';
import '../view_model/museum_cubit.dart';
import '../entities/museum.dart';
import '../widgets/custom_app_bar.dart';

class MuseumsView extends StatefulWidget {
  final AppFacade appFacade;

  const MuseumsView({Key? key, required this.appFacade}) : super(key: key);

  @override
  _MuseumsViewState createState() => _MuseumsViewState();
}

class _MuseumsViewState extends State<MuseumsView> {
  @override
  void initState() {
    super.initState();
    widget.appFacade.fetchAllMuseums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "MUSEUMS", showProfileIcon: true, showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<MuseumCubit, MuseumState>(
          bloc: widget.appFacade.museumCubit,
          builder: (context, state) {
            if (state is MuseumLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MuseumsLoaded) {
              // Agrupar museos alfabéticamente
              final groupedMuseums = _groupMuseumsByLetter(state.museums);

              return ListView.builder(
                itemCount: groupedMuseums.length,
                itemBuilder: (context, index) {
                  final letter = groupedMuseums.keys.elementAt(index);
                  final museums = groupedMuseums[letter]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          letter,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...museums.map((museum) => _buildMuseumItem(museum)).toList(),
                      const Divider(thickness: 1, height: 32),
                    ],
                  );
                },
              );
            } else if (state is Error) {
              return Center(child: Text('Error: ${state.message}'));
            } else {
              return const Center(child: Text("No museums to display"));
            }
          },
        ),
      ),
    );
  }

  Widget _buildMuseumItem(Museum museum) {
    return GestureDetector(
      onTap: () {
        // Navegar a la vista del museo
        Navigator.pushNamed(context, Routes.museum, arguments: {'museum': museum});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            if (museum.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  museum.image!,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              const Icon(Icons.image, size: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                museum.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para agrupar los museos por la letra inicial del nombre
  Map<String, List<Museum>> _groupMuseumsByLetter(List<Museum> museums) {
    // Ordenar museos alfabéticamente
    museums.sort((a, b) => a.name.compareTo(b.name));

    final Map<String, List<Museum>> groupedMuseums = {};
    for (var museum in museums) {
      final letter = museum.name[0].toUpperCase();
      if (groupedMuseums[letter] == null) {
        groupedMuseums[letter] = [];
      }
      groupedMuseums[letter]!.add(museum);
    }
    return groupedMuseums;
  }
}
