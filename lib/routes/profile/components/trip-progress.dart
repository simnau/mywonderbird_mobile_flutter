import 'package:flutter/material.dart';
import 'package:mywonderbird/components/custom-icons.dart';

class TripProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const TripProgress({
    Key key,
    @required this.currentStep,
    @required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          flex: totalSteps - currentStep,
          child: Container(
            color: Colors.grey,
            height: 8,
          ),
        ),
        Expanded(
          flex: currentStep,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                color: theme.accentColor,
                height: 8,
              ),
              Positioned(
                bottom: -6,
                right: -20,
                child: Icon(
                  CustomIcons.bird,
                  size: 36,
                  color: theme.accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
