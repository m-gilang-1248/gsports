# Modification Design: Update Technical Specification for Guest & Owner Modes

## Overview
This modification involves updating the `softwaredesign/TECH_SPEC.md` file to accommodate new requirements: Guest Mode, Owner Side (CRUD), and a modern UI. This ensures the technical documentation remains the source of truth for upcoming development sprints.

## Goal
To revise the Technical Specification (SDD) to reflect:
1.  Updated Dependencies (Google Auth, Images, etc.).
2.  Refined Project Structure (Partner/Owner features).
3.  Updated Key Implementation Details (Role-based State Management, Routing Guards, Payment Flow, Image Handling).

## Analysis of Changes

### 1. Update Dependencies
- **Add:**
    - `google_sign_in`: For Google Authentication.
    - `carousel_slider`: For image galleries in UI.
    - `flutter_svg`: For vector assets.
    - `image_picker`: For selecting images (Owner CRUD).
    - `permission_handler`: For managing permissions (Camera/Storage).
- **Maintain:** `flutter_bloc`, `go_router`, `get_it`, `firebase_*`, `webview_flutter`.

### 2. Update Project Structure
- Explicitly detail `features/partner` to include `venue_management` (CRUD) and `dashboard`.
- The overall Clean Architecture structure remains unchanged.

### 3. Update Key Implementation Details
- **A. State Management:** Introduce `RoleBasedAccess` concept. The UI will adapt based on the `UserEntity.role` (e.g., `user` vs `owner`).
- **B. Routing & Guard:**
    - **Public:** `/`, `/login`, `/register`, `/home`, `/venue-detail` (Guest Mode enabled).
    - **Protected (User):** `/booking`, `/payment`, `/profile`.
    - **Protected (Owner):** `/owner-dashboard`, `/manage-venue`.
    - **Logic:** `GoRouter` redirect must check `authStatus` AND `role`.
- **C. Payment Flow:** Clarify "Client-Side Midtrans Implementation". The app will likely call a backend API (or Cloud Function acting as API) to get the Snap Token, then load the WebView.
- **D. Image Handling (New):** Describe the flow for Owners:
    1.  Pick image (`image_picker`).
    2.  Upload to Firebase Storage.
    3.  Get Download URL.
    4.  Save URL to Firestore `venues` collection.

## Deliverables
- A rewritten `softwaredesign/TECH_SPEC.md`.

## References
- Existing `softwaredesign/TECH_SPEC.md`
- Midtrans Documentation (Client-Side integration patterns)
- Firebase Storage Documentation
