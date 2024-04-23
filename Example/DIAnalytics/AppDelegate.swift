//
//  AppDelegate.swift
//  DIAnalytics
//
//  Created by liemvu on 06/29/2021.
//  Copyright (c) 2021 liemvu. All rights reserved.
//

import UIKit
import DIAnalyticsSDK
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
      
      Analytics.setDebugLogEnabled(true)
      let apiKey = "c2c09332-14a1-4eb1-8964-2d85b2a561c8"
      let trackingUrl = URL(string: "https://dev.datainsider.co/api/tracking/events/track")!
      Analytics.configure(apiKey: apiKey, trackingUrl: trackingUrl)
      FirebaseApp.configure()
      
      return true
    }

}

