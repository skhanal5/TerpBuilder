//
//  AddClassView.swift
//  Terp_Builder
//
//  Created by caleb on 3/12/23.
//

import SwiftUI
import Firebase

struct AddClassView: View {
    @EnvironmentObject var schedule: ScheduleModel
    @EnvironmentObject var notify: NotificationModel
    
    @State private var filteredCourses: [CourseResponse] = []
    @State private var search: String = ""
    @StateObject private var apiModel = APIModel()

    //Preforms the course searching
    //Users can specify either course numbers or course titles
    private func preformSearch(keyword: String) {
        filteredCourses = apiModel.courses.filter { course in
            course.id.localizedCaseInsensitiveContains(keyword)
            || course.name.localizedCaseInsensitiveContains(keyword)
        }
    }
    
    private var courses: [CourseResponse] {
        filteredCourses.isEmpty ? apiModel.courses: filteredCourses
    }
    
    var body: some View {
        VStack {
            Text("Search for a class")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(.white)
                .fontWeight(.bold)
            NavigationStack{
                List(courses) { course in
                    VStack(alignment: .leading) {
                        NavigationLink {
                            
                            //The legacy function has the old static data
                            //The curent one makes api calls
                            DetailedCourseInfo(course: course)
                                .environmentObject(schedule)
                                .environmentObject(notify)
                                .navigationBarTitleDisplayMode(.inline)
                        } label: {
                            HStack {
                                VStack(alignment:.leading) {
                                    Text(course.id)
                                    Text(course.name)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .searchable(text: $search, prompt:"Enter a class number...")
                .onChange(of: search, perform: preformSearch)
                .task {
                    do {
                        try await apiModel.fetchCourses()
                    } catch {
                        print(error)
                    }
                }
                .background(CustomColor.NEUTRAL)
                .scrollContentBackground(.hidden)
            }
        }
        .background(Color.accentColor)
    }
}

struct DetailedCourseInfo: View {
    @EnvironmentObject var schedule: ScheduleModel
    @EnvironmentObject var notify: NotificationModel

    private var course: CourseResponse
    @StateObject private var apiModel = APIModel()
    @State var reviews: [String] = []

    
    init(course: CourseResponse) {
        self.course = course
    }
    
    var body: some View {
        VStack {
            ScrollView {
                if apiModel.info.count >= 1 {
                    ZStack {
                        VStack(spacing: 15) {
                            VStack {
                                Text(apiModel.info[0].id)
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                                Text(apiModel.info[0].name)
                                    .font(.system(size: 20))
                                    .fontWeight(.bold)
                            }
                            HStack {
                                Text("Credits: ")
                                    .fontWeight(.bold)
                                Text(String(apiModel.info[0].credits))
                                Spacer()
                            }
                            HStack {
                                Text("Prerequisites: ")
                                    .fontWeight(.bold)
                                
                                Text(apiModel.info[0].relationships.prereqs ?? "None")
                                Spacer()
                            }
                            Text(apiModel.info[0].description)
                            HStack {
                                Text("Sections:")
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            VStack {
                                ForEach(apiModel.info[0].sections, id: \.self) { section in
                                    SectionView(section: section, info: apiModel.info[0])
                                        .environmentObject(schedule)
                                        .environmentObject(notify)
                                    Divider()
                                }
                            }
                            .padding()
                            .background(CustomColor.NEUTRAL)
                            Spacer()
                            
                            VStack {
                                reviewView(course: course)
                            }
                            
                        }
                        .padding()
                        .alert(isPresented: $schedule.addFailed) {
                            Alert(title: Text("Couldn't add this course"),
                                  message: Text("Either this course is in your schedule or you attempted to add a course that would cause a time conflict"),
                                  dismissButton: .default(Text("Ok")))
                        }
                    }
                }
                
            }
        }.task {
            do {
                try await apiModel.fetchCourseInfo(classID: course.id)
            } catch {
                print(error)
            }
        }
    }
}


struct SectionView: View {
    @EnvironmentObject var schedule: ScheduleModel
    @EnvironmentObject var notify: NotificationModel
    
    private var section: String
    private var info: InfoResponse
    @StateObject private var apiModel = APIModel()
    
    init(section: String, info:InfoResponse) {
        self.section = section
        self.info = info
    }
    
    func getLecture() -> Meeting? {
        for x in apiModel.sections[0].meetings {
           // print("\n\n")
            //print(x)
            if x.classtype == "" {
                return x
            }
        }
        return nil
    }
    
    func getDiscussion() -> Meeting? {
        for x in apiModel.sections[0].meetings {
           // print(x)
            if x.classtype == "Discussion" {
                return x
            }
        }
        return nil
    }
    
    var body: some View {
        VStack{
            if apiModel.sections.count >= 1 {
                VStack(spacing: 5) {
                    
                    //Section Id
                    HStack{
                        Text(apiModel.sections[0].id)
                            .foregroundColor(.accentColor)
                            .fontWeight(.bold)
                        Spacer()
                        
                        //if seats are nonzero, we can add the course
                        if apiModel.sections[0].open_seats != "0" {
                            
                            //if courses has already been added indicate a checkmark
                            //can delete course from here
                            if schedule.currClasses.contains(apiModel.sections[0].id) {
                                Button(action: {
                                    deleteCourse(info: info, section: apiModel.sections[0])
                                }){
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(.green)
                                }
                                .padding(.trailing, 20)
                            } else {
                                Button(action: {
                                    addCourse(info: info, section: apiModel.sections[0])
                                }){
                                    Image(systemName: "plus.square.fill")
                                        .font(.system(size: 30))
                                }
                                .padding(.trailing, 20)
                            }
                            
                        //if seats are zero, then allow notifications
                        } else {
                            Button(action:{
                                addNotification(info: info, section: apiModel.sections[0])
                            }){
                                Image(systemName: "bell.square.fill")
                                    .font(.system(size: 30))
                            }
                            .padding(.trailing, 20)
                        }
                        
                    }
                    .padding(.leading, 15)
                    .padding(.top, 10)
                    
                    
                    //Professor Info
                    HStack {
                        Text("Professor:")
                            .fontWeight(.bold)
                        if apiModel.sections[0].instructors.count == 0 {
                            Text("TBA")
                        } else {
                            Text(apiModel.sections[0].instructors.joined(separator: ", "))
                        }
                        Spacer()
                    }
                    .padding(.leading, 15)
                    .padding(.top, 5)
                    Divider()
                    
                    
                    //Lecture Info
                    HStack {
                        Text("Lecture:")
                            .fontWeight(.bold)
                        Spacer()
                        VStack(alignment: .leading) {
                            let lec = getLecture()
                            HStack {
                                Text("\(lec?.days ?? "0")")
                                Text("\(lec?.start_time ?? "0") - \(lec?.end_time ?? "0")")
                            }
                            Text(apiModel.sections[0].meetings[0].building)
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(height: 50)
                    Divider()
                    
                    
                    //Discussion Info
                    //Discussion tab will not be displayed when unused
                    let disc = getDiscussion()
                    if disc != nil {
                        HStack {
                            Text("Discussion:")
                                .fontWeight(.bold)
                            
                            Spacer()
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(disc?.days ?? "0")")
                                    Text("\(disc?.start_time ?? "0") - \(disc?.end_time ?? "0")")
                                }
                                Text(apiModel.sections[0].meetings[0].building)
                            }
                            Spacer()
                        }
                        .padding()
                        .frame(height: 50)
                    }
                    
                    //Seats Info
                    HStack {
                        Text("Seats:")
                            .fontWeight(.bold)
                        
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Total: \(apiModel.sections[0].seats)")
                                Text("Open: \(apiModel.sections[0].open_seats)")
                            }
                            Text("Waitlist: \(apiModel.sections[0].waitlist)")
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(height: 50)
                }
                .background(Color.white)
                .cornerRadius(15)
            }
    
        }.task {
            do {
                try await apiModel.fetchSections(sectionID: section)
            } catch {
                print(error)
            }
        }

    }
    
    
    /*
        Adds a course to the current
        schedule.
     
        If there is a time-conflict with the current
        schedule, then an alert will pop-up
        where the user can either replace the existing
        course in that time slot or leave it as it is.
     
        otherwise, the alert will indicate that the
        addition was successful
     */
    
                                   
    func addCourse(info: InfoResponse, section: SectionResponse) {
        let course: CourseData = CourseData(id: info.id, name: info.name, credits: info.credits, description: info.description, relationships: info.relationships, instructor: section.instructors.count == 0 ? "TBA" : section.instructors[0], sectionID: section.id, meeting: section.meetings)
        schedule.addToSchedule(course: course)
    }
    
    func deleteCourse(info: InfoResponse, section: SectionResponse) {
        let course: CourseData = CourseData(id: info.id, name: info.name, credits: info.credits, description: info.description, relationships: info.relationships, instructor: section.instructors.count == 0 ? "TBA" : section.instructors[0], sectionID: section.id, meeting: section.meetings)
        schedule.removeFromSchedule(course: course)
    }
    

    func addNotification(info: InfoResponse, section: SectionResponse ) {
        notify.pushNotification(
            date: Date.now.addingTimeInterval(60),
            title: "Seat Notification for \(info.name) - \(section.id)",
            body: "You will be notified when seats are available")
    }
}

struct reviewView: View {
    @EnvironmentObject var schedule: ScheduleModel
    @State var reviews: [[String:String]] = []
    private var course: CourseResponse
    
    init(course: CourseResponse) {
        self.course = course
    }
    
    var body: some View {
        HStack{
            Text("Reviews:").fontWeight(.bold)
            Spacer()
        }
        
        VStack() {
            
            if (reviews.count > 0) {
                ForEach(reviews, id: \.self) { review in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.2))
                        
                        VStack {
                            starView(stars: review["rating"]!)
                            Text("Professor: \(review["professor"]!)").foregroundColor(.black).padding(8)
                            Divider()
                            Text(review["review"]!).foregroundColor(.black).padding(8)
                        }.padding()
                    }
                }
            } else {
                Text("No reviews for this course")
            }
        }.padding(16).onAppear(perform: loadReviews)
        
    }
    
    func loadReviews() {
        let rootRef = Database.database().reference()
        let ref = rootRef.child("courses").child(course.id)

        ref.observe(.value, with: { snapshot in
            print(snapshot.children.allObjects)
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let childData = childSnapshot.value as! [String:String]
                reviews.append(childData)
                print(childData)
            }
        })
    }
    
}

struct starView: View {
    var stars: String
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { num in
                Image(systemName: num <= Int(stars)! ? "star.fill" : "star")
                    .font(.system(size: 20))
                    .foregroundColor(num <= Int(stars)! ? .yellow : .gray)
            }
        }
    }
}

struct AddClassView_Previews: PreviewProvider {
    static var previews: some View {
        AddClassView()
            .environmentObject(ScheduleModel())
            .environmentObject(NotificationModel())
    }
}
