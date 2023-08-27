class StringUtils {
  static String combineEventTypeAndIdForModify(
          String eventTypeName, dynamic idForModify) =>
      '$eventTypeName,$idForModify';
}
