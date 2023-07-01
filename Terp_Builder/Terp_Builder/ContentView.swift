//
//  ContentView.swift
//  Terp_Builder
//
//  Created by caleb on 3/3/23.
//

import SwiftUI

//move this into a separate standalone config file

struct ContentView: View {
    @EnvironmentObject var schedule: ScheduleModel
    @EnvironmentObject var notify: NotificationModel
    
    var body: some View {
        VStack {
            TabView() {
                ScheduleView().environmentObject(schedule).tabItem {
                    Label("Schedule", systemImage: "house")
                        .foregroundColor(.red)
                }
                AddClassView()
                    .environmentObject(schedule)
                    .environmentObject(notify)
                    .tabItem {
                    Label("Add Course", systemImage: "plus")
                        .foregroundColor(.red)
                }
                MapView().tabItem {
                    Label("Navigation", systemImage: "map")
                        .foregroundColor(.red)
                }
                ReviewView()
                    .tabItem {
                    Label("Review", systemImage: "square.and.pencil")
                        .foregroundColor(.red)
                }
                SettingsView()
                    .environmentObject(notify)
                    .tabItem {
                    Label("Settings", systemImage: "gear")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ScheduleModel())
            .environmentObject(NotificationModel())
    }
}
