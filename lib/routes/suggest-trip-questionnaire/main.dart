import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/components/typography/subtitle2.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/suggest-trip-questionnaire/builder-arguments.dart';
import 'package:mywonderbird/routes/suggest-trip-questionnaire/wizard-step.dart';
import 'package:mywonderbird/routes/swipe-locations/main.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/suggestion.dart';

import 'steps.dart';

class SuggestTripQuestionnaire extends StatefulWidget {
  @override
  _SuggestTripQuestionnaireState createState() =>
      _SuggestTripQuestionnaireState();
}

class _SuggestTripQuestionnaireState extends State<SuggestTripQuestionnaire> {
  final PageController _pageController = PageController();
  final Map<String, FocusNode> _focusNodes = {
    'country': FocusNode(),
    'start': FocusNode(),
    'end': FocusNode(),
  };
  final Map<String, dynamic> _values = {
    'country': null,
    'start': null,
    'end': null,
    'duration': 1,
    'locationCount': 3,
    'travelerCount': 0,
    'travelingWithChildren': null,
  };
  int _currentPage = 0;
  bool _isLoading = false;

  bool get isFirstPageSelected => _currentPage == 0;
  bool get isLastPageSelected => _currentPage == questionnaireSteps.length - 1;
  WizardStep get currentStep => questionnaireSteps[_currentPage];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: BackButtonIcon(),
          onPressed: isFirstPageSelected ? _onBack : _onPrevious,
        ),
        actions: [
          FlatButton(
            onPressed: _onCancel,
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.red),
            ),
            shape: ContinuousRectangleBorder(),
          ),
        ],
        backgroundColor: Colors.transparent,
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: NeverScrollableScrollPhysics(),
              itemCount: questionnaireSteps.length,
              itemBuilder: (context, index) {
                final step = questionnaireSteps[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Subtitle1(
                      step.title,
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: step.builder(BuilderArguments(
                        focusNode: _focusNodes[step.key],
                        onValueChanged: (value) =>
                            _onFieldValueChanged(step.key, value),
                        value: _values[step.key],
                        onComplete: _onComplete,
                      )),
                    ),
                  ],
                );
              },
            ),
          ),
          _bottomContent(),
        ],
      ),
    );
  }

  Widget _bottomContent() {
    final value = _values[currentStep.key];
    final isValid = currentStep.validator(value);

    var onPressed;

    if (isValid && !_isLoading) {
      onPressed = isLastPageSelected ? _onComplete : _onNext;
    }

    return SizedBox(
      width: double.infinity,
      child: RaisedButton(
        onPressed: onPressed,
        child: _isLoading
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(),
              )
            : Subtitle2.light('Continue'),
      ),
    );
  }

  _onFieldValueChanged(String key, dynamic value) {
    if (_values[key] == value) {
      return;
    }

    setState(() {
      _values[key] = value;
    });
  }

  _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  _onNext() {
    if (_currentPage < questionnaireSteps.length - 1) {
      _focusNodes[currentStep.key]?.unfocus();
      _pageController.animateToPage(
        _currentPage + 1,
        duration: Duration(
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  _onPrevious() {
    if (_currentPage > 0) {
      _focusNodes[currentStep.key]?.unfocus();
      _pageController.animateToPage(
        _currentPage - 1,
        duration: Duration(
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  _onBack() {
    final navigationService = locator<NavigationService>();

    navigationService.pop();
  }

  _onCancel() {
    final navigationService = locator<NavigationService>();

    navigationService.popUntil((route) => route.isFirst);
  }

  _onComplete() async {
    _focusNodes[currentStep.key]?.unfocus();
    try {
      setState(() {
        _isLoading = true;
      });

      final suggestionService = locator<SuggestionService>();
      final navigationService = locator<NavigationService>();
      final locations =
          await suggestionService.suggestedLocations(stepValues(_values));

      navigationService.pushReplacement(
        MaterialPageRoute(
          builder: (context) => SwipeLocations(initialLocations: locations),
        ),
      );
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
