# Gsports

Gsports is a SaaS (Software as a Service) mobile application for real-time sports venue booking, connecting venue owners (Mitra) and users.

## Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Architecture:** Clean Architecture
- **State Management:** Flutter BLoC
- **Navigation:** GoRouter

## Project Status
**Phase 1 & 2: Authentication & UI Foundation - Completed**
- Firebase Auth (Google Sign-In) and Guest Mode.
- Clean Architecture with BLoC and Repository pattern.
- Modern Blue Design System (Material 3).

**Phase 3: Booking & Payment - Completed**
- Real-time slot availability checking.
- Multi-slot selection and dynamic pricing.
- Midtrans Snap integration for secure payments.
- Automatic payment status synchronization and 15-minute timer.
- Split Bill functionality with join codes.

**Phase 4: Venue & Search - Completed**
- Advanced search with filtering.
- Detailed venue profiles with parallax headers and facilities.
- Multi-court support per venue.

## Features
- **Discovery:** Browse sports venues, filter by category/location.
- **Booking:** Select multiple hours, choose courts, and pay via Midtrans.
- **Social:** Split the bill with friends using a unique 6-digit code.
- **Management:** View booking history and real-time payment status.
