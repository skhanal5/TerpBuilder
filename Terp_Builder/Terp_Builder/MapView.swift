//
//  MapView.swift
//  Terp_Builder
//
//  Created by caleb on 3/12/23.
//

import SwiftUI
import MapKit
import CoreLocation


struct MapView: View {
    
    
    @State var latitudinalMeters: CLLocationDistance = 500
    @State var longitudinalMeters: CLLocationDistance = 500
    
    //defines our region which is fixed at an arbitrary point
    @State private var region = MKCoordinateRegion(center:
                                                    CLLocationCoordinate2D(latitude: 38.9869, longitude: -76.9426), latitudinalMeters: 500, longitudinalMeters: 500)
    
    //contains our annotations, user is fixed and is the first 'BuildingResponse'
    @State private var annotations: [BuildingResponse] = [BuildingResponse(name: "user", code: "", id: "", long: -76.9426, lat: 38.9869)]
    
    //used for our searching
    @State private var query: String = ""
    @State private var filteredBuildings: [BuildingResponse] = []
    
    //used to determine whether to show the popup modal
    @State private var popupTriggered: Bool = false
    
    //models
    @StateObject private var apiModel = APIModel()
    @StateObject private var directionModel = DirectionsViewModel()
    
    
    //next two blocks are used for searching
    private var buildings: [BuildingResponse] {
        filteredBuildings.isEmpty ? apiModel.locations : filteredBuildings
    }
    
    private func preformSearch(keyword: String) {
        filteredBuildings = apiModel.locations.filter { building in building.name
                .localizedCaseInsensitiveContains(keyword)
            ||
            building.code
                .localizedCaseInsensitiveContains(keyword)
        }
    }
    
    var body: some View {
        VStack {
            Text("Navigation")
                .font(.custom("Helvetica Neue", size: 20))
                .foregroundColor(.white)
                .fontWeight(.bold)
            ZStack {
                VStack {
                       Map(coordinateRegion: $region, interactionModes: .all,
                           annotationItems: annotations) { loc in
                           MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.long)) {
                               PlaceAnnotationView(name: loc.name)
                           }
                       }
                           .frame(height: 480)
                    Spacer()
                }
                VStack {
                    Spacer()
                    if (annotations.count == 2) {
                        HStack {
                            TimePopup(directionModel.time)
                            DistancePopup(directionModel.distance)
                            DirectionsPopup()
                                .onTapGesture {
                                    if !popupTriggered {
                                        popupTriggered = true
                                    }
                                }
                        }
                    }
                    NavigationStack {
                        if (query.count != 0) {
                            List(buildings) { building in
                                Text(building.name)
                                    .onTapGesture {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                            if (annotations.count == 1) {
                                                annotations.append(building)
                                            } else {
                                                annotations.remove(at: 1)
                                                annotations.append(building)
                                            }
                                            query = ""
                                            computeDirs(annotations[0].long, annotations[0].lat, annotations[1].long, annotations[1].lat)
                                  
                                        })
                                    }
                            }
                            .task {
                                do {
                                    try await apiModel.fetchAllBuildings()
                                } catch {
                                    print("test")
                                }
                            }
                            .onChange(of: query, perform: preformSearch)
                        } else {
                            //show only a few locations
                            popularLocations(annotations: $annotations, region: $region).environmentObject(directionModel)
                        }
                    }
                    .frame(height: 250)
                    .searchable(text: $query, prompt:"Enter a building...")
                    .scrollContentBackground(.automatic)
                }.popover(isPresented: $popupTriggered) {
                    DirectionsModal().environmentObject(directionModel)
                }
            }
        }
        .background(Color.accentColor)
    }
    
    func computeDirs(_ sourceLong:Double, _ sourceLat: Double, _ destLong:Double, _ destLat: Double) {
        Task {
            await  region = directionModel.computeDirections(sourceLong: sourceLong, sourceLat: sourceLat, destLong: destLong, destLat: destLat)
        }
    }
}

struct DirectionsModal: View {
    @EnvironmentObject private var directionModel: DirectionsViewModel
    
    var body: some View {
        VStack {
            Text("Directions")
                .font(.custom("Helvetica Neue", size: 20))
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 15)
            VStack {
                List(directionModel.dirs, id:\.self) { dir in
                    HStack {
                        Text(dir.instructions)
                    }
                }
            }
        }.background(Color.accentColor)
    }
}

//popup that appears on the left when a location is selected
struct TimePopup: View {
    var time: TimeInterval
    init(_ time: TimeInterval) {
        self.time = time
    }
    
    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(CustomColor.HIGHLIGHT)
                .overlay {
                    Text(String(format: "%.1f", time) + " min")
                        .foregroundColor(.white)
                        .bold()
                        .animation(.easeIn, value: 10)
                }.frame(width: 100, height: 30)
                .padding(.trailing, 20)
        }
    }
}

//popup that appears on the middle when a location is selected
struct DistancePopup: View {
    var dist: Double
    init(_ dist: Double) {
        self.dist = dist
    }
    
    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(CustomColor.SECONDARY)
                .overlay {
                    Text(String(format: "%.1f", dist) + " m")
                        .foregroundColor(.white)
                        .bold()
                        .animation(.easeIn, value: 10)
                }.frame(width: 100, height: 30)
                .padding(.trailing, 15)
        }
    }
}

//popup that appears on the right when a location is selected
struct DirectionsPopup: View {
    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color.accentColor)
                .overlay {
                    Text("Directions")
                        .foregroundColor(.white)
                        .bold()
                }.frame(width: 100, height: 30)
                .padding(.trailing, 10)
        }
    }
}

//hstack in the bottom
struct popularLocations: View {
    @EnvironmentObject var directionModel: DirectionsViewModel
    @Binding var annotations: [BuildingResponse]
    @Binding var region: MKCoordinateRegion
    
    var list:[BuildingResponse] = [BuildingResponse(name: "IRB", code: "", id: "432", long: -76.9364438800535, lat: 38.9891607057353), BuildingResponse(name: "MCK", code: "", id: "035", long: -76.9451004712142,lat: 38.98598155), BuildingResponse(name: "ESJ", code: "", id:"226",long:-76.941914,lat:38.986699)]
    
    var body: some View {
        VStack {
            HStack {
                Text("Popular locations:")
                    .font(.system(size: 20))
                    .bold()
                    .padding(.top, 10)
                Spacer()
            }
            HStack {
                ForEach(list, id:\.self) { building in
                    popularLocationsCell(building.name)
                        .onTapGesture {
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                if (annotations.count == 1) {
                                    annotations.append(building)
                                } else {
                                    annotations.remove(at: 1)
                                    annotations.append(building)
                                }
                                
                                computeDirs(annotations[0].long, annotations[0].lat, annotations[1].long, annotations[1].lat)
                            })
                        }
                }
            }
            .background(Color(red: 0, green: 0, blue: 0, opacity:0.05))
            .cornerRadius(10)
            .frame(height:100)
        }
        .padding()
    }
    
    func computeDirs(_ sourceLong:Double, _ sourceLat: Double, _ destLong:Double, _ destLat: Double) {
        Task {
            await  region = directionModel.computeDirections(sourceLong: sourceLong, sourceLat: sourceLat, destLong: destLong, destLat: destLat)
        }
    }
}

//individual cell in the hstack
struct popularLocationsCell: View {
    var name: String
    
    init(_ name: String) {
        self.name = name
    }
    
    var body: some View {
        VStack {
            Image(systemName: "building.2.crop.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(Color.accentColor)
            Spacer()
            Text(name)
                .font(.system(size: 15))
            Spacer()
        }
        .frame(width:85)
        .frame(height:50)
        .padding(10)
        Divider()
    }
}

/*
    Defines custom annotations for the map
    -> idea & general code comes from a tutorial
 */
struct PlaceAnnotationView: View {
    
    var name: String
    
    var body: some View {
        VStack(spacing: 0){
            //first case is the default "pin" look
            if (name != "user"){
                Image(systemName: "building.2.crop.circle.fill")
                    .renderingMode(.original)
                    .foregroundColor(.accentColor)
                    .font(.title)
                Image(systemName: "arrowtriangle.down.fill")
                    .renderingMode(.original)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                    .offset(x:0, y:-5)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .renderingMode(.original)
                    .font(.title)
                    .foregroundColor(.accentColor)
                Image(systemName: "arrowtriangle.down.fill")
                    .renderingMode(.original)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)
                    .offset(x:0, y:-5)
            }
        }
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
