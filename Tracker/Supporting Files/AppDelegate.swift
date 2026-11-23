//
//  AppDelegate.swift
//  Tracker
//
//  Created by it on 05.09.2026.
//

import UIKit
import AppMetricaCore
@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let configuration = AppMetricaConfiguration(apiKey: "323043ee-fd66-402e-abbe-95a391b4074e") {
            AppMetrica.activate(with: configuration)
        }
            
        return true
    }
}

