# Proplilly — Core Functions & Screen Responsibilities

Central reference for shared application logic, cross-role features, and screen-level responsibilities.
Use this file when adding new features to decide where code belongs and which existing modules to reuse.

---

## Application Entry & Bootstrap

| Location | Responsibility |
|----------|----------------|
| `lib/main.dart` | App startup, theme setup, `RemoteConfigService.initialize()`, root navigator keys |
| `lib/navigation/app_navigator.dart` | Global `NavigatorState` and `ScaffoldMessengerState` keys for use outside widget trees |

**Startup flow**

```
main()
  → RemoteConfigService.initialize()
  → runApp(MyApp)
  → LoginScreen (initial route)
```

---

## Cross-Role Core Functions

These modules are shared by all user roles and should remain role-agnostic.

### Authentication (`lib/auth/`)

| Module | Core function |
|--------|---------------|
| `login_screen.dart` | Email/password login UI; routes to role home on success |
| `login_service.dart` | `POST {live_url}/api/login`; persists session to SharedPreferences |
| `register_service.dart` | Sign-up API call using `live_url` from prefs |
| `logout_service.dart` | Clears locally stored user/session data |
| `auth_preferences.dart` | SharedPreferences keys for token, role, user profile fields |
| `auth_role_router.dart` | Maps API `user.role` → home screen widget |
| `session_expiry_handler.dart` | Handles expired sessions and redirects to login |
| `signup_screen.dart` | Registration UI |
| `forgot_password_screen.dart` / `forgot_password_service.dart` | Password reset request flow |
| `reset_password_screen.dart` / `reset_password_service.dart` | Password reset completion flow |

**Role routing**

| API role | Home screen |
|----------|-------------|
| `client`, `customer` | `HomePage` (`lib/client/screens/client_home_page.dart`) |
| `field_agent` | `FieldAgentHomeScreen` (`lib/fieldagent/screens/fieldagent_home_screen.dart`) |

### Remote Config (`lib/remote_config/remote_config_service.dart`)

| Core function | Details |
|---------------|---------|
| Firebase bootstrap | Initializes Firebase + Remote Config at app start |
| Persist to prefs | Writes RC values to SharedPreferences for offline/stable reads |
| Typed getters | `liveUrl`, `androidVersion`, `iosVersion`, store URLs, force-update flags, update reasons |

**Key parameters**

| Key | Purpose |
|-----|---------|
| `live_url` | Base API URL for all authenticated requests |
| `android_version` / `ios_version` | Target store version for update checks |
| `android_forceUpdate` / `ios_forceUpdate` | `"true"` = mandatory update |
| `androidupdate_reason` / `iosupdate_reason` | Dialog message shown to users |
| `playstore_url` / `appstore_url` | Store links opened on Update tap |

### App Update (`lib/app_update/`)

| Module | Core function |
|--------|---------------|
| `app_update_service.dart` | Platform update check; prefs first, Remote Config fallback; version compare via `package_info_plus` |
| `app_update_dialog.dart` | Shared Update Available dialog (force vs optional behavior) |
| `app_update_config.dart` | Platform update config model |

**Trigger point:** called from every role Home Screen after first frame via `AppUpdateService.checkAndPrompt(context)`.

### Shared API Helpers

| Module | Core function |
|--------|---------------|
| `lib/services/api_service.dart` | Common HTTP/API utilities |
| `lib/client/services/client_live_url_api.dart` | Resolves `live_url` from SharedPreferences for client endpoints |

---

## Client Module (`lib/client/`)

Used by roles: **client**, **customer**.

### Home Screen — `client_home_page.dart`

| Responsibility | Implementation |
|----------------|------------------|
| Post-login dashboard shell | Drawer navigation, app bar, pull-to-refresh |
| Dashboard data | `HomeDashboardProvider`, properties, ads, market headlines |
| App update check | `AppUpdateService.checkAndPrompt` on init |
| Notifications badge/count | `ClientNotificationProvider.shared().refresh()` |

### Screens & Responsibilities

| Screen | File | Primary responsibility |
|--------|------|------------------------|
| Home | `client_home_page.dart` | Dashboard, quick actions, property carousel, ads, market headlines |
| My Properties | `client_my_properties_screen.dart` | List owned/registered properties |
| Property Details | `client_property_details_screen.dart` | Single property view, map, status |
| Add Property | `client_add_property_screen.dart` | Register a new property |
| Edit Property | `client_edit_property_screen.dart` | Update existing property details |
| Update Property | `client_update_property_screen.dart` | Property media/details update flow |
| Property Status | `client_property_status_screen.dart` | Monitoring status across properties |
| Visit Reports | `client_visit_reports_screen.dart` | List field-agent visit reports |
| Visit Report Details | `client_visit_report_details_screen.dart` | Single report detail view |
| Customer Billing | `client_billing_screen.dart` / `client_customer_billing_screen.dart` | Billing records and subscription info |
| Client Feedback | `client_feedback_screen.dart` | Submit/view feedback |
| Referrals | `client_referral_screen.dart` | Referral code sharing and submission |
| My Referrals | `client_my_referrals_screen.dart` | List of referred users |
| Additional Services | `client_additional_services_screen.dart` | Browse available add-on services |
| Request Additional Service | `client_request_additional_service_screen.dart` | Submit service request |
| Profile | `client_profile_screen.dart` | View profile, account actions |
| Edit Profile | `edit_client_profile_screen.dart` | Update name, contact, photo |
| Raise Support Ticket | `client_support_ticket_screen.dart` | Create support ticket |
| Your Tickets | `client_ticket_list_screen.dart` | List support tickets |
| Ticket Detail | `client_ticket_detail_screen.dart` | Single ticket conversation/status |
| Notifications | `client_notification_screen.dart` | In-app notification list |
| Ad Details | `client_ad_details_screen.dart` | Promotional ad detail + interest submission |
| Market Headline Details | `client_market_headline_details_screen.dart` | Market news item detail |

### Client Layer Pattern

```
Screen → Provider (state) → Service (API) → Model / Mapper
```

Key providers live in `lib/client/providers/`.
Key services live in `lib/client/services/`.
Shared UI widgets live in `lib/client/widgets/`.

---

## Field Agent Module (`lib/fieldagent/`)

Used by role: **field_agent**.

### Home Screen — `fieldagent_home_screen.dart`

| Responsibility | Implementation |
|----------------|------------------|
| Post-login dashboard shell | Drawer navigation, hero section, summary cards |
| Dashboard data | `FieldAgentDashboardProvider` — schedules, assigned properties, ads |
| App update check | `AppUpdateService.checkAndPrompt` on init |

### Screens & Responsibilities

| Screen | File | Primary responsibility |
|--------|------|------------------------|
| Home | `fieldagent_home_screen.dart` | Summary counts, ads slider, assigned property carousel |
| My Schedules | `fieldagent_my_schedule_screen.dart` | Today's/upcoming scheduled visits |
| My Assigned Properties | `fieldagent_my_schedules_screen.dart` / `fieldagent_assigned_properties_screen.dart` | Properties assigned to agent |
| Schedule Property Detail | `fieldagent_my_schedule_property_detail_screen.dart` | Visit task detail, actions, map |
| Property Details | `fieldagent_property_details_screen.dart` | Full property info for agent |
| Submit Report | `fieldagent_submit_report_screen.dart` | Submit visit/inspection report |
| Submitted Reports | `fieldagent_submitted_reports_screen.dart` | History of submitted reports |
| Submitted Report Details | `fieldagent_submitted_report_details_screen.dart` | View a past report |
| View Report | `fieldagent_view_report_screen.dart` | Read-only report view |
| Referrals | `fieldagent_referral_screen.dart` | Referral code sharing |
| My Referrals | `fieldagent_my_referrals_screen.dart` | List referred users |
| Profile | `fieldagent_profile_screen.dart` | View agent profile |
| Edit Profile | `edit_fieldagent_profile_screen.dart` | Update agent profile |
| Raise Support Ticket | `fieldagent_raise_ticket_screen.dart` | Create support ticket |
| Your Tickets | Reuses `client_ticket_list_screen.dart` (`clientModule: false`) | Agent ticket list |
| Ad Details | `fieldagent_ad_details_screen.dart` | Promotional ad detail |
| Schedules (alt) | `fieldagent_schedules_screen.dart` | Schedule listing view |

### Field Agent Layer Pattern

Same as client: **Screen → Provider → Service → Model**.

Providers: `lib/fieldagent/providers/`.
Services: `lib/fieldagent/` and `lib/fieldagent/services/`.

---

## Shared Client Screens (Used by Field Agent)

| Screen | Shared usage |
|--------|--------------|
| `client_ticket_list_screen.dart` | Ticket list for both client and field agent modules |
| `client_ticket_detail_screen.dart` | Ticket detail for both modules |

When extending ticket functionality, keep behavior role-aware via constructor flags (e.g. `clientModule`).

---

## UI & Theming (`lib/client/theme/`, `lib/client/widgets/`)

| Area | Purpose |
|------|---------|
| `app_colors.dart` | Brand colors used app-wide |
| `premium/` widgets | Reusable screen body, error states, cards, buttons |
| `proplilly_app_bar_logo_action.dart` | Consistent app bar branding |
| Role-specific widgets | Under `client/widgets/` and `fieldagent/widgets/` |

---

## Utilities

| Module | Core function |
|--------|---------------|
| `lib/client/utils/property_map_launcher.dart` | Opens Google Maps for property coordinates |

---

## Where to Add New Functionality

| Need | Add to |
|------|--------|
| Feature used by all roles | `lib/app_update/`, `lib/auth/`, `lib/remote_config/`, or new top-level `lib/<feature>/` |
| Client-only screen | `lib/client/screens/` + matching provider/service |
| Field-agent-only screen | `lib/fieldagent/screens/` or `lib/fieldagent/` + provider/service |
| Shared screen across roles | Prefer a shared screen with a role flag; document it here |
| New Remote Config key | `RemoteConfigKeys`, `RemoteConfigDefaults`, persist + getter in `remote_config_service.dart` |
| Home-screen-only behavior | Trigger from role home screen `initState` post-frame callback |

---

## Maintenance Notes

- Keep this file updated when adding screens, shared services, or cross-role flows.
- Prefer extending existing providers/services over duplicating API logic.
- All API calls should resolve `live_url` from SharedPreferences (via Remote Config at startup).
- App update logic must stay centralized in `lib/app_update/` — do not duplicate dialog or version-check code in role screens.
