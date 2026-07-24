# Wanderlust Migration Plan: Apply Agro-Prod Architecture

## Overview
Apply all architectural improvements from Agro-Prod to Wanderlust while preserving:
- Firebase project configuration
- google-services.json
- firebase_options.dart
- Firestore schema
- Authentication
- Chat data
- Notifications
- Assets
- Business logic

## Phase 1: Authentication (Login, Register, AuthService, Welcome, Tour Date, Splash/Root Decider, Admin Home)

### Phase 1 Tasks:
- [x] **Splash Binding** - Already done ✓
- [ ] **AuthService** - Update to extend AppBaseService with proper _initialize/_dispose
- [ ] **Login Controller** - Clean up unused imports, remove dead code
- [ ] **Register Controller** - Refactor to follow Agro-Prod patterns
- [ ] **Welcome Controller** - Refactor to follow Agro-Prod patterns
- [ ] **Tour Date Question Controller** - Refactor to follow Agro-Prod patterns
- [ ] **Admin Home Controller** - Refactor to follow Agro-Prod patterns
- [ ] **Splash Controller** - Remove unused field _authService, clean up imports
- [ ] **Login Binding** - Ensure uses BaseBinding pattern
- [ ] **Register Binding** - Ensure uses BaseBinding pattern
- [ ] **Welcome Binding** - Ensure uses BaseBinding pattern
- [ ] **Tour Date Question Binding** - Ensure uses BaseBinding pattern
- [ ] **Admin Home Binding** - Ensure uses BaseBinding pattern
- [ ] **Views** - Update to use AppBaseView pattern

### Verification:
- [ ] `flutter analyze` - No new errors
- [ ] Navigation works: Splash → Login → Welcome/TourDate/Admin
- [ ] Firebase authentication works
- [ ] Remember me functionality works

## Phase 2: User List & Responses

### Phase 2 Tasks:
- [ ] **User List Controller** - Refactor to Agro-Prod patterns
- [ ] **User List Binding** - BaseBinding pattern
- [ ] **User List Screen** - AppBaseView pattern
- [ ] **Responses Controller** - Refactor to Agro-Prod patterns
- [ ] **Responses Binding** - BaseBinding pattern
- [ ] **Responses Screen** - AppBaseView pattern

### Verification:
- [ ] `flutter analyze` - No new errors
- [ ] Navigation works
- [ ] Data loading works

## Phase 3: Complete Chat Refactor

### Phase 3 Tasks:
- [ ] **Chat Model** - Ensure follows Agro-Prod patterns
- [ ] **Chat Service** - Move all Firebase operations to service
- [ ] **Chat Controller** - Presentation logic only
- [ ] **Chat Binding** - BaseBinding pattern
- [ ] **Chat Screen** - AppBaseView pattern
- [ ] **Chat Widgets** (MessageBubble, MessagesListView, MessageInputField) - Clean architecture
- [ ] **Chat Routing** - Ensure proper GetX routing

### Verification:
- [ ] `flutter analyze` - No new errors
- [ ] Chat functionality works
- [ ] Real-time messaging works
- [ ] FCM notifications work

## Phase 4: Lock Screen & Background Services

### Phase 4 Tasks:
- [ ] **Lock Model** - Follow Agro-Prod patterns
- [ ] **Lock Service** - Extend AppBaseService
- [ ] **Lock Controller** - Presentation logic only
- [ ] **Lock Binding** - BaseBinding pattern
- [ ] **Lock Screen** - AppBaseView pattern
- [ ] **ActiveChatTracker** - Service for tracking active chats
- [ ] **MissedMessageService** - Service for missed messages
- [ ] **ChatSoundPlayer** - Service for chat sounds
- [ ] **FirebaseMessagingService** - FCM integration
- [ ] **Background Services Integration** - Ensure proper initialization in SplashBinding

### Verification:
- [ ] `flutter analyze` - No new errors
- [ ] Lock screen works
- [ ] Background notifications work
- [ ] Missed messages tracked correctly

## Phase 5: Route Refactor, DI, GetX Bindings, Clean Architecture

### Phase 5 Tasks:
- [ ] **Routes** - Ensure all routes use GetX pattern with bindings
- [ ] **AppBaseController** - Ensure proper base class
- [ ] **AppBaseView** - Ensure proper base widget
- [ ] **AppBaseService** - Ensure proper base service
- [ ] **Dependency Injection** - All services/controllers registered in bindings
- [ ] **Folder Structure** - Verify lib/ structure matches Agro-Prod:
  - binding/
  - controller/
  - model/
  - service/
  - view/
  - widgets/
  - helper/
  - helper/core/
  - helper/core/base/
- [ ] **Shared Widgets** - Extract common widgets
- [ ] **Theme System** - Consistent theming
- [ ] **Environment Config** - Dev/UAT/Prod environments

### Verification:
- [ ] `flutter analyze` - No errors (only pre-existing ones from external packages)
- [ ] All navigation works
- [ ] Firebase integration works
- [ ] App builds and runs successfully

## Key Architectural Rules (from Agro-Prod):
1. **Every screen must use**: AppBaseView, AppBaseController, Bindings, GetX routing, Dependency Injection
2. **Every Firebase operation** must be in Services
3. **Views** must contain UI only
4. **Controllers** must contain presentation logic only
5. **Services** must contain Firestore/Firebase logic only
6. **Folder structure** must match Agro-Prod exactly