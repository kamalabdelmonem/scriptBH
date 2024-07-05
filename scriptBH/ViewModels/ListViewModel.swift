//
//  ListViewModel.swift
//  scriptBH
//
//  Created by Work on 04/07/2024.
//

import Foundation
import Combine

class ListViewModel {
    private var dynamicContent: [Int: [ListItemModel]] = [
        0: (1...20).map { ListItemModel(id: "\($0)", label: "List 0 - Item \($0)") },
        1: (1...40).map { ListItemModel(id: "\($0)", label: "List 1 - Item \($0)") },
        2: (1...4).map { ListItemModel(id: "\($0)", label: "List 2 - Item \($0)") },
        3: (1...22).map { ListItemModel(id: "\($0)", label: "List 3 - Item \($0)") }
        // Add more indexes and items as needed
    ]
    private var filteredItemsSubject = CurrentValueSubject<[ListItemModel], Never>([])
    private var currentCarouselIndex: Int = 0
    
    var filteredItemsPublisher: AnyPublisher<[ListItemModel], Never> {
        return filteredItemsSubject.eraseToAnyPublisher()
    }
    
    func fetchItems(forIndex index: Int) {
        // Use dynamicContent for static data (default)
        guard let items = dynamicContent[index] else {
            self.filteredItemsSubject.send([])
            return
        }
        self.currentCarouselIndex = index
        self.filteredItemsSubject.send(items)
        
        // Uncomment to fetch items from API
        /*
        API.fetchList(forIndex: index) { [weak self] (result: Result<[ListItemModel], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let items):
                self.dynamicContent[index] = items
                self.currentCarouselIndex = index
                self.filteredItemsSubject.send(items)
            case .failure(let error):
                print("Error fetching items: \(error.localizedDescription)")
                self.filteredItemsSubject.send([])
            }
        }
        */
    }
    
    func filterItems(with query: String) {
        guard let currentItems = dynamicContent[currentCarouselIndex] else {
            filteredItemsSubject.send([])
            return
        }
        if query.isEmpty {
            filteredItemsSubject.send(currentItems)
        } else {
            let filtered = currentItems.filter { $0.label.lowercased().contains(query.lowercased()) }
            filteredItemsSubject.send(filtered)
        }
    }
}
