//
//  ScheduleModel.swift
//  Terp_Builder
//
//  Created by Subodh Khanal on 3/27/23.
//

import Foundation

enum Day: String, CaseIterable {
    case Sun, Mon, Tue, Wen, Thu, Fri, Sat
}

/*
    Data is a struct that contains all course data.
    It is a more compact version of the Info & Sections struct
    since we do not need the additional information
 */
struct CourseData: Equatable {
    let id: String
    let name: String
    let credits: String
    let description: String
    let relationships: relationship
    let instructor: String
    let sectionID: String
    let meeting: [Meeting]
    
    //sectionID is unique, no need to compare other values
    static func == (lhs: CourseData, rhs:CourseData) -> Bool {
        return lhs.sectionID == rhs.sectionID
    }
}

class ScheduleModel:ObservableObject {
    
    /*
        A dictionary containing the CourseData for each day of the week.
     */
    @Published var currSchedule: [Day: [CourseData]] =
        [.Sun: [], .Mon: [], .Tue: [], .Wen: [], .Thu: [], .Fri: [], .Sat: []]
    
    //an array of section-id's for fast look-up
    @Published var currClasses: [String] = []
    
    @Published var addFailed: Bool = false
    
    func addToSchedule (course: CourseData) {
        if (checkConflict(course: course)) {
            addFailed = true
        } else {
            if course.meeting[0].days == "MWF" {
                currSchedule[.Mon]!.append(course)
                currSchedule[.Wen]!.append(course)
                currSchedule[.Fri]!.append(course)
            } else if course.meeting[0].days == "TuTh" {
                currSchedule[.Tue]!.append(course)
                currSchedule[.Thu]!.append(course)
            } else if course.meeting[0].days == "MW" {
                currSchedule[.Mon]!.append(course)
                currSchedule[.Wen]!.append(course)
            } else if course.meeting[0].days.count == 1 {
                if course.meeting[0].days.first == "M" {
                    currSchedule[.Mon]!.append(course)
                } else if course.meeting[0].days.first == "W" {
                    currSchedule[.Wen]!.append(course)
                } else {
                    currSchedule[.Fri]!.append(course)
                }
            } else if course.meeting[0].days.count == 2 {
                if course.meeting[0].days == "Tu" {
                    currSchedule[.Tue]!.append(course)
                } else {
                    currSchedule[.Thu]!.append(course)
                }
            }
            currClasses.append(course.sectionID)
            addFailed = false
        }
        print(addFailed)
    }
    
    
    /*
        Verify that the lecture times do not conflict
        -MWF
        -TuTh
        -MW
        -Only 1 day of lecture
        -might be missing additional cases
     
        Return true: if there are conflicts, false otherwise
     */
    func checkConflict(course: CourseData) -> Bool {
        if course.meeting[0].days == "MWF" {
            return (checkLecture(day: .Mon, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
                && checkLecture(day: .Wen, startTime:course.meeting[0].start_time, endTime: course.meeting[0].end_time)
                && checkLecture(day: .Fri, startTime:course.meeting[0].start_time, endTime: course.meeting[0].end_time))
        } else if course.meeting[0].days == "TuTh" {
                return (checkLecture(day: .Tue, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
                    && checkLecture(day: .Thu, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time))
        } else if course.meeting[0].days == "MW" {
            return (checkLecture(day: .Mon, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
                && checkLecture(day: .Wen, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time))
        } else if course.meeting[0].days.count == 1 {
            if course.meeting[0].days.first == "M" {
                return checkLecture(day: .Mon, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
            } else if course.meeting[0].days.first == "W" {
                return checkLecture(day: .Wen, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
            } else {
                return checkLecture(day: .Fri, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
            }
        } else if course.meeting[0].days.count == 2 {
            if course.meeting[0].days == "Tu" {
                return checkLecture(day: .Tue, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
            } else {
                return checkLecture(day: .Thu, startTime: course.meeting[0].start_time, endTime: course.meeting[0].end_time)
            }
        }
        
        if course.meeting.count == 2 {
            if course.meeting[1].days == "MWF" {
                return (checkDiscussion(day: .Mon, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                    && checkDiscussion(day: .Wen, startTime:course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                    && checkDiscussion(day: .Fri, startTime:course.meeting[1].start_time, endTime: course.meeting[1].end_time))
            } else if course.meeting[1].days == "TuTh" {
                    return (checkDiscussion(day: .Tue, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                        && checkDiscussion(day: .Thu, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time))
            } else if course.meeting[1].days == "MW" {
                return (checkDiscussion(day: .Mon, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                    && checkDiscussion(day: .Wen, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time))
            } else if course.meeting[1].days.count == 1 {
                if course.meeting[1].days.first == "M" {
                    return checkDiscussion(day: .Mon, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                } else if course.meeting[1].days.first == "W" {
                    return checkDiscussion(day: .Wen, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                } else {
                    return checkDiscussion(day: .Fri, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                }
            } else if course.meeting[1].days.count == 2 {
                if course.meeting[1].days == "Tu" {
                    return checkDiscussion(day: .Tue, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                } else {
                    return checkDiscussion(day: .Thu, startTime: course.meeting[1].start_time, endTime: course.meeting[1].end_time)
                }
            }
        }
        return false
    }
    
    
    /*
        Verify that the lecture times do not conflict
     
        Return true: if there are conflicts, false otherwise
     */
    func checkLecture(day: Day, startTime: String, endTime: String) -> Bool {
        
        //need a date formatter to easily compare time intervals
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        
        //iterate through that days classes and see if the class start-time and end-time don't conflict
        if let arr = currSchedule[day] {
            for i in 0..<arr.count {
                
                /*
                    If the new class occurs before the existing one
                    or the new class occurs after the existing one,
                    it is valid otherwise it is not
                */
                if (arr[i].meeting[0].start_time == startTime && arr[i].meeting[0].end_time == endTime) {
                    return true
                }
                
                if ((formatter.date(from: arr[i].meeting[0].start_time)! < formatter.date(from: startTime)! &&
                    formatter.date(from: arr[i].meeting[0].end_time)! < formatter.date(from: endTime)!) ||
                    (formatter.date(from: arr[i].meeting[0].start_time)! > formatter.date(from: startTime)! &&
                        formatter.date(from: arr[i].meeting[0].end_time)! > formatter.date(from: endTime)!)) {
                    continue
                } else {
                    return true
                }
            }
        } else {
            print("anti triggered")
            return false
        }
        return false
    }
    
    
    /*
        Verify that the lecture times do not conflict
     
        Return true: if there are conflicts, false otherwise
     */
    func checkDiscussion(day: Day, startTime: String, endTime:String) -> Bool {
        //need a date formatter to easily compare time intervals
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        //iterate through that days classes and see if the class start-time and end-time don't conflict
        if let arr = currSchedule[day] {
            for i in 0..<arr.count {
                
                /*
                    If the new class occurs before the existing one
                    or the new class occurs after the existing one,
                    it is valid otherwise it is not
                */
                if arr[i].meeting.count == 2 {
                    if ((formatter.date(from: arr[i].meeting[1].start_time)! < formatter.date(from: startTime)! &&
                        formatter.date(from: arr[i].meeting[1].end_time)! < formatter.date(from: endTime)!) ||
                        (formatter.date(from: arr[i].meeting[1].start_time)! > formatter.date(from: startTime)! &&
                            formatter.date(from: arr[i].meeting[1].end_time)! > formatter.date(from: endTime)!)) {
                        continue
                    } else {
                        return true
                    }
                }
            }
        } else {
            return false
        }
        return false
    }
    
    
    func removeFromSchedule(course: CourseData) {
        
        //remove from currClasses
        if let index = currClasses.firstIndex(of: course.sectionID) {
            currClasses.remove(at: index)
        }
        
        
        //remove from dictionary
        if course.meeting[0].days == "MWF" {
            quickDelete(day: .Mon, course: course)
            quickDelete(day: .Wen, course: course)
            quickDelete(day: .Fri, course: course)
        } else if course.meeting[0].days == "TuTh" {
            quickDelete(day: .Tue, course: course)
            quickDelete(day: .Thu, course: course)
        } else if course.meeting[0].days == "MW" {
            quickDelete(day: .Mon, course: course)
            quickDelete(day: .Wen, course: course)
        } else if course.meeting[0].days.count == 1 {
            if course.meeting[0].days.first == "M" {
                quickDelete(day: .Mon, course: course)
            } else if course.meeting[0].days.first == "W" {
                quickDelete(day: .Wen, course: course)
            } else {
                quickDelete(day: .Fri, course: course)
            }
        } else if course.meeting[0].days.count == 2 {
            if course.meeting[0].days == "Tu" {
                quickDelete(day: .Tue, course: course)
            } else {
                quickDelete(day: .Thu, course: course)
            }
        }
    }
    
    func quickDelete(day: Day, course: CourseData) {
        if let index = currSchedule[day]!.firstIndex(of: course) {
            currSchedule[day]!.remove(at: index)
        }
    }
    
    
}
