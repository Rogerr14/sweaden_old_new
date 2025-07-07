part of 'shared_widgets.dart';

class SearchPlaces extends SearchDelegate<LatLng?> {
  @override
  // ignore: overridden_fields
  final String searchFieldLabel;
  final g_places.LatLng myLocation;
  SearchPlaces(this.myLocation) : searchFieldLabel = "Buscar sitio...";

  final places = g_places.FlutterGooglePlacesSdk(
      AppConfig.appEnv.apiKeyGooglePlaces,
      locale: const Locale('es', 'EC'));

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
        future: _buildResultPlaces(),
        builder: (context,
            AsyncSnapshot<g_places.FindAutocompletePredictionsResponse?>
                snapshot) {
          if (snapshot.hasData) {
            return _buildTiles(context, snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Colocar ubicación manualmente'),
            onTap: () => close(context, null),
          )
        ],
      );
    }
    return buildResults(context);
  }

  Future<g_places.FindAutocompletePredictionsResponse?>
      _buildResultPlaces() async {
    final predictions = await places.findAutocompletePredictions(
        query.toLowerCase().trim(),
        countries: ['ec'],
        origin: myLocation);
    if (predictions.predictions.isEmpty) {
      return null;
    }
    return predictions;
  }

  Widget _buildTiles(BuildContext context,
      g_places.FindAutocompletePredictionsResponse predictions) {
    return ListView.separated(
        itemBuilder: (_, i) {
          final prediction = predictions.predictions[i];
          return ListTile(
            leading: const Icon(Icons.place),
            title: Text(
              prediction.primaryText,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              prediction.secondaryText,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              final coor = await places.fetchPlace(prediction.placeId,
                  fields: [g_places.PlaceField.Location]);
              close(context,
                  LatLng(coor.place!.latLng!.lat, coor.place!.latLng!.lng));
            },
          );
        },
        separatorBuilder: (_, i) => const Divider(),
        itemCount: predictions.predictions.length);
  }
}
