//
//  AppDelegate.swift
//  Trimming
//
//  Created by 根岸 裕太 on 2020/11/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let image = UIImage(named: "youkai_amabie_mimi")?.pngData()
        let firstView = TrimmingViewController.instantiate(imageData: image!)

        window.rootViewController = firstView
        window.makeKeyAndVisible()

        return true
    }

}

