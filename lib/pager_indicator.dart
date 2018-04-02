import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_page_reveal/pages.dart';

class PagerIndicator extends StatelessWidget {
  final PagerIndicatorViewModel viewModel;

  PagerIndicator({this.viewModel});

  @override
  Widget build(BuildContext context) {
    List<PageBubble> bubbles = [];

    for (var i = 0; i < viewModel.pages.length; i++) {
      final page = viewModel.pages[i];
      var percentActive;
      var isHollow = i >= viewModel.activeIndex ||
          (i == viewModel.activeIndex &&
              viewModel.slideDirection == SlideDirection.leftToRight);

      if (i == viewModel.activeIndex) {
        percentActive = 1.0 - viewModel.slidePercent;
      } else if (i == viewModel.activeIndex - 1 &&
          viewModel.slideDirection == SlideDirection.leftToRight) {
        percentActive = viewModel.slidePercent;
      } else if (i == viewModel.activeIndex + 1 &&
          viewModel.slideDirection == SlideDirection.rightToLeft) {
        percentActive = viewModel.slidePercent;
      } else {
        percentActive = 0.0;
      }

      bubbles.add(new PageBubble(
        viewModel: new PageBubbleViewModel(
            page.iconAssetPath, page.color, isHollow, percentActive),
        onClickHandler: () {
          _onClickHandler(i);
        },
      ));
    }

    final BUBBLE_WIDTH = 55.0;
    final baseTranslation =
        ((BUBBLE_WIDTH * viewModel.pages.length) / 2) - (BUBBLE_WIDTH / 2);
    var translation = baseTranslation - (viewModel.activeIndex * BUBBLE_WIDTH);

    if (viewModel.slideDirection == SlideDirection.leftToRight) {
      translation += BUBBLE_WIDTH * viewModel.slidePercent;
    } else if (viewModel.slideDirection == SlideDirection.rightToLeft) {
      translation -= BUBBLE_WIDTH * viewModel.slidePercent;
    }

    return new Column(
      children: <Widget>[
        new Expanded(child: new Container()),
        new Transform(
            transform: new Matrix4.translationValues(translation, 0.0, 0.0),
            child: new Row(
                mainAxisAlignment: MainAxisAlignment.center, children: bubbles))
      ],
    );
  }

  void _onClickHandler(int activeIndex) {
    print("I'm clicked at $activeIndex");
  }
}

class PageBubble extends StatelessWidget {
  final PageBubbleViewModel viewModel;
  final GestureTapCallback onClickHandler;

  PageBubble({
    this.viewModel,
    this.onClickHandler,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: 55.0,
      height: 65.0,
      child: new GestureDetector(
        onTap: onClickHandler,
        child: new Center(
          child: new Container(
            width: lerpDouble(20.0, 45.0, viewModel.activePercent),
            height: lerpDouble(20.0, 45.0, viewModel.activePercent),
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isHollow
                  ? new Color(0x88FFFFFF)
                      .withAlpha((0x88 * viewModel.activePercent).round())
                  : new Color(0x88FFFFFF),
              border: new Border.all(
                  color: viewModel.isHollow
                      ? const Color(0x88FFFFFF).withAlpha(
                          (0x88 * (1.0 - viewModel.activePercent)).round())
                      : Colors.transparent,
                  width: 3.0),
            ),
            child: new Opacity(
              opacity: viewModel.activePercent,
              child: new Image.asset(
                viewModel.iconAssetPath,
                color: viewModel.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum SlideDirection { leftToRight, rightToLeft, none }

class PagerIndicatorViewModel {
  final List<PageViewModel> pages;
  final int activeIndex;
  final SlideDirection slideDirection;
  final double slidePercent;

  PagerIndicatorViewModel(
      this.pages, this.activeIndex, this.slideDirection, this.slidePercent);
}

class PageBubbleViewModel {
  final String iconAssetPath;
  final Color color;
  final bool isHollow;
  final double activePercent;

  PageBubbleViewModel(
      this.iconAssetPath, this.color, this.isHollow, this.activePercent);
}
