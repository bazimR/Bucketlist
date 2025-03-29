//
//  EditPlaceView.swift
//  Bucketlist
//
//  Created by Rishal Bazim on 28/03/25.
//

import SwiftUI

struct EditPlaceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var description: String

    enum LoadingState {
        case loading, loaded, failed
    }

    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    var location: Location
    var onSave: (Location) -> Void
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Description", text: $description)
                Section("Nearby...") {
                    switch loadingState {
                    case .loading:
                        ProgressView()
                    case .loaded:
                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title).font(.headline) + Text(": ")
                                + Text(page.description)
                        }
                    case .failed:
                        Text("Failed to load")
                    }
                }
            }.task {
                await fetchNearbyPlaces()
            }.toolbar {
                ToolbarItem {
                    Button("Save") {
                        var newLocation = location
                        newLocation.id = UUID()
                        newLocation.name = name
                        newLocation.description = description

                        onSave(newLocation)
                        dismiss()
                    }
                }
            }.navigationTitle("Edit place")
        }
    }
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.name = location.name
        self.description = location.description
        self.location = location
        self.onSave = onSave
    }

    func fetchNearbyPlaces() async {
        let urlString =
            "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)

            let items = try JSONDecoder().decode(Result.self, from: data)

            pages = items.query.pages.values.sorted()

            loadingState = .loaded
        } catch {
            loadingState = .failed
        }

    }
}

#Preview {
    EditPlaceView(location: .example) { _ in }
}
