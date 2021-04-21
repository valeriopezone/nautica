import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import './item.dart';
import './notifier.dart';
import './provider.dart';

export './item.dart';

class ReorderableWrap extends StatelessWidget {


  List<StaggeredTile> tileInfo = <StaggeredTile>[
     StaggeredTile.count(2, 2),
     StaggeredTile.count(2, 1),
     StaggeredTile.count(1, 2),
     StaggeredTile.count(1, 1),
     StaggeredTile.count(2, 2),
     StaggeredTile.count(1, 2),
     StaggeredTile.count(1, 1),
     StaggeredTile.count(3, 1),
     StaggeredTile.count(1, 1),
     StaggeredTile.count(4, 1),
  ];



  ReorderableWrap({
    @required this.children,
    @required this.onReorder,
    @required this.tileInfo,
    Key key,
  }) : super(key: key);

  final List<ReorderableWrapItem> children;
  final Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {

    return ReorderableWrapProvider(
      onReorder: onReorder,
      notifier: ReorderableWrapNotifier<ReorderableWrapItem>(
        children: children,
      ),
      child: Builder(
        builder: (_context) {
          final provider = ReorderableWrapProvider.of(_context);
          return Listener(
            onPointerMove: (e) {
              final box = provider.feedbackBox;
              if (false == provider.state.active || null == box) {
                return;
              }
              final offset = box.localToGlobal(Offset.zero);
              final newIndex = _findIndex(
                  offset, provider.state.offsets, provider.state.size);
              provider.move(provider.state.newIndex, newIndex);
            },
           // child: Wrap(
           //   children: provider.notifier.children,
           // ),

              child :  StaggeredGridView.count(
                crossAxisCount: 4,
                staggeredTiles: tileInfo,
                children: provider.notifier.children,
                mainAxisSpacing: 0.0,
                crossAxisSpacing: 0.0,
              )


          );
        },
      ),
    );
  }
}

int _findIndex(Offset offset, List<Offset> offsets, Size size) {
  final firstOffset = offsets[0];
  var index = 0;
  try {
    offsets.asMap().forEach((i, item) {
      final dx = offset.dx + size.width / 2;
      final dy = offset.dy + size.height / 2;
      if ((dx > item.dx && dy > item.dy) ||
          (dx > item.dx && dy < firstOffset.dy && firstOffset.dy == item.dy) ||
          (dy > item.dy && dx < firstOffset.dx && firstOffset.dx == item.dx)) {
        index = i;
      }
    });
    return index;
  } on Exception catch (e) {
    print('Error: _findIndex@ReorderableWrap\n${e.toString()}');
    return 0;
  }
}

