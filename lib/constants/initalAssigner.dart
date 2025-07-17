class InitalAssigner {
  static Future<String> generateInitial(String text) async{
    var initial = text[0].toUpperCase();
    text.replaceFirst(text[0], initial);
    return text;
  }
}
