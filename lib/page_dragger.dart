import 'package:flutter/material.dart';
import 'pager_indicator.dart';
import 'dart:async';
import 'dart:ui';

class PageDragger extends StatefulWidget {
  final StreamController<SlideUpdate> slideUpdateSteam;
  final bool canDragLeftToRight;
  final bool canDragRightToLeft;

  PageDragger(
      {this.slideUpdateSteam,
      this.canDragLeftToRight,
      this.canDragRightToLeft});

  @override
  _PageDraggerState createState() => new _PageDraggerState();
}

class _PageDraggerState extends State<PageDragger> {
  static const double FULL_TRANSITION_PX = 300.0;

  Offset dragStart;
  SlideDirection slideDirection;
  double slidePercentage;

  onDragStart(DragStartDetails details) {
    dragStart = details.globalPosition;
  }

  onDragUpdate(DragUpdateDetails details) {
    if (dragStart != null) {
      final newPositon = details.globalPosition;
      final dx = dragStart.dx - newPositon.dx;

      if (dx > 0.0 && widget.canDragRightToLeft) {
        slideDirection = SlideDirection.rightToLeft;
      } else if (dx < 0.0 && widget.canDragLeftToRight) {
        slideDirection = SlideDirection.leftToRight;
      } else {
        slideDirection = SlideDirection.none;
      }

      if (slideDirection != SlideDirection.none) {
        slidePercentage = (dx / FULL_TRANSITION_PX).abs().clamp(0.0, 1.0);
      } else {
        slidePercentage = 0.0;
      }

      print('Dragging $slideDirection at $slidePercentage');

      widget.slideUpdateSteam.add(new SlideUpdate(
          slideDirection, slidePercentage, UpdateType.dragging));
    }
  }

  onDragEnd(DragEndDetails details) {

    widget.slideUpdateSteam.add(
        new SlideUpdate(SlideDirection.none, 0.0, UpdateType.doneDragging));
        
    dragStart = null;
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onHorizontalDragStart: onDragStart,
      onHorizontalDragUpdate: onDragUpdate,
      onHorizontalDragEnd: onDragEnd,
    );
  }
}

enum UpdateType { dragging, doneDragging, animating, doneAnimating }

class SlideUpdate {
  final SlideDirection direction;
  final double slidePercent;
  final UpdateType updateType;

  SlideUpdate(this.direction, this.slidePercent, this.updateType);
}

class AnimatedPageDragger {
  static const double PERCENT_PER_MILISECOND = 0.005;
  final SlideDirection slideDirection;
  final TransitionGoal transitionGoal;
  AnimationController completeAnimationController;

  AnimatedPageDragger(
      {this.slideDirection,
      this.transitionGoal,
      slidePercent,
      StreamController<SlideUpdate> slideUpdateStream,
      TickerProvider vsync}) {

    final double startSlidePercent = slidePercent;
    double endSlidePercent;
    Duration duration;

    if (transitionGoal == TransitionGoal.open) {
      endSlidePercent = 1.0;
      final slideRemaining = 1.0 - slidePercent;
      duration = new Duration(
          milliseconds: (slideRemaining / PERCENT_PER_MILISECOND).round());
    } else {
      endSlidePercent = 0.0;
      duration = new Duration(
          milliseconds: (slidePercent / PERCENT_PER_MILISECOND).round());
    }

    completeAnimationController =
        new AnimationController(vsync: vsync, duration: duration)
          ..addListener(() {
            final double slidePercent = lerpDouble(
              startSlidePercent,
              endSlidePercent, 
              completeAnimationController.value
              );
            slideUpdateStream.add(new SlideUpdate(
                slideDirection, slidePercent, UpdateType.animating));
          })
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              slideUpdateStream.add(new SlideUpdate(
                  slideDirection, endSlidePercent, UpdateType.doneAnimating));
            }
          });
  }

  run() {
    completeAnimationController.forward(from: 0.0);
  }

  dispose() {
    completeAnimationController.dispose();
  }
}

enum TransitionGoal {
  open,
  close,
}
