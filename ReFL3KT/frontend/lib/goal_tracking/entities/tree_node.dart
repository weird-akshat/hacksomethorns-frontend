class TreeNode {
  TreeNode? parent;
  List<TreeNode> children = [];

  void addChild(TreeNode node) {
    children.add(node);
  }

  void addChildren(List<TreeNode> list) {
    children.addAll(list);
  }

  void removeChild(TreeNode node) {
    children.remove(node);
  }

  void changeParent(TreeNode parent) {
    this.parent = parent;
  }
}
