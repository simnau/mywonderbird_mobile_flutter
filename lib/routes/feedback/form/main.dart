import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/components/typography/subtitle1.dart';
import 'package:mywonderbird/routes/feedback/form/steps.dart';
import 'package:mywonderbird/services/feedback.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:im_stepper/stepper.dart';

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
  bool _stepNext = false;
  bool _stepPrevious = false;
  int _currentStep = 0;

  Widget _buildTextField(
      TextEditingController controller, FocusNode focusNode) {
    return TextField(
      decoration: InputDecoration(border: OutlineInputBorder()),
      maxLines: 7,
      controller: controller,
      focusNode: focusNode,
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DotStepper(
          goNext: _stepNext,
          goPrevious: _stepPrevious,
          dotCount: feedbackSteps.length,
          indicatorEffect: IndicatorEffect.jump,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => navigationService.pop(),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (dragEndDetails) {
          if (dragEndDetails.primaryVelocity < 0) {
            _onNavigateForward();
          } else if (dragEndDetails.primaryVelocity > 0) {
            _onNavigateBack();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                itemCount: feedbackSteps.length,
                itemBuilder: (context, index) {
                  final step = feedbackSteps[index];
                  final contr = _controllers[feedbackSteps[_currentStep].key];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Subtitle1(
                        step.title,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                      Expanded(
                        child: _buildTextField(contr, _focusNodes[step.key]),
                      ),
                      if (_currentStep == feedbackSteps.length - 1)
                        RaisedButton(
                          child: BodyText1.light('Submit'),
                          onPressed: () => _onSubmit(),
                        ),
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          color: Colors.red,
                          child: BodyText1.light(_error),
                        ),
                      SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
            _buildStepper(),
          ]),
        ),
      ),
    );
  }

  _onPageChanged(int page) {
    if (_currentStep < page) {
      setState(() {
        _stepNext = true;
        _stepPrevious = false;
        _currentStep = page;
      });
    } else {
      setState(() {
        _stepNext = false;
        _stepPrevious = true;
        _currentStep = page;
      });
    }
  }

  _onNavigateForward() {
    if (_currentStep < feedbackSteps.length - 1) {
      _focusNodes[feedbackSteps[_currentStep].key]?.unfocus();

      _pageController.animateToPage(
        _currentStep + 1,
        duration: Duration(
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  _onNavigateBack() {
    if (_currentStep > 0) {
      _focusNodes[feedbackSteps[_currentStep].key]?.unfocus();
      _pageController.animateToPage(
        _currentStep - 1,
        duration: Duration(
          milliseconds: 400,
        ),
        curve: Curves.easeInOut,
      );
    }
  }

  _onSubmit() async {
    final feedbackService = locator<FeedbackService>();

    try {
      await feedbackService.submit(
          _controllers['like'].text,
          _controllers['improvements'].text,
          _controllers['newFunctionalities'].text);
      setState(() {
        _error = null;
      });

      await showDialog(
        context: context,
        child: AlertDialog(
          title: Text("Feedback"),
          content: Text("Was successfully sent!"),
          actions: <Widget>[
            MaterialButton(
                onPressed: () {
                  navigationService.pop();
                },
                child: Text('Close')),
          ],
        ),
        barrierDismissible: true,
      );
    } catch (e) {
      print(e);
      setState(() {
        _error = e.message;
      });
    } finally {
      navigationService.pop();
    }
  }
}