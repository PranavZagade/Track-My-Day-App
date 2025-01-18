//
//  TrackMyDayApp.swift
//  TrackMyDay
//
//  Created by Pranav Zagade on 10/30/24.
//

import SwiftUI
import Firebase

@main
struct TrackMyDayApp: App {
    @StateObject var authManager = AuthenticationManager()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                TaskListView()
                    .environmentObject(authManager)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}

