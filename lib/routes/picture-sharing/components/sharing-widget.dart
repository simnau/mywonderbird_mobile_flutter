import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/theme.dart';
import 'package:mywonderbird/models/journey.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/picture-sharing/components/location-selector.dart';
import 'package:mywonderbird/routes/picture-sharing/components/trip-selector.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SharingWidget extends StatefulWidget {
  final Future<Journey> Function() onSelectTrip;
  final Future<Journey> Function() onCreateTrip;
  final Future<LocationModel> Function() onSelectLocation;
  final Function(Journey) onTripChange;
  final Function(LocationModel) onLocationChange;
  final Journey trip;
  final LocationModel location;
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool single;
  final List<ImageProvider> images;

  SharingWidget({
    this.onSelectTrip,
    this.onCreateTrip,
    this.onTripChange,
    this.trip,
    this.onSelectLocation,
    this.onLocationChange,
    this.location,
    this.formKey,
    this.titleController,
    this.descriptionController,
    bool single,
    this.images,
  }) : single = single ?? false;

  @override
  _SharingWidgetState createState() => _SharingWidgetState();
}

class _SharingWidgetState extends State<SharingWidget> {
  int currentPhoto = 0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: _content(),
            ),
          ),
        );
      },
    );
  }

  Widget _content() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Form(
            key: widget.formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Photo title',
                    hintStyle: TextStyle(
                      color: Colors.black26,
                    ),
                  ),
                  style: theme.textTheme.subtitle1,
                  validator: _validateTitle,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: widget.titleController,
                ),
                Padding(padding: const EdgeInsets.only(bottom: 16.0)),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Photo description (optional)',
                    hintStyle: TextStyle(
                      color: Colors.black26,
                    ),
                  ),
                  style: theme.textTheme.subtitle1,
                  maxLines: null,
                  controller: widget.descriptionController,
                ),
                Padding(padding: const EdgeInsets.only(bottom: 8.0)),
                LocationSelector(
                  initialValue: widget.location,
                  onSelectLocation: widget.onSelectLocation,
                  onChange: widget.onLocationChange,
                  validator: _validateLocation,
                ),
                ..._tripSelector(),
                Padding(padding: const EdgeInsets.only(bottom: 8.0)),
              ],
            ),
          ),
        ),
        Stack(
          children: [
            CarouselSlider.builder(
              itemCount: widget.images.length,
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                final image = widget.images[index];

                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: image,
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                autoPlay: false,
                aspectRatio: 4 / 3,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                viewportFraction: 1.0,
                onPageChanged: _onPhotoChanged,
              ),
            ),
            if (widget.images.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: spacingFactor(2),
                child: Center(
                  child: AnimatedSmoothIndicator(
                    count: widget.images.length,
                    activeIndex: currentPhoto,
                    effect: ScrollingDotsEffect(
                      activeDotColor: theme.accentColor,
                      activeDotScale: 4 / 3,
                      dotHeight: 12,
                      dotWidth: 12,
                      spacing: spacingFactor(1),
                      maxVisibleDots: 5,
                      dotColor: Color(0xFFC4C4C4),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  List<Widget> _tripSelector() {
    if (widget.single) {
      return [];
    }

    return [
      Divider(thickness: 2),
      TripSelector(
        image: widget.images[0],
        initialValue: widget.trip,
        onCreateTrip: widget.onCreateTrip,
        onSelectTrip: widget.onSelectTrip,
        onChange: widget.onTripChange,
        validator: _validateTrip,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    ];
  }

  String _validateTitle(String value) {
    if (value.isEmpty) {
      return 'Photo title is required';
    }

    return null;
  }

  String _validateLocation(LocationModel value) {
    if (value == null) {
      return 'Location is required';
    }

    return null;
  }

  String _validateTrip(Journey value) {
    if (widget.single) {
      return null;
    }

    if (value == null) {
      return 'Trip is required';
    }

    return null;
  }

  _onPhotoChanged(int page, CarouselPageChangedReason reason) {
    setState(() {
      currentPhoto = page;
    });
  }
}
