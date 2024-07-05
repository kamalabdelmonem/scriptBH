//
//  ListViewModel.swift
//  scriptBH
//
//  Created by Work on 04/07/2024.
//

import Foundation
import Combine

class ListViewModel {
    
    // MARK: - Properties
    internal var dynamicContent: [Int: [ListItemModel]] = [
        0: (1...20).map { ListItemModel(id: "\($0)", label: "List 0 - Item \($0)") },
        1: (1...40).map { ListItemModel(id: "\($0)", label: "List 1 - Item \($0)") },
        2: (1...14).map { ListItemModel(id: "\($0)", label: "List 2 - Item \($0)") },
        3: (1...32).map { ListItemModel(id: "\($0)", label: "List 3 - Item \($0)") }
        // Add more indexes and items as needed
    ]
    private var filteredItemsSubject = CurrentValueSubject<[ListItemModel], Never>([])
    private var currentCarouselIndex: Int = 0
    
    var filteredItemsPublisher: AnyPublisher<[ListItemModel], Never> {
        return filteredItemsSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Public Methods
    // Expose for testing
    func getDynamicContent() -> [Int: [ListItemModel]] {
        return dynamicContent
    }


    func fetchItems(forIndex index: Int) {
        fetchStaticContent(forIndex: index)
        
        // Uncomment to fetch items from API
        /*
        fetchItemsFromAPI(forIndex: index)
        */
    }
    
    func filterItems(with query: String) {
        guard let currentItems = dynamicContent[currentCarouselIndex] else {
            filteredItemsSubject.send([])
            return
        }
        let filtered = query.isEmpty ? currentItems : currentItems.filter { $0.label.lowercased().contains(query.lowercased()) }
        filteredItemsSubject.send(filtered)
    }
    
    // MARK: - Private Methods
    private func fetchStaticContent(forIndex index: Int) {
        guard let items = dynamicContent[index] else {
            filteredItemsSubject.send([])
            return
        }
        currentCarouselIndex = index
        filteredItemsSubject.send(items)
    }
    
    /*
    private func fetchItemsFromAPI(forIndex index: Int) {
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
    }
    */
}
