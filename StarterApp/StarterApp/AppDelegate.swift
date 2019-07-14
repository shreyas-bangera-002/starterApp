//
//  AppDelegate.swift
//  StarterApp
//
//  Created by Shreyas Bangera on 15/06/19.
//  Copyright © 2019 Shreyas Bangera. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        inject {
            self.appLaunched()
        }
        #endif
        appLaunched()
        return true
    }
    
    func appLaunched() {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navCtlr = UINavigationController(rootViewController: UIViewController.controller(.character)).then {
            $0.isNavigationBarHidden = true
            $0.hero.isEnabled = true
            $0.hero.navigationAnimationType = .fade
            $0.hero.modalAnimationType = .selectBy(presenting:.zoom, dismissing:.zoomOut)
        }
        window?.rootViewController = navCtlr
        window?.makeKeyAndVisible()
    }
}

