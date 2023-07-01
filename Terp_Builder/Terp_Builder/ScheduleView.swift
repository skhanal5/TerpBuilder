//
//  ScheduleView.swift
//  Terp_Builder
//
//  Created by caleb on 3/12/23.
//

import SwiftUI

func getDate() -> String {
    let curDay = Date()
    return curDay.formatted(Date.FormatStyle().weekday())
}

struct ScheduleView: View {
    @State private var selectedDay = getDate()
    @EnvironmentObject private var schedule: ScheduleModel
    
    var body: some View {
        
        VStack() {
            Text("Terp Builder")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(.white)
                .fontWeight(.bold)
            VStack{
                days
                Divider().padding()
                scheduleView
                    .background(CustomColor.NEUTRAL)
                    .scrollContentBackground(.hidden)
                    .padding(.top, -20)
            }
            .padding(.top, 15)
            .background(CustomColor.NEUTRAL)
        }.background(Color.accentColor)
        
    }
    
    
    var days: some View {
        HStack(alignment: .top) {
            ForEach(Day.allCases, id: \.self) { day in
                if day.rawValue == selectedDay {
                    ZStack {
                        Circle()
                            .fill(.white)

                        Circle()
                            .strokeBorder(.red, lineWidth: 3)
                    }.overlay {
                        Text("\(day.rawValue)")
                            .foregroundColor(Color.accentColor)
                    }.frame(width: 47, height: 47, alignment: .center)
                    
                } else {
                    ZStack {
                        Circle()
                            .fill(.white)
                        Circle()
                            .strokeBorder(.black, lineWidth: 2)
                    }.overlay {
                        Button("\(day.rawValue)") {
                            selectedDay = day.rawValue
                        }
                        .foregroundColor(.black)
                    }.frame(width: 47, height: 47, alignment: .center)
                }
            }
        }
    }
    
    
    var scheduleView: some View {
        
        return ScrollView {
            ZStack {
                VStack {
                    ForEach (8..<23) { t in
                        HStack {
                            if t < 12 {
                                Text("\(t) am")
                            } else if t == 12 {
                                Text("\(t) pm")
                            } else if t == 24 {
                                Text("\(t - 12) am")
                            } else {
                                Text("\(t - 12) pm")
                            }
                            Spacer()
                        }.padding(20)
                        Divider()
                    }
                }
                VStack {
                    ZStack{
                        ForEach (8..<23) { t in
                            HStack {
                                Spacer()
                                checkForClass(currTime: t)
                            }.padding(0)
                        }
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func checkForClass(currTime: Int) -> AnyView {
        //convert to enum value
        var currDay = Day.Mon
        for day in Day.allCases {
            if selectedDay == day.rawValue {
                currDay = day
            }
        }
        
        //loop classes on a given day
        for course in schedule.currSchedule[currDay]! {
            for i in course.meeting {
                //check if course meets current day because meetings are duplicated between days
                var meetsCurr = false
                var idx = 0 //used to determine Tu/Th
                for c in i.days {
                    let nextIdx = i.days.index(i.days.startIndex, offsetBy: idx+1)
                    if c.isUppercase {
                        if c == Character("M") && currDay == Day.Mon {
                            meetsCurr = true
                        } else if c == Character("T") && i.days[nextIdx] == "u" && currDay == Day.Tue {
                            meetsCurr = true
                        } else if c == Character("W") && currDay == Day.Wen {
                            meetsCurr = true
                        } else if c == Character("T") && i.days[nextIdx] == "h" && currDay == Day.Thu {
                            meetsCurr = true
                        } else if c == Character("F") && currDay == Day.Fri {
                            meetsCurr = true
                        }
                    }
                    idx += 1
                }
                
                if !meetsCurr {
                    return AnyView(ZStack { Text("") })
                }
                
                let (startHr, startMin) = convertTime(t: i.start_time)
                let (_, endMin) = convertTime(t: i.end_time)
                
                if currTime == startHr {
                    let hrOffset = CGFloat(startHr) - 8
                    var minOffset: CGFloat = 0
                    var courseHeight: CGFloat = 65 //50 min class
                    if startMin != 0 {
                        minOffset = 40
                    }
                    if endMin % 10 != 0 {
                        courseHeight = 95 //1:15 class
                    }
                    return AnyView(ZStack {
                        Rectangle().fill(CustomColor.SECONDARY).frame(width: 100, height: courseHeight).cornerRadius(10).offset(x:0, y:(hrOffset * 76.5) - 7 + minOffset)
                        Text(course.id).offset(x:0, y:(hrOffset * 76.5) - 7 + minOffset)
                    })
                }
            }
        }
        return AnyView(ZStack { Text("") })
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView().environmentObject(ScheduleModel())
    }
}

