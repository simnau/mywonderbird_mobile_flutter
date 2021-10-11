import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/models/location.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/picture-sharing/components/form-page.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/select-location/main.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/types/form-page-data.dart';
import 'package:mywonderbird/routes/picture-sharing/pages/types/picture-share-data.dart';
import 'package:mywonderbird/routes/picture-sharing/providers/form.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/sharing.dart';
import 'package:mywonderbird/types/picture-data.dart';
import 'package:mywonderbird/util/snackbar.dart';
import 'package:provider/provider.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class SharePicturesStandalone extends StatelessWidget {
  final List<PictureData> pictureDatas;

  const SharePicturesStandalone({
    Key key,
    @required this.pictureDatas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FormProvider(
        pictureDatas: pictureDatas,
      ),
      child: _SharePicturesStandaloneInner(
        pictureDatas: pictureDatas,
      ),
    );
  }
}

class _SharePicturesStandaloneInner extends StatefulWidget {
  final List<PictureData> pictureDatas;

  const _SharePicturesStandaloneInner({
    Key key,
    @required this.pictureDatas,
  }) : super(key: key);

  @override
  _SharePicturesStandaloneInnerState createState() =>
      _SharePicturesStandaloneInnerState();
}

class _SharePicturesStandaloneInnerState
    extends State<_SharePicturesStandaloneInner> {
  final PageController pageController = PageController();
  int currentPage = 0;

  bool _isSharing = false;

  FormPageData get currentFormPageData {
    final formProvider = Provider.of<FormProvider>(
      context,
      listen: false,
    );

    return formProvider.formPageDatas[currentPage];
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(interceptBack);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(interceptBack);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: _isSharing
            ? null
            : BackButton(
                onPressed: onBack,
              ),
        actions: [
          TextButton(
            onPressed: onNext,
            child: _isSharing
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(),
                  )
                : BodyText1(
                    currentPage < widget.pictureDatas.length - 1
                        ? 'NEXT'
                        : 'SHARE',
                    color: theme.primaryColor,
                  ),
          )
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    final theme = Theme.of(context);
    final formProvider = Provider.of<FormProvider>(context);

    return Column(
      children: [
        if (widget.pictureDatas.length > 1)
          StepProgressIndicator(
            currentStep: currentPage + 1,
            totalSteps: widget.pictureDatas.length,
            selectedColor: theme.accentColor,
          ),
        Expanded(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChange,
            allowImplicitScrolling: false,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final pictureData = widget.pictureDatas[index];

              return FormPage(
                pictureData: pictureData,
                index: index,
                trip: formProvider.trip,
                onSelectLocation: _onSelectLocation,
                onLocationChange: _onLocationChange,
                location: formProvider.formPageDatas[index].location,
                isSingle: true,
              );
            },
            itemCount: widget.pictureDatas.length,
          ),
        ),
      ],
    );
  }

  onPageChange(int page) {
    setState(() {
      currentPage = page;
    });
  }

  onBack() {
    if (currentPage > 0) {
      pageController.animateToPage(
        currentPage - 1,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      final navigationService = locator<NavigationService>();

      navigationService.pop();
    }
  }

  onNext() {
    if (!currentFormPageData.formKey.currentState.validate()) {
      return;
    }

    if (currentPage < widget.pictureDatas.length - 1) {
      pageController.animateToPage(
        currentPage + 1,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else if (currentPage == widget.pictureDatas.length - 1) {
      _share();
    }
  }

  bool interceptBack(bool stopDefaultButtonEvent, RouteInfo info) {
    onBack();
    return true;
  }

  Future<LocationModel> _onSelectLocation() async {
    final navigationService = locator<NavigationService>();
    final selectedLocation = await navigationService.push(
      MaterialPageRoute(
        builder: (context) => SelectLocation(
          location: currentFormPageData.location,
        ),
      ),
    );

    if (selectedLocation != null) {
      return selectedLocation;
    }

    return null;
  }

  _onLocationChange(LocationModel location) {
    setState(() {
      currentFormPageData.location = location;
    });
  }

  _share() async {
    final navigationService = locator<NavigationService>();
    final sharingService = locator<SharingService>();
    final formProvider = Provider.of<FormProvider>(
      context,
      listen: false,
    );

    try {
      setState(() {
        _isSharing = true;
      });

      final pictures = formProvider.formPageDatas
          .map(
            (formPageData) => PictureShareData.fromFormPageData(formPageData),
          )
          .toList();

      await sharingService.shareMultiplePictures(
        pictures,
      );

      navigationService.popUntil((route) => route.isFirst);
      navigationService.pushReplacementNamed(HomePage.PATH);
    } catch (e) {
      final snackBar = createErrorSnackbar(text: e.toString());
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }
}
