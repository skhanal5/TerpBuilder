//
//  Terp_BuilderApp.swift
//  Terp_Builder
//
//  Created by caleb on 3/3/23.
//

import SwiftUI
import Firebase


@main
struct Terp_BuilderApp: App {
    var schedule: ScheduleModel = ScheduleModel()
    let notify = NotificationModel()
    
    
    init() {
        notify.getPersission()
        FirebaseApp.configure()

    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(schedule)
                .environmentObject(notify)
        }
    }
}
