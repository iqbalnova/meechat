import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

String getUserName(types.User user) =>
    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

final customCacheManager = CacheManager(
  Config(
    'customCacheKey',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 20,
  ),
);
