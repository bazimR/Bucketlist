//
//  Location.swift
//  Bucketlist
//
//  Created by Rishal Bazim on 27/03/25.
//

import Foundation
import MapKit

struct Location: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }

    #if DEBUG
        static let example = Location(
            id: UUID(),
            name: "Paris",
            description: "hotel paris tely",
            latitude: 12,
            longitude: -2
        )
    #endif
}
