////
//  SceneDelegate.swift
//  bikesystem
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        // START BLE
        _ = BLEManager.shared

        // Make sure scene is valid
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        // Create window
        let window = UIWindow(windowScene: windowScene)

        // Attach SwiftUI ContentView
        window.rootViewController = UIHostingController(
            rootView: ContentView()
        )

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}

