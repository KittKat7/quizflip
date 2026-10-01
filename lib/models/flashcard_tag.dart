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
  static final String prefix = '#';

  /// The separator separates different levels of the tag.
  static final String separator = '/';

  static final RegExp _validRegEx = RegExp(r'[A-Z0-9/]+');

  /// Validate tag strings
  static String _validateTag(String tagStr) {
    // Remove invalid characters
    tagStr.replaceAll(_validRegEx, '');
    // Remove starting `/` as first char
    while (tagStr.startsWith(separator)) {
      tagStr.replaceFirst(separator, '');
    }
    // Ensure tag string is NOT empty
    if (tagStr.isEmpty) throw Exception('Tag String is EMPTY');
    // Ensure tags start with `#`
    if (!tagStr.startsWith(prefix)) {
      tagStr = prefix + tagStr;
    }
    // Remove trailing `/`
    while (tagStr.endsWith(separator)) {
      tagStr = tagStr.substring(0, tagStr.length - 1);
    }
    // Remove double `//`
    while (tagStr.contains(separator + separator)) {
      tagStr.replaceAll(separator + separator, separator);
    }
    return tagStr;
  }

  /// The string representation of the tag.
  final String _tagStr;
  String get tagStr => _tagStr;

  /// Constructor.
  FlashcardTag({required String tagStr}) : _tagStr = _validateTag(tagStr);

  /// Checks if the provided tag is a prefix of this tag.
  bool hasPrefix(FlashcardTag tag) {
    return tag._tagStr == _tagStr ||
      _tagStr.startsWith(tag._tagStr + separator);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return (other as FlashcardTag).hashCode == hashCode;
  }

  @override
  int get hashCode => _tagStr.hashCode;

}

class FlashcardTagFilter {
  /// The internal tag for the filter
  FlashcardTag? _filter;
  /// Returns the tag string or empty string for the filter
  String get filterStr => _filter == null? '' : _filter!.tagStr;

  FlashcardTagFilter({required FlashcardTag? filter}) : _filter = filter;

  /// Checks if the provided tag passes the filter condition. Returns true if no
  /// filter is set or if the tag has the same prefix as the filter.
  bool passedFilter(FlashcardTag tag) {
    if (_filter == null) return true;
    return tag.hasPrefix(_filter!);
  }

  /// Update the filter by pop ing the last subtag
  void popSubtag() {
    if (_filter == null) return;
    String tagStr = _filter!.tagStr;
    if (!tagStr.contains(FlashcardTag.separator)) {
      _filter = null;
    } else {
      List<String> tagBits = tagStr.split(FlashcardTag.separator);
      tagBits.removeLast();
      FlashcardTag tag = FlashcardTag(tagStr: tagBits.join(FlashcardTag.separator));
      _filter = tag;
    }
  }

  /// Updates the internal filter state by appending the provided subtag string.
  void pushSubtag(String subtagStr) {
    if (_filter == null) {
      _filter = FlashcardTag(tagStr: subtagStr);
    } else {
      String tagStr = _filter!.tagStr;
      _filter = FlashcardTag(tagStr: tagStr + FlashcardTag.separator + subtagStr);
    }
  }

  /// Get the next subtag after the filter, or return null.
  String? getNextSubtagStr(FlashcardTag tag) {
    if (!passedFilter(tag)) return null;
    String tmpStr = tag.tagStr;
    tmpStr = tmpStr.substring((_filter == null? 0 : _filter!.tagStr.length));
    if (tmpStr.isEmpty) return null;
    if (tmpStr.startsWith(FlashcardTag.separator)) tmpStr = tmpStr.substring(1);
    return tmpStr.split(FlashcardTag.separator).first;
  }
}