//
//  ListViewModel.swift
//  scriptBH
//
//  Created by Work on 04/07/2024.
//

import Foundation
import Combine

protocol ListViewModelDelegate: AnyObject {
    func showSkeleton()
    func hideSkeleton()
}

class ListViewModel {
    
    // MARK: - Properties
    
    weak var delegate: ListViewModelDelegate?
    private(set) var items: [ListItemModel] = []
    private var cancellables = Set<AnyCancellable>()
    
    var filteredItemsPublisher = CurrentValueSubject<[ListItemModel], Never>([])
    private var currentIndex = 0
    
    // Static data
    private let staticData: [Int: [ListItemModel]] = [
        0: (1...20).map { ListItemModel(id: "\($0)", label: "List 0 - Item \($0)") },
        1: (1...40).map { ListItemModel(id: "\($0)", label: "List 1 - Item \($0)") },
        2: (1...3).map { ListItemModel(id: "\($0)", label: "List 2 - Item \($0)") },
        3: (1...32).map { ListItemModel(id: "\($0)", label: "List 3 - Item \($0)") }
    ]
    
    // MARK: - Fetch Data
    /*
    // Uncomment to fetch items from API
    func fetchData() {
        delegate?.showSkeleton() // Notify delegate to show skeleton loading state
        
        // Simulate API call or use real endpoint
        let endpoint = "https://api.example.com/items"
        API.fetchData(from: endpoint) { [weak self] (result: Result<[ListItemModel], Error>) in
            guard let self = self else { return }
            
            self.delegate?.hideSkeleton() // Hide skeleton loading state
            
            switch result {
            case .success(let fetchedItems):
                self.items = fetchedItems
                self.filteredItemsPublisher.send(fetchedItems)
            case .failure(let error):
                print("Failed to fetch data: \(error)")
                // Handle error gracefully, possibly retry or show an alert
            }
        }
    }*/
    
    /// Fetches items based on the specified index.
    /// - Parameter index: The index to fetch items for.
    func fetchItems(forIndex index: Int) {
        currentIndex = index
        
        // Fetch static content
        if let staticItems = staticData[index] {
            items = staticItems
            filteredItemsPublisher.send(staticItems)
        }
        
        // Uncomment to fetch items from API
        // fetchData()
    }
    
    /// Filters items based on the provided search text.
    ///
    /// - Parameter searchText: The text to filter items with.
    func filterItems(with searchText: String) {
        if searchText.isEmpty {
            filteredItemsPublisher.send(items) // Send all items if search text is empty
        } else {
            let filteredItems = items.filter { $0.label.contains(searchText) }
            filteredItemsPublisher.send(filteredItems) // Send filtered items
        }
    }
}
