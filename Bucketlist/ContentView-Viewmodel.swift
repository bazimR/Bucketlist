//
//  ContentView-Viewmodel.swift
//  Bucketlist
//
//  Created by Rishal Bazim on 29/03/25.
//

import CoreLocation
import Foundation
import LocalAuthentication

extension ContentView {
    @Observable
    class ViewModel {
        private(set) var locations: [Location]
        var selectedPlace: Location?
        var isUnlocked = false
        let savedPath = URL.documentsDirectory.appending(path: "SavedPath")

        init() {
            do {
                let data = try Data(contentsOf: savedPath)
                locations = try JSONDecoder()
                    .decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }

        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data
                    .write(
                        to: savedPath,
                        options: [.atomic, .completeFileProtection]
                    )
            } catch {
                print("Unable save data.")
            }
        }
        func addLocation(at point: CLLocationCoordinate2D) {
            let newLocation = Location(
                id: UUID(),
                name: "New location",
                description: "",
                latitude: point.latitude,
                longitude: point.longitude
            )
            locations.append(newLocation)
            save()
        }

        func update(of location: Location) {
            guard let selectedPlace else { return }
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }
        func authenticate() {
            let context = LAContext()
            var error: NSError?

            if context
                .canEvaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    error: &error
                )
            {
                let reason =
                    "Please authenticate yourself to unlock your bucketlist."

                context
                    .evaluatePolicy(
                        .deviceOwnerAuthenticationWithBiometrics,
                        localizedReason: reason
                    ) { success, authenticateError in
                        if success {
                            self.isUnlocked = true
                        } else {
//error
                        }
                    }
            } else {
//no biometrics
            }
        }
    }
}
