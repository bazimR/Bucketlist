//
//  ContentView.swift
//  Bucketlist
//
//  Created by Rishal Bazim on 27/03/25.
//

import MapKit
import SwiftUI

struct ContentView: View {
    let startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 8, longitude: 75),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )

    @State private var viewModel = ViewModel()
    var body: some View {
        if !viewModel.isUnlocked {
            ZStack {
                MapReader { MapProxy in
                    Map(initialPosition: startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(
                                location.name,
                                coordinate: location.coordinates
                            ) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.capsule)
                                    .onLongPressGesture(
                                        minimumDuration: 0.1,
                                        maximumDistance: 44
                                    ) {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }.mapStyle(
                        viewModel.mapType.value
                    ).onTapGesture { position in
                        if let coordinates = MapProxy.convert(
                            position, from: .local)
                        {
                            viewModel.addLocation(at: coordinates)
                        }
                    }.sheet(item: $viewModel.selectedPlace) { place in
                        EditPlaceView(
                            location: place
                        ) { viewModel.update(of: $0) }
                    }
                }
                VStack {
                    HStack {
                        Text(String(viewModel.locations.count))
                            .font(.largeTitle.bold())
                            .foregroundStyle(.primary)
                            .padding()
                        Spacer()
                        Picker("Map type", selection: $viewModel.mapType) {
                            Text("standard").tag(MapStyles.standard)
                            Text("Hybrid").tag(MapStyles.hybrid)
                        }.pickerStyle(.segmented).padding(.horizontal)

                    }
                    Spacer()
                }
            }
        } else {
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
    }
}

#Preview {
    ContentView()
}
