import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutterdabao/CustomWidget/FadeRoute.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rxdart/rxdart.dart';

const String kGoogleApiKey = "AIzaSyCIIqjYS-TEsb7XziWv79Z9kEmZ-m-u2mk";

abstract class HavingGoogleMapPlaces {
  GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  Future<LatLng> getLatLng(Prediction p) async {
    assert(p != null);

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId);
    final lat = detail.result.geometry.location.lat;
    final lng = detail.result.geometry.location.lng;

    return LatLng(lat, lng);
  }

  Future<void> handlePressButton(BuildContext context,
      Function(LatLng, String) onCompleteCallback, String startingText) async {
    // show input autocomplete with selected mode
    // then get the Prediction selected
    Prediction p = await CustomPlacesAutocomplete.show(
      startingText: startingText,
      context: context,
      apiKey: kGoogleApiKey,
      onError: onError,
      mode: Mode.fullscreen,
      language: "en",
      components: [Component(Component.country, "sg")],
    );

    if (p != null) {
      LatLng newLocation = await getLatLng(p);
      onCompleteCallback(newLocation, p.description);
    }
  }

  void onError(PlacesAutocompleteResponse response) {
    SnackBar(content: Text(response.errorMessage));
  }
}

class CustomPlacesAutocompleteWidget extends StatefulWidget {
  final String apiKey;
  final String hint;
  final Location location;
  final num offset;
  final num radius;
  final String language;
  final List<String> types;
  final List<Component> components;
  final bool strictbounds;
  final Mode mode;
  final Widget logo;
  final ValueChanged<PlacesAutocompleteResponse> onError;
  final String startingText;

  CustomPlacesAutocompleteWidget({
    @required this.apiKey,
    this.mode = Mode.fullscreen,
    this.hint = "Search",
    this.offset,
    this.location,
    this.radius,
    this.language,
    this.types,
    this.components,
    this.strictbounds,
    this.logo,
    this.onError,
    Key key,
    this.startingText,
  }) : super(key: key);

  @override
  State<CustomPlacesAutocompleteWidget> createState() {
    if (mode == Mode.fullscreen) {
      return _CustomPlacesAutocompleteScaffoldState();
    }
    return _CustomPlacesAutocompleteScaffoldState();
  }

  static CustomPlacesAutocompleteState of(BuildContext context) => context
      .ancestorStateOfType(const TypeMatcher<CustomPlacesAutocompleteState>());
}

class _CustomPlacesAutocompleteScaffoldState
    extends CustomPlacesAutocompleteState {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    super._queryTextController.text = widget.startingText;
  }

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
        backgroundColor: Colors.white,
        title: CustomAppBarPlacesAutoCompleteTextField());
    final body = CustomPlacesAutocompleteResult(
      onTap: Navigator.of(context).pop,
      logo: widget.logo,
    );
    return Scaffold(appBar: appBar, body: body);
  }
}

class CustomPlacesAutocompleteResult extends StatefulWidget {
  final ValueChanged<Prediction> onTap;
  final Widget logo;

  CustomPlacesAutocompleteResult({this.onTap, this.logo});

  @override
  _CustomPlacesAutocompleteResult createState() =>
      _CustomPlacesAutocompleteResult();
}

class _CustomPlacesAutocompleteResult
    extends State<CustomPlacesAutocompleteResult> {
  @override
  Widget build(BuildContext context) {
    final state = CustomPlacesAutocompleteWidget.of(context);
    assert(state != null);

    if (state._queryTextController.text.isEmpty ||
        state._response == null ||
        state._response.predictions.isEmpty) {
      final children = <Widget>[];
      if (state._searching) {
        // children.add(_Loader());
      }
      children.add(widget.logo ?? PoweredByGoogleImage());
      return Stack(children: children);
    }
    return PredictionsListView(
      predictions: state._response.predictions,
      onTap: widget.onTap,
    );
  }
}

class CustomAppBarPlacesAutoCompleteTextField extends StatefulWidget {
  const CustomAppBarPlacesAutoCompleteTextField({
    Key key,
  }) : super(key: key);
  @override
  _CustomAppBarPlacesAutoCompleteTextFieldState createState() =>
      _CustomAppBarPlacesAutoCompleteTextFieldState();
}

class _CustomAppBarPlacesAutoCompleteTextFieldState
    extends State<CustomAppBarPlacesAutoCompleteTextField> {
  @override
  Widget build(BuildContext context) {
    final state = CustomPlacesAutocompleteWidget.of(context);
    assert(state != null);

    return Container(
        alignment: Alignment.topLeft,
        margin: EdgeInsets.only(top: 4.0),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: state._queryTextController,
                autofocus: true,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                decoration: InputDecoration(
                  hintText: state.widget.hint,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            new IconButton(
                onPressed: () {
                  state._queryTextController.clear();
                },
                icon: new Icon(Icons.clear))
          ],
        ));
  }
}

abstract class CustomPlacesAutocompleteState
    extends State<CustomPlacesAutocompleteWidget> {
  TextEditingController _queryTextController;
  PlacesAutocompleteResponse _response;
  GoogleMapsPlaces _places;
  bool _searching;

  final _queryBehavior = BehaviorSubject<String>(seedValue: '');

  @override
  void initState() {
    super.initState();
    _queryTextController = TextEditingController(text: "");

    _places = GoogleMapsPlaces(apiKey: widget.apiKey);
    _searching = false;

    _queryTextController.addListener(_onQueryChange);

    _queryBehavior.stream
        .debounce(const Duration(milliseconds: 300))
        .listen(doSearch);
  }

  Future<Null> doSearch(String value) async {
    if (mounted && value.isNotEmpty) {
      setState(() {
        _searching = true;
      });

      final res = await _places.autocomplete(
        value,
        offset: widget.offset,
        location: widget.location,
        radius: widget.radius,
        language: widget.language,
        types: widget.types,
        components: widget.components,
        strictbounds: widget.strictbounds,
      );

      if (res.errorMessage?.isNotEmpty == true ||
          res.status == "REQUEST_DENIED") {
        onResponseError(res);
      } else {
        onResponse(res);
      }
    } else {
      onResponse(null);
    }
  }

  void _onQueryChange() {
    _queryBehavior.add(_queryTextController.text);
  }

  @override
  void dispose() {
    super.dispose();

    _places.dispose();
    _queryBehavior.close();
    _queryTextController.removeListener(_onQueryChange);
  }

  @mustCallSuper
  void onResponseError(PlacesAutocompleteResponse res) {
    if (!mounted) return;

    if (widget.onError != null) {
      widget.onError(res);
    }
    setState(() {
      _response = null;
      _searching = false;
    });
  }

  @mustCallSuper
  void onResponse(PlacesAutocompleteResponse res) {
    if (!mounted) return;

    setState(() {
      _response = res;
      _searching = false;
    });
  }
}

class CustomPlacesAutocomplete {
  static Future<Prediction> show(
      {@required BuildContext context,
      @required String apiKey,
      Mode mode = Mode.fullscreen,
      String hint = "Search",
      num offset,
      Location location,
      num radius,
      String language,
      List<String> types,
      List<Component> components,
      bool strictbounds,
      Widget logo,
      String startingText,
      ValueChanged<PlacesAutocompleteResponse> onError}) {
    final builder = (BuildContext ctx) => CustomPlacesAutocompleteWidget(
          apiKey: apiKey,
          mode: mode,
          language: language,
          components: components,
          types: types,
          location: location,
          radius: radius,
          strictbounds: strictbounds,
          offset: offset,
          hint: hint,
          logo: logo,
          onError: onError,
          startingText: startingText,
        );

    if (mode == Mode.overlay) {
      return showDialog(context: context, builder: builder);
    }
    return Navigator.push(context, MyCustomRoute(builder: builder));
  }
}

class MyCustomRoute<T> extends MaterialPageRoute<T> {
  MyCustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (settings.isInitialRoute) return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(animation),
      child: new SlideTransition(
        position: new Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0.0, 1.0),
        ).animate(secondaryAnimation),
        child: child,
      ),
    );
  }
}
