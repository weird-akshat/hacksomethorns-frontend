import 'dart:math';

import 'package:flutter/material.dart';
import 'package:frontend/goal_tracking/configuration.dart';
import 'package:frontend/goal_tracking/entities/tree_node.dart';
import 'package:frontend/goal_tracking/widgets/edge_widget.dart';
import 'package:frontend/goal_tracking/widgets/goal_widget.dart';

class GraphView extends StatefulWidget {
  final TreeNode root;

  const GraphView({super.key, required this.root});

  @override
  State<GraphView> createState() => _GraphViewState();
}

class _GraphViewState extends State<GraphView> {
  List<Widget> goals = [];
  List<Widget> edges = [];
  late Map<TreeNode, Offset> positions;
  final _transformationController = TransformationController();

  double findTreeWidth(Map<TreeNode, Offset> map) {
    double max = 0;
    double min = double.maxFinite;

    for (var entry in map.entries) {
      if (entry.value.dx > max) {
        max = entry.value.dx;
      } else if (entry.value.dx < min) {
        min = entry.value.dx;
      }
    }
    return max + GOAL_WIDGET_WIDTH;
  }

  int findTreeHeight(TreeNode node) {
    if (node == null) {
      return 0;
    } else {
      int max = 0;
      for (TreeNode child in node.children) {
        int x = findTreeHeight(child);
        if (x > max) {
          max = x;
        }
      }
      return max + 1;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    positions = tidyTreeLayout(widget.root,
        rootPosition: Offset(MediaQuery.of(context).size.width / 2, 0));
    verifyPosition(positions);
    stackWidth = findTreeWidth(positions) + GOAL_WIDGET_WIDTH;
    stackHeight = (findTreeHeight(widget.root)) * levelSeparation;

    dfs(widget.root);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rootPos = positions[widget.root]!;
      final screenSize = MediaQuery.of(context).size;

// Center the root node on the screen
      final dx = screenSize.width / 2 - (rootPos.dx + GOAL_WIDGET_WIDTH / 2);
      final dy = 20.0; // Optional vertical padding from top

      _transformationController.value = Matrix4.identity()..translate(dx, dy);
    });
  }

  void dfs(TreeNode node) {
    goals.add(GoalWidget(offset: positions[node]!, treeNode: node));

    for (var child in node.children) {
      edges.add(EdgeWidget(
          from: positions[node]! +
              Offset(GOAL_WIDGET_WIDTH / 2, GOAL_WIDGET_HEIGHT / 2),
          to: positions[child]! +
              Offset(GOAL_WIDGET_WIDTH / 2, GOAL_WIDGET_HEIGHT / 2)));
      dfs(child);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Goal Hierarchy",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.0005,

          maxScale: 10,
          // boundaryMargin: const EdgeInsets.all(2000),

          constrained: false,
          scaleEnabled: true,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
                width: stackWidth,
                height: stackHeight,
                child: Stack(children: edges + goals)),
          ),
        ),
      ),
    );
  }
}

class _RTTNode {
  final TreeNode treeNode;
  _RTTNode? parent, leftSibling;
  List<_RTTNode> children = [];
  double prelim = 0, modifier = 0;
  double? x, y; // Final positions
  _RTTNode(this.treeNode);
}

bool verifyPosition(Map<TreeNode, Offset> map) {
  double minSeparation = GOAL_WIDGET_WIDTH + 150;
  bool changed = false;

  // Group nodes by their vertical level (dy)
  Map<double, List<MapEntry<TreeNode, Offset>>> levels = {};

  for (var entry in map.entries) {
    levels.putIfAbsent(entry.value.dy, () => []).add(entry);
  }

  final updated = Map<TreeNode, Offset>.from(map);

  // For each vertical level
  for (var entries in levels.values) {
    entries.sort((a, b) => a.value.dx.compareTo(b.value.dx));

    for (int i = 1; i < entries.length; i++) {
      final prev = entries[i - 1];
      final curr = entries[i];

      double separation = curr.value.dx - updated[prev.key]!.dx;

      if (separation < minSeparation) {
        double shift = minSeparation - separation;
        Offset newOffset = Offset(curr.value.dx + shift, curr.value.dy);
        updated[curr.key] = newOffset;
        changed = true;
      }
    }
  }

  map
    ..clear()
    ..addAll(updated);

  return changed ? verifyPosition(map) : true;
}

Map<TreeNode, Offset> tidyTreeLayout(
  TreeNode root, {
  required Offset rootPosition,
}) {
  _RTTNode build(TreeNode tn, _RTTNode? parent) {
    final n = _RTTNode(tn)..parent = parent;
    for (var c in tn.children) {
      final childWrapper = build(c, n);
      if (n.children.isNotEmpty) {
        childWrapper.leftSibling = n.children.last;
      }
      n.children.add(childWrapper);
    }
    return n;
  }

  final wrappedRoot = build(root, null);
  void moveSubtree(_RTTNode node, double shift) {
    node.prelim += shift;
    node.modifier += shift;
  }

  void apportion(_RTTNode v) {
    final leftSibling = v.leftSibling!;
    var vip = v;
    var vim = leftSibling;

    var sip = vip.modifier;
    var sim = vim.modifier;

    var vipRight = vip.children.isNotEmpty ? vip.children.first : null;
    var vimLeft = vim.children.isNotEmpty ? vim.children.last : null;

    double shift = 0;
    int level = 1;

    while (vipRight != null && vimLeft != null) {
      final diff = (vimLeft.prelim + sim) - (vipRight.prelim + sip);
      if (diff + subtreeSeparation > 0) {
        shift += diff + subtreeSeparation;
        moveSubtree(v, shift);
        sip += shift;
      }

      vipRight = vipRight.children.isNotEmpty ? vipRight.children.first : null;
      vimLeft = vimLeft.children.isNotEmpty ? vimLeft.children.last : null;
      sip += vip.modifier;
      sim += vim.modifier;

      level++;
    }
  }

  void firstWalk(_RTTNode v) {
    for (var c in v.children) {
      firstWalk(c);
    }

    if (v.children.isEmpty) {
      v.prelim = v.leftSibling == null
          ? 0
          : v.leftSibling!.prelim + GOAL_WIDGET_WIDTH + siblingSeparation;
    } else if (v.children.length == 1) {
      final child = v.children.first;
      v.prelim = child.prelim;
    } else {
      final first = v.children.first;
      final last = v.children.last;
      v.prelim = (first.prelim + last.prelim) / 2;
    }

    if (v.leftSibling != null) {
      apportion(v);
    }
  }

  void secondWalk(_RTTNode v, double modSum, int depth, double xOffset) {
    final x = v.prelim + modSum + xOffset - GOAL_WIDGET_WIDTH / 2;
    final y = rootPosition.dy + levelSeparation * depth;

    v.x = x;
    v.y = y;

    for (var c in v.children) {
      secondWalk(c, modSum + v.modifier, depth + 1, xOffset);
    }
  }

  double findMinX(_RTTNode v, double modSum) {
    double minX = v.prelim + modSum;
    for (var c in v.children) {
      minX = min(minX, findMinX(c, modSum + v.modifier));
    }
    return minX;
  }

  // Run layout
  firstWalk(wrappedRoot);
  final minX = findMinX(wrappedRoot, 0);
  final xOffset = rootPosition.dx - minX;
  secondWalk(wrappedRoot, 0, 0, xOffset);

  // Collect results
  final Map<TreeNode, Offset> result = {};
  void collect(_RTTNode v) {
    result[v.treeNode] = Offset(v.x!, v.y!);
    for (var c in v.children) collect(c);
  }

  collect(wrappedRoot);
  return result;
}
