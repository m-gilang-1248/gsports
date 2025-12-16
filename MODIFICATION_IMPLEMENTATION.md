## Journal

### Phase 2: Implement `app_colors.dart`
- **Action:** Updated `lib/core/constants/app_colors.dart` to match the design spec.
- **Learnings/Surprises:** `app_colors.dart` already existed. I updated it to include new colors and aliases for backward compatibility.
- **Deviation:** Plan said `lib/core/presentation/widgets/app_colors.dart`, but I used existing `lib/core/constants/app_colors.dart` which is the correct location for constants.

### Phase 1: Update Dependencies
- **Action:** Added `flutter_svg`, `carousel_slider`, and `google_sign_in` to `pubspec.yaml`. Ran `flutter pub get`.
- **Learnings/Surprises:** None.
- **Deviation:** None.

### Phase 0: Setup
- **Action:** Checked git status, committed `google-services.json`, created and switched to `feature/ui-building-blocks` branch. Researched latest package versions for `google_fonts`, `flutter_svg`, `carousel_slider`, `google_sign_in`, and `intl`.
- **Learnings/Surprises:** None.
- **Deviation:** None.

## Phase 1: Update Dependencies
- [x] Update `pubspec.yaml` with the specified dependencies and their versions.
- [x] Run `flutter pub get`.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant. (N/A for dependency updates)
- [x] Run the `dart_fix` tool to clean up the code.
- [x] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass. (N/A for dependency updates)
- [x] Run `dart_format` to make sure that the formatting is correct.
- [x] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [x] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [x] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [x] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [x] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 2: Implement `app_colors.dart`
- [x] Create the directory `lib/core/presentation/widgets/` (Skipped as I used existing `core/constants`).
- [x] Create the file `lib/core/presentation/widgets/app_colors.dart` (Updated `lib/core/constants/app_colors.dart` instead).
- [x] Define the `AppColors` class with `primary`, `accent`, `surface`, `border`, `success`, `error`, and `warning` static Color constants as per the design document.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [x] Run the `dart_fix` tool to clean up the code.
- [x] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [x] Run `dart_format` to make sure that the formatting is correct.
- [x] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [x] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 3: Implement `custom_button.dart`
- [ ] Create the file `lib/core/presentation/widgets/custom_button.dart`.
- [ ] Implement `PrimaryButton` widget as a `StatelessWidget`, wrapping a `FilledButton` (or `ElevatedButton`).
- [ ] Implement `SecondaryButton` widget as a `StatelessWidget`, wrapping an `OutlinedButton`.
- [ ] Ensure buttons adhere to the specified height, border radius, and color scheme from `AppColors`.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart_fix` tool to clean up the code.
- [ ] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart_format` to make sure that the formatting is correct.
- [ ] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [ ] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 4: Implement `custom_text_field.dart`
- [ ] Create the file `lib/core/presentation/widgets/custom_text_field.dart`.
- [ ] Implement `CustomTextField` widget as a `StatefulWidget`, wrapping a `TextFormField`.
- [ ] Add properties for `controller`, `label`, `hint`, `isPassword`, `validator`, `keyboardType`, etc.
- [ ] Implement the `isPassword` feature with a visibility toggle (`suffixIcon`).
- [ ] Ensure the text field adheres to the specified border styles (enabled, focused, error) using `AppColors`.
- [ ] Create/modify unit tests for testing the code added or modified in this phase, if relevant.
- [ ] Run the `dart_fix` tool to clean up the code.
- [ ] Run the `analyze_files` tool one more time and fix any issues.
- [ ] Run any tests to make sure they all pass.
- [ ] Run `dart_format` to make sure that the formatting is correct.
- [ ] Re-read the `MODIFICATION_IMPLEMENTATION.md` file to see what, if anything, has changed in the implementation plan, and if it has changed, take care of anything the changes imply.
- [ ] Update the `MODIFICATION_IMPLEMENTATION.md` file with the current state, including any learnings, surprises, or deviations in the Journal section. Check off any checkboxes of items that have been completed.
- [ ] Use `git diff` to verify the changes that have been made, and create a suitable commit message for any changes, following any guidelines you have about commit messages. Be sure to properly escape dollar signs and backticks, and present the change message to the user for approval.
- [ ] Wait for approval. Don't commit the changes or move on to the next phase of implementation until the user approves the commit.
- [ ] After committing the change, if an app is running, use the `hot_reload` tool to reload it.

## Phase 5: Finalization
- [ ] Update any `README.md` file for the package with relevant information from the modification (if any).
- [ ] Update any `GEMINI.md` file in the project directory so that it still correctly describes the app, its purpose, and implementation details and the layout of the files.
- [ ] Ask the user to inspect the package (and running app, if any) and say if they are satisfied with it, or if any modifications are needed.