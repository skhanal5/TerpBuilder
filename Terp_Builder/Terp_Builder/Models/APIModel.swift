//
//  APIModel.swift
//  Terp_Builder
//
//  Created by caleb on 3/26/23.
//

import Foundation


//https://beta.umd.io/

@MainActor
class APIModel: ObservableObject {
    
    @Published var courses: [CourseResponse] = []
    @Published var info: [InfoResponse] = []
    @Published var sections: [SectionResponse] = []
    @Published var locations: [BuildingResponse] = []

    func fetchCourses() async throws {
        
        let request = URLRequest(url: URL(string: "https://api.umd.io/v1/courses/list")!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let courseResponse = try JSONDecoder().decode([CourseResponse].self, from: data)
        courses = courseResponse
    }
    
    func fetchCourseInfo(classID: String) async throws {
        
        let request = URLRequest(url: URL(string: "https://api.umd.io/v1/courses/\(classID)")!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let infoResponse = try JSONDecoder().decode([InfoResponse].self, from: data)
        info = infoResponse
    }
    
    func fetchSections(sectionID: String) async throws {
        let request = URLRequest(url: URL(string: "https://api.umd.io/v1/courses/sections/\(sectionID)")!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let sectionResponse = try JSONDecoder().decode([SectionResponse].self, from: data)
        sections = sectionResponse
    }
    

    /* 
    func fetchCoordinates(building: String) async throws {
        let request = URLRequest(url: URL(string: "https://api.umd.io/v1/map/buildings/\(building)")!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let buildingResponse = try JSONDecoder().decode([BuildingResponse].self, from: data)
        locations = buildingResponse
    }
     */
    
    func fetchAllBuildings() async throws {
        let request = URLRequest(url: URL(string: "https://api.umd.io/v1/map/buildings")!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let buildingResponse = try JSONDecoder().decode([BuildingResponse].self, from: data)
        locations = buildingResponse
    }
}

