import 'package:flutter/material.dart';
import 'package:mywonderbird/components/slide-indicator.dart';
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
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.only(top: 16.0)),
          Expanded(
            child: PageView.builder(
              controller: pageViewController,
              onPageChanged: _onPageChanged,
              itemBuilder: _onboardingSlide,
              itemCount: ONBOARDING_SLIDES.length,
            ),
          ),
          _bottomContent(),
        ],
      ),
    );
  }

  Widget _onboardingSlide(context, index) {
    final item = ONBOARDING_SLIDES[index];

    return Image.asset(
      item.imagePath,
      fit: BoxFit.cover,
    );
  }

  Widget _bottomContent() {
    final theme = Theme.of(context);
    final isLastPageSelected = _currentPage == ONBOARDING_SLIDES.length - 1;
    final item = ONBOARDING_SLIDES[_currentPage];

    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SlideIndicator(
                color: theme.primaryColor,
                itemCount: ONBOARDING_SLIDES.length,
                currentItem: _currentPage,
              ),
            ),
            Padding(padding: const EdgeInsets.only(bottom: 16.0)),
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
            Padding(padding: const EdgeInsets.only(bottom: 8.0)),
            Text(
              item.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Padding(padding: const EdgeInsets.only(bottom: 16.0)),
            RaisedButton(
              colorBrightness: Brightness.dark,
              child: Text(
                isLastPageSelected ? "Let's go" : 'Next',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.0,
                ),
              ),
              onPressed: isLastPageSelected ? _onComplete : _onNext,
            ),
          ],
        ),
      ),
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
