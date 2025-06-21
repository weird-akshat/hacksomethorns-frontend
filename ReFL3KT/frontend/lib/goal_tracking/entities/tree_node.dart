class TreeNode {
  String name;
  TreeNode({required this.name, required this.id});
  TreeNode? parent;
  List<TreeNode> children = [];

  int id;

  String? description;
  int? parentId; // goal ID of parent (
  String status = 'active';
  String priority = 'medium';
  String? deadline; // ISO 8601 string
  bool isGroupGoal = false;

  void addChild(TreeNode node) {
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
  }

  void changeParent(TreeNode newParent) {
    parent?.children.remove(this);
    parent = newParent;
    newParent.children.add(this);
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'name': name,
      'description': description ?? '',
      'id': id,
      'user': userId,
      'parent': parentId,
      'status': status == "active" ? "not_started" : "completed",
      'priority': priority,
      'deadline': deadline,
    };
  }

  factory TreeNode.fromJson(Map<String, dynamic> json) {
    return TreeNode(
      name: json['name'],
      id: json['id'],
    )
      ..description = json['description']
      ..parentId = json['parent']
      ..status = json['status'] == 'not_started' ? 'active' : 'completed'
      ..priority = json['priority']
      ..deadline = json['deadline']
      ..isGroupGoal = json['is_group_goal'] ?? false;
  }
}
