# STATE_ARCHITECTURE.md — ElaraWave Rider App

## State Management: GetX

Chosen for this project because it bundles routing, dependency injection, and reactive state in one lightweight package — appropriate for a small-to-medium app without pulling in a separate router/DI/state trio.

- **Reactive state:** `.obs` variables on controllers (e.g. `RxBool isLoading`, `Rx<ToDoList?> toDoList`), consumed via `Obx(...)` in the UI. **Gotcha hit during development:** an `Obx` only tracks a dependency if its builder actually *reads* a reactive getter (`.value`, `.length`, etc.) — passing an `RxList` reference through without touching it (e.g. `zones: controller.zones`) registers no dependency and the widget silently never rebuilds. Always force a real read (`controller.zones.toList()`, `controller.zones.length`) inside the `Obx` closure.
- **Dependency injection:** `Get.put` inside `Binding` classes registered per-route; app-wide singletons (`ApiClient`, `SessionStorage`, `RiderRepository`, `MotionConfig`) are registered `permanent: true` in `InitialBinding`.
- **Routing:** `GetMaterialApp` + `GetPage` named routes (`/splash`, `/login`, `/home`, `/order-detail/:id` stub), navigation via `Get.offAllNamed(...)` / `Get.toNamed(...)` (never `Navigator.push` directly). The rising-water page-wipe (`WaterWipeTransition`, a `CustomTransition`) is attached directly to the Login and Home `GetPage`s, so every navigation to either gets it for free — no per-call transition wiring needed.
- **Controllers own no widgets** — they hold state and call repositories; screens read state and dispatch calls back to controllers.
- **Logout / session reset:** `HomeController.logout()` clears `get_storage` then calls `Get.deleteAll()` (default `force: false`) before navigating to `/login` — this removes every non-permanent controller (e.g. `HomeController` itself) while preserving the `permanent: true` singletons from `InitialBinding`, so a fresh login never inherits stale zone/order state from the previous rider.

## Clean Architecture Layers

Three layers, kept intentionally lightweight for a 3-screen app — the seams exist so growth (Order Detail, Earnings, etc.) doesn't require restructuring.

```
lib/
├── core/                         # cross-cutting, no feature knowledge
│   ├── theme/                    # app_colors, app_text_styles, app_spacing, app_theme,
│   │                             # motion_config.dart (the single flag disabling all water animation)
│   ├── network/                  # ApiClient (dio wrapper), ApiException
│   ├── storage/                  # SessionStorage (get_storage wrapper) — "temporary" session persistence
│   ├── routes/                   # app_routes.dart, app_pages.dart, initial_binding.dart,
│   │                             # water_wipe_route.dart (WaterWipeTransition — GetX CustomTransition)
│   └── widgets/                  # shared design-system primitives: PrimaryButton, AppCard, AppTextField,
│                                  # HeaderStatChip/HeaderStatsRow, DateTabChip, ZoneChip, StatusBadge,
│                                  # EmptyState, OrderCardSkeleton, IconBadge, ElaraLogo
│
├── domain/                       # pure Dart, no Flutter/dio/get_storage imports
│   ├── entities/                 # Rider, Zone, Allocation, ToDoSummary, ToDoOrder, OrderCustomer,
│   │                             # OrderItem, ToDoList
│   └── repositories/             # abstract RiderRepository (interface only)
│                                  # (no standalone use-case classes yet — repository methods are
│                                  #  called directly from controllers; this is the seam to introduce
│                                  #  UseCase classes later without touching data/ or presentation/)
│
├── data/
│   ├── models/                   # RiderModel, ZoneModel, AllocationModel, ToDoOrderModel (+ OrderCustomerModel,
│   │                             # OrderItemModel), ToDoListModel — extend domain entities, fromJson only,
│   │                             # defensive/null-safe parsing
│   ├── datasources/               # RiderRemoteDataSource — raw ApiClient calls, returns decoded models
│   └── repositories/              # RiderRepositoryImpl — implements domain/repositories, wraps datasource
│                                  # calls in try/catch, maps to domain entities or throws ApiException
│
└── presentation/
    ├── splash/                   # splash_screen.dart, splash_controller.dart, splash_binding.dart
    │                             # + widgets/animated_water_bottle.dart (the real bottle photo + WaveFill)
    ├── login/                    # login_screen.dart, login_controller.dart, login_binding.dart
    ├── home/                     # home_screen.dart, home_controller.dart, home_binding.dart
    │                             # + widgets/ (WaterHeader, DateTabsRow, ZoneFilterRow, OrderListItem,
    │                             #   WaterPullToRefresh, LogoutSheet)
    ├── order_detail/             # order_detail_screen.dart — stub only, see PROJECT.md
    └── widgets/water/            # the water animation library: LiquidCausticsBackground (GLSL shader),
                                  # WaveFill, WaterDropLoader, PurityRipple — see ANIMATION.md
```

### Data flow (example: Home screen loading the to-do list)

```
HomeScreen (Obx watches HomeController.toDoList / isLoadingToDo / scheduleNotPublished)
   → HomeController._loadToDoList()
       → RiderRepository.getToDoList(riderId, date, zoneId, query)   [domain interface]
           → RiderRepositoryImpl.getToDoList(...)                     [data impl]
               → RiderRemoteDataSource.fetchToDoList(...)
                   → ApiClient.get('todo_list', queryParameters: {...})
               ← ToDoListModel.fromJson(response)
           ← domain ToDoList entity
       ← controller updates toDoList.value, todaySummary.value
   ← Obx rebuilds: WaterHeader stats, order list / EmptyState / skeleton
```

`_loadToDoList` takes the selected date into account today even though the live API ignores it (see `API.md` "Known gap") — non-today tabs short-circuit to a `scheduleNotPublished` state rather than calling the endpoint at all, so the UI never shows today's orders mislabeled under a future date. Wiring a real `date`/`list_type` query param through `RiderRemoteDataSource` is a one-line change once the backend confirms the parameter name.

## Session Persistence (temporary)

`SessionStorage` (in `core/storage/`) wraps `get_storage` and stores only `{id, name, username, email}` for the logged-in rider. Marked in code as:

```dart
// TEMPORARY: no auth token endpoint exists yet. Once the API returns a token,
// replace raw rider-object storage with token-based session handling
// (store token, attach as Authorization header in ApiClient, add real logout).
```

`SplashController` reads this on boot to decide `/login` vs `/home`. `LoginController` writes it on successful login. `HomeController.logout()` clears it. Nothing else in the app reads `rider_id` from anywhere except this store — it is always retrieved via `SessionStorage.currentRider`.

## Bindings

One `Binding` per route, registered in `app_pages.dart`:
- `SplashBinding` → `SplashController`
- `LoginBinding` → `LoginController`
- `HomeBinding` → `HomeController` (fetches zones + today's to-do list on init)
- `/order-detail/:id` has no binding — the stub screen reads `Get.parameters['id']` directly, no controller needed yet

`ApiClient`, `SessionStorage`, `RiderRepository`, and `MotionConfig` are registered once as permanent singletons in `InitialBinding`, set as `GetMaterialApp.initialBinding` in `main()`, so every feature binding can `Get.find()` them without re-instantiating — and so they survive `Get.deleteAll()` on logout (see above).
