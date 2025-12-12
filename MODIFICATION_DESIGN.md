# MODIFICATION DESIGN: Split Bill Feature (Phase 1)

## Overview
This design document outlines the implementation of the "Split Bill" feature for the Gsports application. Phase 1 focuses on the Domain and Data layer updates to support booking participants and split codes, laying the foundation for the UI/UX implementation.

## Goal
To enable users to split the cost of a booking by inviting others via a unique code.
Specifically for Phase 1:
- Refactor the `Booking` entity to properly type participants using a new `PaymentParticipant` entity.
- Implement the logic for generating a unique 6-character alphanumeric split code.
- Implement the logic for joining a booking using the split code.

## Analysis
The current `Booking` entity uses `List<Map<String, dynamic>>` for participants. This is loose and prone to errors. We need a strongly typed `PaymentParticipant` entity.
The `splitCode` logic needs to be robust (unique, easy to share). For MVP, client-side generation is acceptable as per requirements.

## Detailed Design

### 1. New Entity: `PaymentParticipant`
Location: `lib/features/booking/domain/entities/payment_participant.dart`

Fields:
- `uid` (String?): Nullable for guests (if supported later), but for now linked to registered users.
- `name` (String): Display name.
- `status` (String): 'host' | 'joined'.
- `paymentStatusToHost` (String): 'pending' | 'paid'.
- `profileUrl` (String?): Optional, for UI display.

### 2. Update Entity: `Booking`
Location: `lib/features/booking/domain/entities/booking.dart`

Changes:
- Change `participants` type from `List<Map<String, dynamic>>` to `List<PaymentParticipant>`.

### 3. New Model: `PaymentParticipantModel`
Location: `lib/features/booking/data/models/payment_participant_model.dart`

- Extends `PaymentParticipant`.
- Implements `fromJson` and `toJson`.

### 4. Update Model: `BookingModel`
Location: `lib/features/booking/data/models/booking_model.dart`

Changes:
- Update `participants` serialization/deserialization to use `PaymentParticipantModel`.

### 5. Data Source Updates
Location: `lib/features/booking/data/datasources/booking_remote_data_source.dart`

- **generateSplitCode**:
  - Function to generate 6-char alphanumeric code (A-Z, 0-9).
  - Update the booking document in Firestore with this code.
- **joinBooking**:
  - Accept `splitCode` and `User`.
  - Query Firestore for booking with `splitCode`.
  - Add user to `participants` array (using `FieldValue.arrayUnion`).

### 6. Use Cases
- `GenerateSplitCode` (lib/features/booking/domain/usecases/generate_split_code.dart)
- `JoinBooking` (lib/features/booking/domain/usecases/join_booking.dart)

## Logic: Split Code Generation (Client-Side MVP)
```dart
String _generateRandomCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}
```

## Summary
This phase strictly refactors the data structure to be robust and ready for the UI implementation in the next phase.
