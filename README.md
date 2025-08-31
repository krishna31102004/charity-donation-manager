# CharityDonationManager — iOS (SwiftUI)

A polished iOS app built with **SwiftUI** that helps users discover charities near them, view details, favorite orgs, and record donations. It uses **SwiftData** for local persistence and **MapKit/CoreLocation** for location-aware discovery. The donate screen is a **professional, dummy payment flow** (no real charges) with card-style validation.

---

## 👀 Demo

> Replace with your own assets

**GIF preview:**
`Docs/demo.gif`

**Screenshots:**

<p align="center">
  <img src="Docs/screen1.png" width="240" />
  <img src="Docs/screen2.png" width="240" />
  <img src="Docs/screen3.png" width="240" />
</p>

---

## ✨ Features

* 🔍 **Discover charities nearby** (MapKit + CoreLocation)  
* 🗺 **Place Detail** page with map, distance, favorite & donate actions  
* ❤️ **Favorites** (add/remove; persisted via SwiftData)  
* 💳 **Dummy payment screen** (card UI w/ validation — 16-digit number with auto spacing, 3-digit CVV, compact expiry)  
* 📜 **Donation History** (stored locally via SwiftData)  
* 👤 **Profile** view (basic info + logout/delete stubs)  
* 🔐 **Auth screens** (Login / Register / Forgot Password — local demo flow)  
* 🎨 **Professional UI** with card sections, empty states, and consistent spacing/typography  

---

## 🧱 Tech Stack

* **SwiftUI** (iOS 17+) + **Observation** (`@Observable`, `@Bindable`)  
* **SwiftData** (local models: donations, favorites, etc.)  
* **MapKit** + **CoreLocation** for discovery & distances  
* **MVVM-style** view models and preview-driven development  
* **No backend required** (donations are simulated & stored locally)  

---

## 🗺️ Location & (Optional) Google Services

**Default:** All discovery & mapping uses **Apple MapKit** + `MKLocalSearch` (no extra keys).

**Optional – Google Places API** (if you want richer POI data):  

* Add the **Google Places SDK for iOS** via Swift Package Manager:  
  - Xcode → Project → **Package Dependencies** →  
    `https://github.com/googlemaps/ios-places-sdk`  
  - Add the `GooglePlaces` product to your app target.  

* Add your key to **Info.plist**:  
  - Key: `GMSPlacesAPIKey` → *Your Google Places API Key*  

* Usage: swap the MapKit search layer for a small adapter that queries Places (Text Search / Nearby Search) and maps results into your existing `PlaceDTO`.

> This project ships “Apple-first” out of the box. Google Places is **optional** and can be toggled per build/config if you add the dependency and key.

---

## 💳 Dummy Payment Flow (no real charges)

* **Card Number:** exactly **16 digits**; UI auto-formats as `#### #### #### ####`  
* **CVV:** **3 digits**  
* **Expiry:** compact **DatePicker** (treated as MM/YY for validation)  
* **Validation:** digits-only; invalid characters immediately block submission  
* **On Confirm:** simulated spinner → saved to **Donation History (SwiftData)**  

---

## 🧭 App Flow

**Discover → Place Detail → Donate → History**  
Tabs: **Discover**, **Favorites**, **History**, **Profile**.  
Auth screens (Login/Register/Forgot) are demo-level stubs to showcase flows.  

---

## 📁 Project Structure (high level)

```

CharityDonationManager/
├─ Models/
│  └─ DonationRecord.swift
├─ ViewModels/
│  ├─ DonationViewModel.swift
│  └─ AuthViewModel.swift
├─ Views/
│  ├─ LaunchView\.swift
│  ├─ RootView\.swift
│  ├─ DiscoverView\.swift
│  ├─ PlaceDetailView\.swift
│  ├─ FavoritesView\.swift
│  ├─ DonationView\.swift          // dummy payment UI + validation
│  ├─ DonationHistoryView\.swift
│  ├─ ProfileView\.swift
│  ├─ LoginView\.swift
│  ├─ RegisterView\.swift
│  └─ ForgotPasswordView\.swift
└─ Resources/
└─ Assets.xcassets, Info.plist, Docs/, etc.

````

---

## 🚀 Getting Started

### Prerequisites

* **Xcode 15+**  
* **iOS 17+** simulator or device  

### Run

```bash
# Clone the repo
git clone https://github.com/krishna31102004/charity-donation-manager.git
cd charity-donation-manager

# Open in Xcode
open CharityDonationManager.xcodeproj
````

Select a simulator (e.g., **iPhone 15 Pro**) → **Run (▶)**

### Permissions

If discovery uses location, add to **Info.plist**:

* `NSLocationWhenInUseUsageDescription` — “We use your location to find nearby charities.”

---

### 📄 LICENSE

MIT License

Copyright (c) 2025 Krishna Balaji

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
