class FirebaseConstants {
  static const String usersCollection = 'users';

  // User Document Fields
  static const String userUidField = 'uid';
  static const String userEmailField = 'email';
  static const String userDisplayNameField = 'displayName';
  static const String userPhotoUrlField = 'photoUrl';
  static const String userRoleField = 'role';
  static const String userTierField = 'tier';
  static const String userTierExpiryDateField = 'tierExpiryDate';
  static const String userBankNameField = 'bankName';
  static const String userBankAccountNumberField = 'bankAccountNumber';
  static const String userBankAccountHolderField = 'bankAccountHolder';
  static const String userCreatedAtField = 'createdAt';
  static const String userFcmTokenField = 'fcmToken';

  // Mitra Profile Fields (sub-fields of user document)
  static const String mitraProfileField = 'mitraProfile';
  static const String mitraBankNameField = 'bankName';
  static const String mitraBankAccountNumberField = 'bankAccountNumber';
  static const String mitraTotalRevenueField = 'totalRevenue';

  // Venues Collection and Document Fields
  static const String venuesCollection = 'venues';
  static const String venueIdField = 'id';
  static const String venueOwnerIdField = 'ownerId';
  static const String venueNameField = 'name';
  static const String venueDescriptionField = 'description';
  static const String venueAddressField = 'address';
  static const String venueCityField = 'city';
  static const String venueLocationField = 'location'; // GeoPoint
  static const String venueFacilitiesField = 'facilities'; // Array
  static const String venuePhotosField = 'photos'; // Array
  static const String venueRatingField = 'rating';
  static const String venueMinPriceField = 'minPrice';
  static const String venueIsVerifiedField = 'isVerified';
  static const String venueCreatedAtField = 'createdAt';

  // Courts Subcollection and Document Fields
  static const String courtsSubcollection = 'courts';
  static const String courtIdField = 'id';
  static const String courtNameField = 'name';
  static const String courtSportTypeField = 'sportType';
  static const String courtSurfaceTypeField = 'surfaceType';
  static const String courtIsIndoorField = 'isIndoor';
  static const String courtHourlyPriceField = 'hourlyPrice';
  static const String courtIsActiveField = 'isActive';

  // Bookings Collection and Document Fields
  static const String bookingsCollection = 'bookings';
  static const String bookingIdField = 'id';
  static const String bookingUserIdField = 'userId';
  static const String bookingVenueIdField = 'venueId';
  static const String bookingCourtIdField = 'courtId';
  static const String bookingSportTypeField = 'sportType';
  static const String bookingDateField = 'date';
  static const String bookingStartTimeField = 'startTime';
  static const String bookingEndTimeField = 'endTime';
  static const String bookingDurationHoursField = 'durationHours';
  static const String bookingStatusField = 'status';
  static const String bookingPaymentStatusField = 'paymentStatus';
  static const String bookingTotalPriceField = 'totalPrice';
  static const String bookingCourtPriceField = 'courtPrice';
  static const String bookingServiceFeeField = 'serviceFee';
  static const String bookingAppFeeField = 'appFee';
  static const String bookingNetRevenueField = 'netRevenue';
  static const String bookingMidtransOrderIdField = 'midtransOrderId';
  static const String bookingMidtransPaymentUrlField = 'midtransPaymentUrl';
  static const String bookingIsSplitBillField = 'isSplitBill';
  static const String bookingSplitCodeField = 'splitCode';
  static const String bookingParticipantsField = 'participants';
  static const String bookingCreatedAtField = 'createdAt';

  // Transactions Collection and Document Fields
  static const String transactionsCollection = 'transactions';
  static const String transactionIdField = 'id';
  static const String transactionUserIdField = 'userId';
  static const String transactionTypeField = 'type';
  static const String transactionAmountField = 'amount';
  static const String transactionStatusField = 'status';
  static const String transactionReferenceIdField = 'referenceId';
  static const String transactionDescriptionField = 'description';
  static const String transactionCreatedAtField = 'createdAt';

  // Matches Collection and Document Fields
  static const String matchesCollection = 'matches';
  static const String matchIdField = 'id';
  static const String matchBookingIdField = 'bookingId';
  static const String matchSportTypeField = 'sportType';
  static const String matchPlayedAtField = 'playedAt';
  static const String matchPlayersField = 'players';
  static const String matchScoreDetailsField = 'scoreDetails';
}
