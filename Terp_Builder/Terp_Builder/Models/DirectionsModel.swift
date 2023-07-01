//
//  Directions.swift
//  Terp_Builder
//
//  Created by Subodh Khanal on 4/16/23.
//

import Foundation
import CoreLocation
import MapKit

//idea for this code comes from a tutorial that is modified for our needs
//source: "Calculating Directions in SwiftUI" on YouTube

class DirectionsViewModel: ObservableObject {    
    @Published var dirs: [MKRoute.Step] = []
    
    //distance in miles
    @Published var distance: CLLocationDistance = 0
    
    //time in minutes
    @Published var time: TimeInterval = 0
    
    func computeDirections(sourceLong: Double, sourceLat: Double, destLong: Double, destLat: Double) async -> MKCoordinateRegion {
        
        if (dirs.count != 0) {
            //reset previous directions
            dirs = []
        }
        
        do {
            let directionReq = MKDirections.Request()
            directionReq.transportType = .walking
            directionReq.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: sourceLat, longitude: sourceLong)))
            directionReq.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destLat, longitude: destLong)))
            let directions = MKDirections(request: directionReq)
            let response = try await directions.calculate()
            
            if let route = response.routes.first {

                dirs = route.steps
                time = route.expectedTravelTime/60
                distance = route.distance * 0.000621 //rough approx
                return MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(latitude: (sourceLat+destLat)/2, longitude: (sourceLong+destLong)/2), latitudinalMeters: route.distance+100, longitudinalMeters: route.distance+100)
            }
            
        } catch {
            print(error)
        }
        return MKCoordinateRegion(center:
                                    CLLocationCoordinate2D(latitude: 38.9869, longitude: -76.9426), latitudinalMeters: 500, longitudinalMeters: 500)
    }
    
}
