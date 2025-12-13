# Modification Design: History Sorting & Dialog Provider Scope Fixes

## Overview
This modification addresses two reported bugs: incorrect history sorting in the "My Bookings" list and a `ProviderNotFoundException` when attempting to update a participant's status via a dialog in the `BookingDetailPage`.

## Problem Analysis

### 1. History Sorting
- **Problem:** User reports "Urutan history terbalik (Lama di atas, Baru di bawah)", meaning old bookings appear at the top and new bookings at the bottom.
- **Current Code (`booking_remote_data_source.dart`):** The `getMyBookings` query uses `.orderBy('startTime', descending: true)`. This should, in principle, sort bookings with the most recent `startTime` at the top (newest first).
- **Ambiguity:** The phrase "terbalik" can be interpreted in different ways depending on the user's expectation. If "newest first" (most recent at top) is the desired behavior, the current code's `descending: true` is correct. If the user is seeing "oldest first" (oldest at top), then `descending: true` should be changed to `descending: false`.
- **Conclusion for now:** Since `descending: true` typically means newest-first (most common for history lists), and the instruction was "Pastikan query `.orderBy('startTime', descending: true)`", no change will be made to the Firestore query for sorting at this stage, as it matches the direct instruction and common UX for history. If the issue persists, further clarification on the *desired* sort order (newest first vs. oldest first) from the user will be required. It's possible the `startTime` values in Firestore are not consistently reflecting the creation order, or the UI has an implicit reversal (though `BookingHistoryPage` review showed none).

### 2. Dialog Provider Scope
- **Problem:** `ProviderNotFoundException` occurs when opening the "Update Status Pembayaran" dialog in `BookingDetailPage`.
- **Cause:** Dialogs and `showModalBottomSheet` are built in a new `Overlay` context, which does not automatically inherit the `BlocProvider` from the widget tree that triggered it. Therefore, `context.read<BookingDetailBloc>()` inside the dialog's `builder` cannot find the `BookingDetailBloc` instance.

## Proposed Solution

### 1. History Sorting Fix
- **No Change in Query:** Based on current understanding and instruction, the `.orderBy('startTime', descending: true)` in `booking_remote_data_source.dart` will remain as is, assuming "newest first" is the desired behavior. The focus will be on the dialog fix first, and re-evaluation of sorting if the problem persists.

### 2. Dialog Provider Scope Fix (`booking_detail_page.dart`)
- **Strategy:** Capture the `BookingDetailBloc` instance from the current `BuildContext` *before* showing the dialog. Then, explicitly provide this instance to the dialog's widget tree using `BlocProvider.value`.
- **Steps:**
    1.  In the `_showUpdateStatusDialog` method, before calling `showDialog`, get the `BookingDetailBloc` instance: `final bloc = context.read<BookingDetailBloc>();`.
    2.  In the `builder` of `showDialog`, wrap the `AlertDialog` (or its content) with `BlocProvider.value`:
        ```dart
        showDialog(
          context: context,
          builder: (innerContext) {
            return BlocProvider.value(
              value: bloc, // Provide the captured bloc
              child: AlertDialog(
                // ... dialog content
              ),
            );
          },
        );
        ```
    3.  Alternatively, inside the dialog, instead of `context.read<BookingDetailBloc>().add(...)`, use `bloc.add(...)` directly if `bloc` is captured outside and accessible. The latter is simpler and avoids the need for `BlocProvider.value` if only adding events. I will use the latter approach as it's more direct for this use case.

## Detailed Design

### Flowchart (Dialog Context Fix)
```mermaid
graph TD
    A[BookingDetailPage Widget Tree] --> B{Call _showUpdateStatusDialog}
    B --> C[Capture: final bloc = context.read<BookingDetailBloc>()]
    C --> D[Call showDialog(builder: (innerContext) {...})]
    D --> E{Dialog's Builder Context}
    E --> F[Inside Dialog: bloc.add(UpdateParticipantPaymentStatus(...))]
    F --> G[Bloc receives event]
```

## Summary
The dialog context issue will be resolved by correctly scoping the `BookingDetailBloc` instance within the dialog. The sorting order will be re-evaluated if needed after confirming the current behavior is indeed "newest first" (descending).
