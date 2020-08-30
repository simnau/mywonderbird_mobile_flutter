import 'package:flutter/material.dart';
import 'package:mywonderbird/constants/onboarding.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/services/onboarding.dart';

class Onboarding extends StatefulWidget {
  final dynamic Function() callback;

  const Onboarding({
    Key key,
    this.callback,
  }) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  static const _INITIAL_PAGE = 0;

  final pageViewController = PageController(initialPage: _INITIAL_PAGE);

  int _currentPage = _INITIAL_PAGE;

  @override
  Widget build(BuildContext context) {
    final isFirstPageSelected = _currentPage == 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: isFirstPageSelected
            ? null
            : IconButton(
                icon: BackButtonIcon(),
                onPressed: _onPrevious,
              ),
        backgroundColor: Colors.transparent,
      ),
      body: PageView.builder(
        controller: pageViewController,
        onPageChanged: _onPageChanged,
        itemBuilder: _onboardingSlide,
        itemCount: ONBOARDING_SLIDES.length,
      ),
      // Center(
      //   child: RaisedButton(
      //     onPressed: _onComplete,
      //     colorBrightness: Brightness.dark,
      //     child: Text('Continue'),
      //   ),
      // ),
    );
  }

  Widget _onboardingSlide(context, index) {
    final theme = Theme.of(context);
    final item = ONBOARDING_SLIDES[index];
    final isLastSlide = index == ONBOARDING_SLIDES.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
          ),
        ),
        Expanded(
          child: Image.asset(
            item.imagePath,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            bottom: 16.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            item.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Center(
            child: RaisedButton(
              padding: const EdgeInsets.symmetric(
                horizontal: 56,
                vertical: 12,
              ),
              colorBrightness: Brightness.dark,
              color: theme.accentColor,
              child: Text(
                isLastSlide ? "Let's go" : 'Next',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                ),
              ),
              onPressed: isLastSlide ? _onComplete : _onNext,
            ),
          ),
        ),
      ],
    );
  }

  _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  _onNext() {
    pageViewController.animateToPage(
      _currentPage + 1,
      duration: Duration(
        milliseconds: 400,
      ),
      curve: Curves.easeInOut,
    );
  }

  _onPrevious() {
    pageViewController.animateToPage(
      _currentPage - 1,
      duration: Duration(
        milliseconds: 400,
      ),
      curve: Curves.easeInOut,
    );
  }

  _onComplete() async {
    final onboardingService = locator<OnboardingService>();
    await onboardingService.markCompletedOnboarding();

    widget.callback();
  }
}
