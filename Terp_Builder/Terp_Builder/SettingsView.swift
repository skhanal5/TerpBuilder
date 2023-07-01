//
//  SettingsView.swift
//  Terp_Builder
//
//  Created by caleb on 3/12/23.
//

import SwiftUI


struct SettingsView: View {
    @State private var date = Date()
    @EnvironmentObject var notify: NotificationModel

    var body: some View {
        VStack {
            Text("Settings")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(.white)
                .fontWeight(.bold)
            VStack {
                Spacer()
                VStack {
                    Text("Enter your registration date").font(.title)
                    
                    Divider()
                    
                    DatePicker(
                        "",
                        selection: $date,
                        displayedComponents: [.hourAndMinute, .date]
                    ).labelsHidden()
                        .scaleEffect(1.2)
                        .padding()

                    Divider()
                    
                    Button("Schedule Registration Reminder") {
                        notify.pushNotification(
                            date: date,
                            title: "Registration Date Reminder",
                            body: "Dont forget! Today is your class registration day")
                    }.font(.title3)
                    
                }.padding(10)
                .background(Color.white)
                Spacer()


            }
            .padding()
            .background(CustomColor.NEUTRAL)
        }
        .background(Color.accentColor)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
