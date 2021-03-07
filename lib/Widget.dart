abstract class Widget{

  String title;
  String icon;
  String description;

  String getTitle() => this.title;
  String getIcon() => this.icon;
  String getDescription() => this.description;

  set setTitle(String t) => this.title = t;
  set setIcon(String t) => this.icon = t;
  set setDescription(String t) => this.description = t;


}