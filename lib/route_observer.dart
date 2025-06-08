// import 'package:flutter/material.dart';
// import 'state/navigation_state.dart';

// class RouteObserverImpl extends RouteObserver<PageRoute<dynamic>> {
//   final NavigationState navigationState;

//   RouteObserverImpl(this.navigationState);

//   void _sendScreenView(PageRoute<dynamic> route) {
//     final routeName = route.settings.name;
//     if (routeName != null && routeName != navigationState.currentRoute) {
//       navigationState.updateRoute(routeName);
//     }
//   }

//   @override
//   void didPush(Route route, Route? previousRoute) {
//     super.didPush(route, previousRoute);
//     if (route is PageRoute) {
//       _sendScreenView(route);
//     }
//   }

//   @override
//   void didReplace({Route? newRoute, Route? oldRoute}) {
//     super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
//     if (newRoute is PageRoute) {
//       _sendScreenView(newRoute);
//     }
//   }

//   @override
//   void didPop(Route route, Route? previousRoute) {
//     super.didPop(route, previousRoute);
//     if (previousRoute is PageRoute) {
//       _sendScreenView(previousRoute);
//     }
//   }
// }
