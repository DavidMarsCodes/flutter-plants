import 'package:chat/models/profilesDispensaries_response.dart';
import 'package:chat/models/profiles_response.dart';
import 'package:chat/models/subscribe.dart';

import 'package:chat/providers/subscription_provider.dart';

class SubscriptionRepository {
  SubscriptionApiProvider _apiProvider = SubscriptionApiProvider();

  Future<Subscription> getSubscription(String userAuth, String userId) {
    return _apiProvider.getSubscription(userAuth, userId);
  }

  Future<ProfilesDispensariesResponse> getProfilesSubsciptionsPending(
      String userId) {
    return _apiProvider.getProfilesSubscriptionsByUser(userId);
  }

  Future<ProfilesDispensariesResponse> getProfilesSubsciptionsApprove(
      String userId) {
    return _apiProvider.getProfilesSubsciptionsApprove(userId);
  }

  Future<ProfilesResponse> getProfilesSubsciptionsApproveNotifi(String userId) {
    return _apiProvider.getProfilesSubsciptionsApproveNotifi(userId);
  }
}
