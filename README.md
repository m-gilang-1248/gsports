# Gsports

Gsports is a SaaS (Software as a Service) mobile application for real-time sports venue booking, connecting venue owners (Mitra) and users.
# Nama: M. Gilang M.W. Sabdokafi
# NIM: 221240001248
## Test Account
- **User** email: akun2@gmail.com | pw: Akun2gmail.com
- **Owner** email: owner2@gmail.com | pw: Owner2gmail.com
- **Admin** email: admin2@gmail.com | pw: Admin2gmail.com


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
- **Booking:** Select multiple hours, choose courts, and pay via Midtrans (includes 2% service fee).
- **Social:** Split the bill with friends using a unique 6-digit code.
- **Scoreboard:** Digital scoreboard with per-sport logic (Limit 5x/month for Free users).
- **Monetization:** 
    - **AdMob Integration:** Banner ads in Home/Detail and Interstitial ads after matches for Free users.
    - **Premium Subscription:** Upgrade for Rp 1000/month via Google IAP to remove ads and unlock unlimited Scoreboard usage.
- **Wallet & Payouts:** Partners can track net revenue (after 5% platform commission) and request manual payouts.
- **Management:** View booking history and real-time payment status.

## Platform Administration
To access the Platform Admin features (e.g., Payout Management):
1.  Open the **Firebase Console**.
2.  Navigate to the **Firestore Database**.
3.  Find the `users` collection.
4.  Locate your user document by UID or email.
5.  Change the `role` field from `user` or `mitra` to `admin_platform`.
6.  Restart the app. You will be redirected to the Admin Payouts dashboard upon splash.
