import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/routes/feedback/form/steps.dart';
import 'package:mywonderbird/services/feedback.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:im_stepper/stepper.dart';
import 'package:mywonderbird/util/sentry.dart';

import '../../../locator.dart';

class FeedbackForm extends StatefulWidget {
  static const RELATIVE_PATH = 'feedback';
  static const PATH = "/$RELATIVE_PATH";

  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final navigationService = locator<NavigationService>();
  final PageController _pageController = PageController();
  final Map<String, FocusNode> _focusNodes = {
    'like': FocusNode(),
    'improvements': FocusNode(),
    'newFunctionalities': FocusNode(),
  };

  final Map<String, TextEditingController> _controllers = {
    'like': TextEditingController(),
    'improvements': TextEditingController(),
    'newFunctionalities': TextEditingController(),
  };

  String _error;
  bool _changePage = true;
  int _currentStep = 0;

  bool get _isLastStep => _currentStep == feedbackSteps.length - 1;
  bool get _isFirstPageSelected => _currentStep == 0;

  Widget _buildTextField(
      TextEditingController controller, FocusNode focusNode) {
    return TextField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        hintText: 'Enter feedback',
      ),
      maxLines: 7,
      controller: controller,
      focusNode: focusNode,
    );
  }

  Widget _buildStepper() {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DotStepper(
          activeStep: _currentStep,
          dotCount: feedbackSteps.length,
          onDotTapped: _onDotTapped,
          indicator: Indicator.jump,
          dotRadius: 12.0,
          spacing: 4.0,
          indicatorDecoration: IndicatorDecoration(color: theme.accentColor),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: _isFirstPageSelected
            ? null
            : IconButton(
                icon: BackButtonIcon(),
                onPressed: _onNavigateBack,
              ),
        actions: <Widget>[
          TextButton(
            onPressed: _isLastStep ? _onSubmit : _onNavigateForward,
            child: Text(
              _isLastStep ? 'SUBMIT' : 'NEXT',
              style: TextStyle(color: theme.primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: feedbackSteps.length,
                itemBuilder: (context, index) {
                  final step = feedbackSteps[index];
                  final contr = _controllers[feedbackSteps[_currentStep].key];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          alignment: Alignment.center,
                          color: Colors.red,
                          child: BodyText1.light(_error),
                        ),
                      Subtitle1(
                        step.title,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 48.0),
                      Expanded(
                        child: _buildTextField(contr, _focusNodes[step.key]),
                      ),
                      SizedBox(height: 32.0),
                    ],
                  );
                },
              ),
            ),
            _buildStepper(),
            TextButton(
              child: BodyText1(
                'Cancel',
                color: theme.errorColor,
              ),
              onPressed: _onCancel,
            ),
          ],
        ),
      ),
    );
  }

  _onPageChanged(int page) {
    if (_changePage) {
      setState(() {
        _currentStep = page;
      });
    } else {
      _changePage = true;
    }
  }

  _onNavigateForward() {
    if (_currentStep < feedbackSteps.length - 1) {
      _focusNodes[feedbackSteps[_currentStep].key]?.unfocus();
      _changePage = false;

      _pageController.animateToPage(
        _currentStep + 1,
        duration: Duration(
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = _currentStep + 1;
      });
    }
  }

  _onNavigateBack() {
    if (_currentStep > 0) {
      _focusNodes[feedbackSteps[_currentStep].key]?.unfocus();
      _changePage = false;

      _pageController.animateToPage(
        _currentStep - 1,
        duration: Duration(
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = _currentStep - 1;
      });
    }
  }

  _onDotTapped(tappedDotIndex) {
    _focusNodes[feedbackSteps[_currentStep].key]?.unfocus();
    _changePage = false;
    setState(() {
      _currentStep = tappedDotIndex;
    });
    _pageController.animateToPage(
      tappedDotIndex,
      duration: Duration(
        milliseconds: 400,
      ),
      curve: Curves.easeInOut,
    );
  }

  _onCancel() {
    navigationService.pop();
  }

  _onSubmit() async {
    final feedbackService = locator<FeedbackService>();

    try {
      setState(() {
        _error = null;
      });
      await feedbackService.submit(
          _controllers['like'].text,
          _controllers['improvements'].text,
          _controllers['newFunctionalities'].text);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Feedback"),
          content: Text("Was successfully sent!"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                navigationService.pop(true);
              },
              child: Text('Close'),
            ),
          ],
        ),
        barrierDismissible: true,
      );
      navigationService.pop(true);
    } catch (e, stackTrace) {
      await reportError(e, stackTrace);
      setState(() {
        _error = e.message;
      });
    }
  }
}
