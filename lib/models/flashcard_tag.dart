/// A tag class to be used for sorting flashcards.
/// Valid tag example: `#super/cool`
/// 1. A tag string CAN NOT be empty
/// 2. A tag string can be made from capital letters, numerics, with `#` as the
/// prefix and `/` as the separator
/// 3. A tag MUST start with `#` as the prefix, and CANNOT have `/` immediately
/// following
/// 4. Tags MUST NOT end with the separator `/`
/// 5. Double separators are NOT permitted, IE `//`
class FlashcardTag {

  /// The prefix for the tags, this is used mostly in display.
  static final String _prefix = '#';

  /// The separator separates different levels of the tag.
  static final String _separator = '/';

  static final RegExp _validRegEx = RegExp(r'[A-Z0-9/]+');

  /// Validate tag strings
  static String _validateTag(String tagStr) {
    // Remove invalid characters
    tagStr.replaceAll(_validRegEx, '');
    // Remove starting `/` as first char
    while (tagStr.startsWith(_separator)) {
      tagStr.replaceFirst(_separator, '');
    }
    // Ensure tag string is NOT empty
    if (tagStr.isEmpty) throw Exception('Tag String is EMPTY');
    // Ensure tags start with `#`
    if (!tagStr.startsWith(_prefix)) {
      tagStr = _prefix + tagStr;
    }
    // Remove trailing `/`
    while (tagStr.endsWith(_separator)) {
      tagStr = tagStr.substring(0, tagStr.length - 1);
    }
    // Remove double `//`
    while (tagStr.contains(_separator + _separator)) {
      tagStr.replaceAll(_separator + _separator, _separator);
    }
    return tagStr;
  }

  /// The string representation of the tag.
  final String _tagStr;

  /// Constructor.
  FlashcardTag({required String tagStr}) : _tagStr = _validateTag(tagStr);

  /// Checks if the provided tag is a prefix of this tag.
  bool hasPrefix(FlashcardTag tag) {
    return tag._tagStr == _tagStr ||
      _tagStr.startsWith(tag._tagStr + _separator);
  }

  /// Returns a new tag with the last subtag popped.
  FlashcardTag? popTag() {
    if (!_tagStr.contains(_separator)) return null;
    List<String> tagBits = _tagStr.split(_separator);
    tagBits.removeLast();
    FlashcardTag tag = FlashcardTag(tagStr: tagBits.join(_separator));
    return tag;
  }

  /// Returns a new tag with the new subtag added.
  FlashcardTag pushTag(String subtagStr) {
    return FlashcardTag(tagStr: _tagStr + _separator + subtagStr);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return (other as FlashcardTag).hashCode == hashCode;
  }

  @override
  int get hashCode => _tagStr.hashCode;

}