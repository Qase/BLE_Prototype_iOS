//
//  AppDelegate.swift
//  BLE_Lock_Master
//
//  Created by David Nemec on 27/04/2017.
//  Copyright © 2017 David Nemec. All rights reserved.
//

import UIKit
import BLE_shared
import QuantiLogger
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        #if DEBUG
            //Fabric.with([Crashlytics.self])
        #else
            Fabric.with([Crashlytics.self])
        #endif
        

        
        // Setup loging
        let logManager = LogManager.shared
        
        let consoleLogger = ConsoleLogger()
        consoleLogger.levels = [.verbose, .info, .debug, .warn, .error]
        logManager.add(consoleLogger)
        
        let fileLogger = FileLogger()
        fileLogger.levels = [.verbose, .info, .debug, .warn, .error]
        logManager.add(fileLogger)
        
        let systemLogger = SystemLogger(subsystem: "cz.quanti.BLE-Lock-Master", category: "logging")
        systemLogger.levels = [.verbose, .info, .debug, .warn, .error]
        logManager.add(systemLogger)
        
        // Draw controller
        window = UIWindow(frame: UIScreen.main.bounds)
        if let _window = window {
            _window.rootViewController = DevicesTableViewController()
            
            _window.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

