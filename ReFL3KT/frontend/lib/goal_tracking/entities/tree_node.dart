class TreeNode {
  String name;
  TreeNode(
      {required this.name,
      required this.id,
      required this.priority,
      this.deadline});
  TreeNode? parent;
  List<TreeNode> children = [];

  int id;

  String? description;
  int? parentId; // goal ID of parent (
  String status = 'active';
  String priority;
  DateTime? deadline; // ISO 8601 string
  bool isGroupGoal = false;

  void addChild(TreeNode node) {
    print(node.toJson('100'));
    node.parent = this;
    node.parentId = id;

    children.add(node);
    node.parent = this;
  }

  void addChildren(List<TreeNode> list) {
    for (var node in list) {
      addChild(node);
    }
  }

  void removeChild(TreeNode node) {
    children.remove(node);
    node.parent = null;
    node.parentId = 0;
  }

  void changeParent(TreeNode newParent) {
    parent?.children.remove(this);
    parent = newParent;
    newParent.children.add(this);
  }

  Map<String, dynamic> toJson(
    String userId,
  ) {
    return {
      "name": name,
      "description": description?.isEmpty == true ? null : description,
      "user": userId,
      "parent": parent?.id ?? null,
      "priority": priority,
      "deadline": deadline?.toIso8601String(),
      "is_group_goal": isGroupGoal,
    };
  }

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    return TreeNode(
      priority: json['priority'],
      name: json['name'],
      id: json['id'],
      deadline: DateTime.parse(json['deadline']),
    )
      ..description = json['description']
      ..parentId = json['parent']
      ..status = json['status'] == 'not_started' ? 'active' : 'completed'
      // ..priority = json['priority']
      ..isGroupGoal = json['is_group_goal'] ?? false;
  }
}
