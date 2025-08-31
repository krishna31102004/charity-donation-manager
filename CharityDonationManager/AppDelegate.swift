//
//  AppDelegate.swift
//  CharityDonationManager(CDM)
//
//  Created by Krishna Balaji on 8/26/25.
//


import UIKit
import GooglePlaces

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let key = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_PLACES_API_KEY") as? String ?? ""
        if !key.isEmpty { GMSPlacesClient.provideAPIKey(key) }
        return true
    }
}
