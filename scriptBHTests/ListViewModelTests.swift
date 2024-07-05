//
//  ListViewModelTests.swift
//  scriptBHTests
//
//  Created by Work on 06/07/2024.
//

import XCTest
import Combine
@testable import scriptBH

class ListViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var viewModel: ListViewModel!
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        viewModel = ListViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testFetchItemsForIndex() {
        // Given
        let indexToFetch = 0
        
        // When
        viewModel.fetchItems(forIndex: indexToFetch)
        
        // Then
        let dynamicContent = viewModel.getDynamicContent()
        XCTAssertNotNil(dynamicContent)
        XCTAssertEqual(dynamicContent[indexToFetch]?.count, 20, "Expected 20 items in dynamic content for index \(indexToFetch)")
    }
    
    func testFilterItemsWithQuery() {
        // Given
        let indexToFetch = 0
        let filterQuery = "Item 10"
        
        // When
        viewModel.fetchItems(forIndex: indexToFetch)
        viewModel.filterItems(with: filterQuery)
        
        // Then
        viewModel.filteredItemsPublisher
            .sink { filteredItems in
                XCTAssertEqual(filteredItems.count, 1, "Expected 1 item in filtered list")
                XCTAssertEqual(filteredItems[0].label, "List \(indexToFetch) - \(filterQuery)", "Expected item label to match")
            }
            .store(in: &cancellables)
    }
}
