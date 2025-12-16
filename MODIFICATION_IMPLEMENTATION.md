# Implementation Plan: Update Technical Specification for Guest & Owner Modes

## Journal

### Phase 2: Finalization
- **Action:** Updated `GEMINI.md` and `README.md` to reflect the Technical Specification update.
- **Learnings/Surprises:** None.
- **Deviation:** None.

### Phase 1: Update `softwaredesign/TECH_SPEC.md`
- **Action:** Rewrote `softwaredesign/TECH_SPEC.md` with updated dependencies, project structure, role-based access, routing, payment flow, and image handling.
- **Learnings/Surprises:** None.
- **Deviation:** None.

## Phase 1: Update `softwaredesign/TECH_SPEC.md`
- [x] Read the content of `softwaredesign/TECH_SPEC.md`.
- [x] Modify the "Tech Stack & Dependencies" section:
    - Add `google_sign_in`, `carousel_slider`, `flutter_svg`, `image_picker`, `permission_handler` to the appropriate categories.
    - Ensure `flutter_bloc`, `go_router`, `get_it`, `firebase_*`, `webview_flutter` are retained.
- [x] Modify the "Project Folder Structure" section:
    - Detail `features/partner` to include `venue_management` (CRUD) and `dashboard`.
- [x] Modify the "Key Implementation Details" section:
    - Update "State Management Strategy" to include `RoleBasedAccess` (mentioning `UserEntity.role`).
    - Revise "Routing & Auth Guard":
        - Define Public, Protected User, and Protected Owner routes.
        - Clarify redirect logic based on `authStatus` AND `role`.
    - Update "Booking & Payment Flow" to 'Client-Side Midtrans Implementation' (HTTP Call for token, then WebView).
    - Add a new sub-section "Image Handling" detailing the use of `image_picker` for Owner uploads to Firebase Storage and URL saving to Firestore.
- [x] Overwrite the `softwaredesign/TECH_SPEC.md` file with the updated content.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant. (N/A for documentation changes)
- [ ] Run the `dart_fix` tool to clean up the code. (N/A for documentation changes)
- [ ] Run the `analyze_files` tool one more time and fix any issues. (N/A for documentation changes)
- [ ] Run any tests to make sure they all pass. (N/A for documentation changes)
- [ ] Run `dart_format` to make sure that the formatting is correct. (N/A for documentation changes)
- [x] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [x] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [x] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [x] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [x] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 2: Finalization
- [x] Update any `README.md` file for the package with relevant information from the modification (if any).
- [x] Update any `GEMINI.md` file in the project directory so that it still correctly describes the app, its purpose, and implementation details and the layout of the files.
- [x] Ask the user to inspect the package (and running app, if any) and say if they are satisfied with it, or if any modifications are needed.
