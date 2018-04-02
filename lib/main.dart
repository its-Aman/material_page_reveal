import 'package:flutter/material.dart';
import 'page_dragger.dart';
import 'page_reveal.dart';
import 'pager_indicator.dart';
import 'pages.dart';
import 'dart:async';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimatedPageDragger animatedPageDragger;
  StreamController<SlideUpdate> slideUpdateStream;

  int activeIndex = 0;
  int nextPageIndex = 0;
  SlideDirection slideDirection = SlideDirection.none;
  double slidePercent = 0.0;

  _MyHomePageState() {
    slideUpdateStream = new StreamController<SlideUpdate>();

    slideUpdateStream.stream.listen((SlideUpdate event) {
      setState(() {
        if (event.updateType == UpdateType.dragging) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;

          if (slideDirection == SlideDirection.leftToRight) {
            nextPageIndex = activeIndex - 1;
          } else if (slideDirection == SlideDirection.rightToLeft) {
            nextPageIndex = activeIndex + 1;
          } else {
            nextPageIndex = activeIndex;
          }
        } else if (event.updateType == UpdateType.doneDragging) {
          print('Done Dragging');
          if (slidePercent > 0.5) {
            animatedPageDragger = new AnimatedPageDragger(
                slideDirection: slideDirection,
                transitionGoal: TransitionGoal.open,
                slidePercent: slidePercent,
                slideUpdateStream: slideUpdateStream,
                vsync: this);
          } else {
            animatedPageDragger = new AnimatedPageDragger(
                slideDirection: slideDirection,
                transitionGoal: TransitionGoal.close,
                slidePercent: slidePercent,
                slideUpdateStream: slideUpdateStream,
                vsync: this);

            nextPageIndex = activeIndex;
          }

          animatedPageDragger.run();
        } else if (event.updateType == UpdateType.animating) {
          slideDirection = event.direction;
          slidePercent = event.slidePercent;
        } else if (event.updateType == UpdateType.doneAnimating) {
          print('Done Aminatin. Next page index $nextPageIndex');
          activeIndex = nextPageIndex;
          slideDirection = SlideDirection.none;
          slidePercent = 0.0;

          animatedPageDragger.dispose();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          new Page(
            viewModel: pages[activeIndex],
            percentVisible: 1.0,
          ),
          new PageReveal(
              revealPercent: slidePercent,
              child: new Page(
                viewModel: pages[nextPageIndex],
                percentVisible: slidePercent,
              )),
          // new Page(viewModel: pages[2], percentVisible: 1.0,)
          new PagerIndicator(
              viewModel: new PagerIndicatorViewModel(
                  pages, activeIndex, slideDirection, slidePercent)),
          new PageDragger(
            slideUpdateSteam: this.slideUpdateStream,
            canDragLeftToRight: activeIndex > 0,
            canDragRightToLeft: activeIndex < pages.length - 1,
          ),
        ],
      ),
    );
  }
}
