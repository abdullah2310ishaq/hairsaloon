## Provider Flow + Local Storage / Hive Gap Report

This document captures the *current* app flow based on the codebase, then identifies where persistence is already implemented vs missing, and where Hive-based storage would be needed for a “real” (restart-safe) salon ERP.

---

## 1. Real App Boot + Navigation Flow (from `lib/src/app.dart`)

### 1.1 App bootstrap sequence
1. `BusinessCombApp` starts.
2. `_bootstrapFuture = _bootstrap()` runs in `initState()`.
3. `build()` shows a `FutureBuilder<_AppBootstrap>`:
   - While waiting: shows `_loadingApp()`.
   - On error: shows `_errorApp(...)`.
   - If bootstrap data is null: shows `_loadingApp(message: 'Loading local storage...')`.
4. `_bootstrap()` does:
   - `final prefs = await SharedPreferences.getInstance();`
   - `await LocalBillingStore.init(prefs);`
   - Creates `SharedPrefsBusinessProfileRepository(prefs: prefs)`.
   - Creates `BusinessProfileNotifier` with usecases wired to that repository.
   - Calls `await notifier.load();`
   - Returns `_AppBootstrap(notifier: notifier, hasSession: notifier.profile != null)`.

### 1.2 Session-based first route
In `MaterialApp`:
- `initialRoute` is:
  - `AppRoutes.homeShell` if `bootstrap.hasSession == true`
  - otherwise `AppRoutes.businessRegistration`

So: “session” is currently equivalent to “Business profile exists in SharedPreferences”.

### 1.3 Routes
Routes are defined in `lib/src/features/router/app_routes.dart`. Key ones:
- `AppRoutes.businessRegistration` -> `BusinessRegistrationScreen`
- `AppRoutes.homeShell` -> `DashboardShell`
- `AppRoutes.billing` / `AppRoutes.savedBills` / `AppRoutes.billDetails` -> billing screens
- `AppRoutes.expenses` -> expenses screens
- `AppRoutes.employees` / `AppRoutes.employeeAgreement` -> employee screens
- `AppRoutes.financeOverview` / `AppRoutes.employeeEarnings` -> finance screens

---

## 2. “Provider” / State Management Reality in This Codebase

### 2.1 No `provider` package is used
There is no usage of `package:provider` in `lib/` (the project uses a custom provider-like approach).

### 2.2 What’s actually used: `BusinessProfileScope` (InheritedNotifier)
`BusinessProfileScope` extends `InheritedNotifier<BusinessProfileNotifier>` and is mounted once in `BusinessCombApp`:
- `BusinessProfileScope(notifier: bootstrap.notifier, child: MaterialApp(...))`

Screens use it like:
- `BusinessProfileScope.of(context).profile`
- `BusinessProfileScope.of(context).save(profile)`
- `BusinessProfileScope.of(context).clear()`

So the “Provider-like” pattern is implemented via Flutter’s `InheritedNotifier`, not the `provider` package.

---

## 3. Local Storage Already Integrated (and where)

### 3.1 SharedPreferences (YES, already integrated)
The app uses `shared_preferences` in exactly these places:

#### 3.1.1 Business profile persistence
File: `lib/src/features/business_profile/data/repositories/shared_prefs_business_profile_repository.dart`
- Storage key: `business_profile_v1`
- Repository persists:
  - `getProfile()` reads `prefs.getString(storageKey)`
  - `saveProfile()` writes the encoded model
  - `clearProfile()` removes it

Bootstrap:
- `BusinessCombApp._bootstrap()` loads this via `BusinessProfileNotifier.load()`.

#### 3.1.2 Billing (saved bills) persistence
File: `lib/src/features/billing/data/local_billing_store.dart`
- Storage keys:
  - `billing.saved_bills.v1`
  - `billing.customer_phones.v1`

Bootstrap:
- `BusinessCombApp._bootstrap()` calls `await LocalBillingStore.init(prefs);`
  - `init()` reads JSON for saved bills
  - reads `StringList` for known customer phones
  - performs a migration-style step to seed phones from loaded bills

Persistence behavior:
- `LocalBillingStore.addBill()` persists:
  - `_persist()` writes the full bills list back into `billing.saved_bills.v1`
  - `_persistCustomerPhones()` writes the phone list back into `billing.customer_phones.v1`

### 3.2 Hive (NO)
Search-wise (in this codebase):
- There are no Hive / hive_flutter / Box usage points.

So right now: Hive is not integrated at all.

---

## 4. Local Storage Missing / Currently In-Memory (restart resets data)

These “Local*Store” classes are used heavily in UI, but they do not persist to disk:

### 4.1 Service categories (NOT persisted)
File: `lib/src/features/services/data/local_category_store.dart`
- Categories/subcategories are static in-memory data.
- Screen actions modify the static maps/lists (add/delete/rename).
- No `SharedPreferences` or Hive persistence exists here.

### 4.2 Services list (NOT persisted)
File: `lib/src/features/services/data/local_services_store.dart`
- Services are seeded in a static list.
- Actions add/update/delete services in memory.
- No persistence exists.

### 4.3 Employees (NOT persisted)
File: `lib/src/features/employees/data/local_employees_store.dart`
- Static in-memory list of employees.
- UI mutates it (add/update/delete).
- No persistence exists.

### 4.4 Expenses (NOT persisted)
File: `lib/src/features/expenses/data/local_expenses_store.dart`
- Static in-memory list of expense items.
- UI mutates it.
- No persistence exists.

### 4.5 Tax rate (NOT persisted)
File: `lib/src/features/settings/data/local_tax_rate_store.dart`
- Uses a `ValueNotifier<double>` in memory.
- `setTaxRate(...)` updates notifier only.
- No persistence exists.

### 4.6 Appointments
`AppointmentsScreen` is currently a placeholder. There is no appointments store/persistence in the current code.

---

## 5. Where Hive-Based Storage Would Be Needed (to make the app “real” across restarts)

If the goal is “real flow” where user changes survive app relaunch, Hive (or another local DB) should back these domains:

### 5.1 Must persist
- Business profile (already persisted with SharedPreferences)
- Saved bills + customer phone autocomplete data (already persisted with SharedPreferences)
- Employees (add/update/delete + active/inactive)
- Expenses (add/update/delete + categories/types)
- Services (add/update/delete services and prices)
- Service categories + subcategories (add/delete/rename)
- Tax rate setting (so billing calculations don’t revert)

### 5.2 Would likely be next
- Appointments data (once implemented)
- Finance derived views could remain derived-from-storage (not separately stored), but settlement/status might need persistence depending on requirements.

### 5.3 Recommended Hive mapping (conceptual)
Hive would typically use:
- `Box<BusinessProfile>` (or store by key if you expect only one profile)
- `Box<Bill>` for saved bills
- `Box<String>` or `Box<CustomerPhone>` for known customer phones (or derive from bills)
- `Box<EmployeeItem>` for employees
- `Box<ExpenseItem>` for expenses
- `Box<ServiceItem>` for services
- `Box<Category>` / `Box<Subcategory>` (or a single box holding the category tree)
- `Box<double>` or a `Box<Settings>` for tax rate

The exact modeling depends on whether you store:
- One business profile only (simpler)
- Multiple businesses (more complex)

---

## 6. Is the Current Storage Integration “Fine”?

### 6.1 What’s good
- Bootstrap ordering is correct for the parts that persist:
  - `SharedPreferences` is initialized
  - `LocalBillingStore.init(prefs)` runs before UI can read `LocalBillingStore.bills`
  - `BusinessProfileNotifier.load()` runs before choosing `initialRoute`
- Business profile session gating works cleanly.
- Billing saved bills + customer phone autocomplete are persisted and reloaded at startup.

### 6.2 What’s not fine (or will limit “real” behavior)
- Most business-critical modules are in-memory only:
  - employees, expenses, services, categories, tax rate reset on restart
- `LocalBillingStore` stores the entire bills list as a single JSON string in `SharedPreferences`.
  - This works for small MVP data
  - But it will hit `SharedPreferences` size limitations as bills grow
  - It also makes partial updates harder (every `addBill` rewrites everything)
- The local stores are `static` singletons:
  - this is convenient but couples UI directly to global mutable state
  - it makes testing harder and makes dependency injection / rehydration patterns more complex
- No reactivity layer exists for most stores:
  - screens use `setState` around in-memory mutations
  - this won’t automatically refresh other parts of the UI tree when data changes (you currently rely on screen-level rebuilds).

---

## 7. “Make It Real with Provider” (Suggested Architecture, consistent with your code style)

You have two options depending on whether you want to keep the current custom scope approach.

### Option A: Keep `InheritedNotifier` (no new dependency)
- Keep `BusinessProfileScope` style for profile
- Introduce additional scopes/notifiers for:
  - Billing store (bills)
  - Employees store
  - Expenses store
  - Services/categories store
  - Settings store (tax rate)
- Each notifier should:
  - own the persisted repository (Hive-backed)
  - expose immutable state to UI
  - call `notifyListeners()` after persistence changes

### Option B: Migrate to `provider` package (matches your wording)
- Add:
  - `MultiProvider`
  - `ChangeNotifierProvider` for each domain notifier
  - optionally `RepositoryProvider` for repositories
- Keep `MaterialApp` inside the provider tree (like you already do with `BusinessProfileScope`).

Either way, the key improvement is the same:
- UI reads from notifier state
- notifier reads/writes from a repository backed by Hive
- no more reliance on `static` in-memory global lists for persisted data.

---

## 8. Storage Inventory Checklist (Quick Reference)

Already persisted (SharedPreferences):
- `business_profile_v1`
- `billing.saved_bills.v1`
- `billing.customer_phones.v1`

Not persisted (in-memory only today):
- `LocalCategoryStore`
- `LocalServicesStore`
- `LocalEmployeesStore`
- `LocalExpensesStore`
- `LocalTaxRateStore`

Hive:
- Not used yet

---

## 9. Next Decision You Need to Make

Before implementing Hive, decide:
- Are you okay with “single business profile only” locally?
- Do you need audit/history (versions) for bills/expenses?
- How big can your stored lists realistically grow?

These decisions affect:
- Hive box design (one big box vs multiple domain boxes)
- whether to store snapshots vs incremental writes

