import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

String getUserName(types.User user) =>
    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
