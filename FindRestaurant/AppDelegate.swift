//
//  AppDelegate.swift
//  FindRestaurant
//
//  Created by Chaitali Patel on 04/07/22.
//

import UIKit
import CoreData
import GoogleMaps

let googleApiKey = "AIzaSyBr4Q9FyT0otujnEStamywgCqaomenO76Q"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleApiKey)
        
        if #available(iOS 15, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor(hexString: "282f58")
            ]
            navigationBarAppearance.backgroundColor = UIColor.white
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

            let tabBarApperance = UITabBarAppearance()
            tabBarApperance.configureWithOpaqueBackground()
            tabBarApperance.backgroundColor = UIColor.white
            UITabBar.appearance().scrollEdgeAppearance = tabBarApperance
            UITabBar.appearance().standardAppearance = tabBarApperance
        }
        return true
    }

}

