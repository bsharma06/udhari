I reviewed the app’s full Flutter surface: dashboard, contact picker, entry/edit flow, detail history, settings, data layer, platform setup, and tests. Udhari has a solid local-first foundation and a clean Material 3 visual direction, but it needs a few correctness fixes before feature expansion.

## Fix before promoting the app

| Priority | Finding | Why it matters |
|---|---|---|
| P0 | Amount validation accepts zero, negatives, and malformed values that parse to `0.0`. | Invalid ledger records undermine trust. Require an amount greater than zero, use currency input formatting, and prevent duplicate submissions. [transaction_form_screen.dart](/C:/Users/homep/dev/udhari/lib/screens/transaction_form_screen.dart:76) |
| P0 | Delete happens immediately, without confirmation or undo. | A single accidental tap permanently removes financial history. Add confirmation plus an “Undo” snackbar. |
| P1 | The shipped test is stale: it creates `AppEntry()` without its required `themeProvider`; it is still the starter counter test. | There is effectively no regression protection for balances, CRUD, or exports. [widget_test.dart](/C:/Users/homep/dev/udhari/test/widget_test.dart:1) |
| P1 | The detail overflow menu is an empty action; import/backup is implemented at the data layer but not exposed in Settings. | These feel unfinished and make recovery difficult. [detail_screen.dart](/C:/Users/homep/dev/udhari/lib/screens/detail_screen.dart:30), [db_helper.dart](/C:/Users/homep/dev/udhari/lib/services/db_helper.dart:77) |

## Product improvements most likely to improve adoption

1. Make the core ledger model clearer.

   - Separate an “advance/debt” entry from a “settlement/payment received” entry.
   - Label every balance in plain language: “You will receive ₹…”, “You need to pay ₹…”, or “Settled.”
   - Show a full per-person breakdown: lent, repaid, borrowed, paid back, outstanding.
   - Support a settled/archive state so zero-balance people do not clutter the home screen.
   - Let users merge duplicate people and preserve a contact ID/phone number, not only a display-name string.

2. Reduce friction when recording an entry.

   - Autofocus the amount field and offer quick amount chips based on recent values.
   - Suggest recently used people as the user types.
   - Add “Today” by default with a compact “Change date” control.
   - Offer a one-tap “Settle balance” action from each person’s detail screen.
   - Add optional field:, UPI reference, and note templates.

3. Give users a reason to return.

   - Due dates and reminders: “Remind Priya on Aug 5.”
   - A reminder timeline and notifications, with channels such as WhatsApp/SMS share templates rather than automatic sending by default.
   - “Overdue” and “due this week” sections.
   - Home-screen widgets for total owed, total due, and quick-add.
   - Lightweight monthly insights: money lent/borrowed, repayments, most overdue accounts, and trends.

4. Build confidence in user data.

   - Add CSV import, JSON encrypted backup/restore, preview-before-import, duplicate detection, and an import result summary.
   - Provide optional cloud backup/sync only as an explicit opt-in; retain full offline mode. [This feature is parked for later enhancements]
   - Add app lock with device PIN/biometrics and encrypted local storage for a finance app.
   - Create a clear “Export all data / delete all data” privacy section.
   - Include a visible backup status and a gentle backup reminder after meaningful data has accumulated.

5. Improve retention and distribution.

   - First-run onboarding with a 30-second example: “Amit owes you ₹500” and “You owe Neha ₹200.”
   - Let users choose a default currency and locale. The current ₹ symbol and fixed two-decimal rendering should become locale-aware currency formatting.

## Modern UI recommendations

The present dark UI is clean, but its information hierarchy can become more useful.

- Replace “Recent Transactions” on Home with “People & balances”—the screen currently lists people, not transactions.
- Use a single hero summary: “Net position,” with two secondary chips for “To collect” and “To pay.” Add an “Overdue” badge when relevant.
- Add filter chips directly below the summary: `All`, `To collect`, `To pay`, `Settled`, `Overdue`; add sorting by amount, recent activity, and due date.
- Use a proper Material 3 `NavigationBar` instead of an always-home `BottomNavigationBar`; recommended sections are Home, Activity, People, and Settings. Keep the FAB for quick entry.
- On the person detail page, make the primary action context-aware: `Record repayment` when they owe the user, or `Record payment` when the user owes them.
- Group history by date, show running balance after each entry, and allow swipe actions for edit/delete with an undo path.
- Replace initial-only avatars with optional contact photos or a consistent generated color/avatar system.
- Make empty states actionable: “Add your first entry” rather than only “No transactions found.”
- Avoid relying only on green/red. Pair color with clear labels/icons, supporting color-blind users.
- Test at large text sizes, improve screen-reader labels for balance polarity and icons, and ensure all controls retain comfortable touch targets.
- Offer system/light/dark theme selection rather than a binary dark toggle; the implementation currently defaults to system but only exposes an on/off dark mode control. [theme_provider.dart](/C:/Users/homep/dev/udhari/lib/providers/theme_provider.dart:1)

## Suggested delivery order

1. Financial correctness, amount validation, delete undo/confirmation, permissions, and real automated tests.
2. Better wording, people management, filters/sorting, settlement flow, currency/locale support.
3. Backup/import, reminders, reports, biometric lock.
4. Widgets, optional sync, sharing integrations, multilingual rollout.

One additional polish point: replace the generic Flutter logo (kept logo.png in assets/images folder) in About and the lowercase Android app label with the real Udhari brand identity. The app already looks thoughtfully designed; these changes would make it feel reliable enough for users to trust it with real money records.