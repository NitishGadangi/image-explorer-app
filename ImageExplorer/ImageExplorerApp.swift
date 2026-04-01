//
//  ImageExplorerApp.swift
//  ImageExplorer
//
//  Created by Nitish Gadangi on 4/1/26.
//

import SwiftUI

@main
struct ImageExplorerApp: App {
    var body: some Scene {
        WindowGroup {
            AppFactory.shared.makeRootView()
        }
    }
}
