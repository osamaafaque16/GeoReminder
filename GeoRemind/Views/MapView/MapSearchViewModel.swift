//
//  MapSearchViewModel.swift
//  GeoRemind
//
//  Created by Osama Afaque on 12/19/25.
//

import Combine
import MapKit

class MapSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [MKMapItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                guard !newValue.isEmpty else {
                    self?.results = []
                    return
                }
                self?.performSearch(query: newValue)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let response = response, error == nil else {
                print("Search error: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            DispatchQueue.main.async {
                print("SEARCHED ITEM = \(response.mapItems)")
                self?.results = response.mapItems
            }
        }
    }
}

