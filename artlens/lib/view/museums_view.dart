import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../routes.dart';
import '../view_model/facade.dart';
import '../view_model/museum_cubit.dart';
import '../view_model/connectivity_cubit.dart';
import '../entities/museum.dart';
import '../widgets/custom_app_bar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MuseumsView extends StatefulWidget {
  final AppFacade appFacade;

  const MuseumsView({Key? key, required this.appFacade}) : super(key: key);

  @override
  _MuseumsViewState createState() => _MuseumsViewState();
}

class _MuseumsViewState extends State<MuseumsView> {
  bool isOnline = true;
  bool isFetched = false;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    isOnline = connectivityResult[0] != ConnectivityResult.none;
    if (isOnline) {
      isFetched = true;
      widget.appFacade.fetchAllMuseums();
    } else {
      if (isFetched) {
        setState(() {
          isOnline;
        });
      } else {
        widget.appFacade.fetchAllMuseums();
      }
    }
  }

  void _handleConnectivityChange(BuildContext context, ConnectivityState state) {
    if (state is ConnectivityOffline) {
      setState(() {
        isOnline = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection lost. Some features may not be available.'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (state is ConnectivityOnline) {

      if (!isFetched) {
        Future.delayed(const Duration(seconds: 5), () {
          isFetched = true;
          widget.appFacade.fetchAllMuseums();
        });
      } else {
        setState(() {
          isOnline = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection restored.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "MUSEUMS", showProfileIcon: true, showBackArrow: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MultiBlocListener(
          listeners: [
            BlocListener<ConnectivityCubit, ConnectivityState>(
              listener: _handleConnectivityChange,
            )
          ],
          child: BlocBuilder<MuseumCubit, MuseumState>(
            bloc: widget.appFacade.museumCubit,
            builder: (context, state) {
              if (state is MuseumLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is MuseumsLoaded) {
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
                        ...museums.map((museum) => _buildMuseumItem(museum)),
                        const Divider(thickness: 1, height: 32),
                      ],
                    );
                  },
                );
              } else if (state is Error) {
                return Center(
                  child: Text(
                    isOnline
                        ? 'Error loading museums: ${state.message}'
                        : "No internet connection. Waiting for connection...",
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return const Center(
                    child: Text(
                      "Unexpected error occurred",
                      textAlign: TextAlign.center,
                    )
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMuseumItem(Museum museum) {
    return GestureDetector(
      onTap: isOnline
          ? () {
        Navigator.pushNamed(context, Routes.museum, arguments: {'museum': museum});
      }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                museum.image,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
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

  // Group museums by the first letter of their name
  Map<String, List<Museum>> _groupMuseumsByLetter(List<Museum> museums) {
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
