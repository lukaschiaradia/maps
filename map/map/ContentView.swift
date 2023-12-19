//
//  ContentView.swift
//  map
//
//  Created by Lukas Chiaradia on 08/12/2023.
//

import SwiftUI
import MapKit


struct ContentView: View {
    @State private var cameraPosition: MapCameraPosition = .region(.userRegion)
    @State private var searchText = ""
    @State private var results = [MKMapItem]()
    
    var body: some View {
        Map(position: $cameraPosition) {
            
            Annotation("My location", coordinate: .userLocation) {
                ZStack {
                    Circle()
                        .frame (width: 32, height: 32)
                        .foregroundColor(.blue.opacity (0.25))
                    
                    Circle()
                        .frame (width: 20, height: 20)
                        .foregroundColor(.white)
                    
                    Circle()
                        .frame(width: 12, height: 12)
                        .foregroundColor (.blue)
                }
            }
            ForEach(results, id: \.self) { item in
            let placemark = item.placemark
            Marker(placemark.name ?? "", coordinate: placemark.coordinate)
                    }
        }
        .overlay(alignment: .top) {
            TextField("Search for a location...", text: $searchText)
                .font(.subheadline)
                .padding(12)
                .background(.white)
                .padding()
                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        }
        .onSubmit(of: /*@START_MENU_TOKEN@*/.text/*@END_MENU_TOKEN@*/) {
            Task { await searchPlace() }
        }
        .mapControls{
            MapCompass()
            MapPitchToggle()
            MapUserLocationButton()
        }
    }
}


extension ContentView {
    func searchPlace() async {
        let request = MKLocalSearch.Request()
        print(request)
        request.naturalLanguageQuery = searchText
        request.region = .userRegion

        let results = try? await MKLocalSearch(request: request).start()
        self.results = results?.mapItems ?? []
        await zoomToSelectedPoint()

    }
    func zoomToSelectedPoint() async {
        guard let selectedCoordinate = results.first?.placemark.coordinate else { return }

        let newRegion = MKCoordinateRegion(
            center: selectedCoordinate,
            latitudinalMeters: 10000,
            longitudinalMeters: 10000
        )

        // Mettre à jour la position de la caméra
        self.cameraPosition = .region(newRegion)
    }



    
    
}


extension CLLocationCoordinate2D {
    static var userLocation: CLLocationCoordinate2D {
        return .init(latitude:46.2636145, longitude: 2.178741)
    }
}

extension MKCoordinateRegion {
    static var userRegion: MKCoordinateRegion {
        return .init(center: .userLocation,
        latitudinalMeters: 1000000,
        longitudinalMeters: 100000)
    }
}


#Preview {
    ContentView()
}
