//
//  Course.swift
//  Terp_Builder
//
//  Created by caleb on 3/26/23.
//

import Foundation


struct CourseResponse: Decodable, Identifiable {
    
    var id: String
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "course_id"
        case name = "name"
    }
}

//The commented lines are unused but can be displayed


//For course description api call
struct InfoResponse: Codable, Identifiable {
    let id: String
    let semester: String
    let name: String
//    let dept_id: String
//    let department: String
    let credits: String
    let description: String
//    let grading_method: [String]
//    let gen_ed: [[String]]
//    let core: [String]
    let relationships: relationship
    let sections: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id = "course_id"
        case semester = "semester"
        case name = "name"
        case description = "description"
        case credits = "credits"
        case sections = "sections"
        case relationships = "relationships"
    }
}

struct relationship: Codable {
//    let coreqs: String?
    let prereqs: String?
//    let formerly: String?
//    let restrictions: String?
//    let additional_info: String?
//    let also_offered_as: String?
//    let credit_granted_for: String?
    
    private enum CodingKeys: String, CodingKey {
        case prereqs = "prereqs"
    }
}




struct SectionResponse: Codable, Identifiable {
    let id: String
//    let semester: String
//    let number: String
    let meetings: [Meeting]
    let seats: String
    let open_seats: String
    let waitlist: String
    let instructors: [String]
    
    private enum CodingKeys: String, CodingKey {
        case id = "section_id"
        case meetings = "meetings"
        case instructors = "instructors"
        case seats = "seats"
        case open_seats = "open_seats"
        case waitlist = "waitlist"
    }
}

struct Meeting: Codable {
    let days: String
    let room: String
    let building: String
    let classtype: String
    let start_time: String
    let end_time: String
}

/* Not in use in this version
struct buildingResponse: Codable {
    let data: [buildingData]
    let count: Int
}
*/

/* was previously referred to as buildingData*/
struct BuildingResponse: Codable, Identifiable, Hashable {
    let name: String
    let code: String
    let id: String
    let long: Double
    let lat: Double
}
