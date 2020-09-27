import 'package:flutter/material.dart';
import 'package:mywonderbird/components/typography/body-text1.dart';
import 'package:mywonderbird/locator.dart';
import 'package:mywonderbird/routes/home/main.dart';
import 'package:mywonderbird/routes/terms/components/initial.dart';
import 'package:mywonderbird/routes/terms/components/updated.dart';
import 'package:mywonderbird/services/navigation.dart';
import 'package:mywonderbird/services/terms.dart';

class TermsPage extends StatefulWidget {
  static const RELATIVE_PATH = 'terms';
  static const PATH = "/$RELATIVE_PATH";

  final bool isUpdate;

  const TermsPage({
    Key key,
    @required this.isUpdate,
  }) : super(key: key);

  @override
  _TermsPageState createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool _termsAccepted = false;
  bool _newsletterAccepted = false;
  String _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 64.0,
                    bottom: 32.0,
                    left: 32.0,
                    right: 32.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.center,
                          color: Colors.red,
                          child: BodyText1.light(_error),
                        ),
                      widget.isUpdate
                          ? UpdatedTerms(
                              termsAccepted: _termsAccepted,
                              onChangedAcceptTerms: _onChangedAcceptTerms,
                              onContinue: _onContinueUpdate,
                            )
                          : InitialTerms(
                              termsAccepted: _termsAccepted,
                              newsletterAccepted: _newsletterAccepted,
                              onChangedAcceptTerms: _onChangedAcceptTerms,
                              onChangedAcceptNewsletter:
                                  _onChangedAcceptNewsletter,
                              onContinue: _onContinue,
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _onChangedAcceptTerms(value) {
    setState(() {
      _termsAccepted = value;
    });
  }

  _onChangedAcceptNewsletter(value) {
    setState(() {
      _newsletterAccepted = value;
    });
  }

  _onContinue() async {
    try {
      setState(() {
        _error = null;
      });
      await locator<TermsService>()
          .acceptTerms(_termsAccepted, acceptedNewsletter: _newsletterAccepted);

      final navigationService = locator<NavigationService>();
      navigationService.popUntil((route) => route.isFirst);
      navigationService.pushReplacementNamed(HomePage.PATH);
    } catch (e) {
      setState(() {
        _error = e.message;
      });
    }
  }

  _onContinueUpdate() async {
    try {
      setState(() {
        _error = null;
      });
      await locator<TermsService>().acceptTerms(_termsAccepted);

      final navigationService = locator<NavigationService>();
      navigationService.popUntil((route) => route.isFirst);
      navigationService.pushReplacementNamed(HomePage.PATH);
    } catch (e) {
      setState(() {
        _error = e.message;
      });
    }
  }
}
