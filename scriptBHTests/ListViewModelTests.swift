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
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testFetchItemsForIndex() {
        // Given
        let indexToFetch = 0
        let expectedItemCount = 20
        let expectation = self.expectation(description: "Fetch items for index")
        
        // When
        viewModel.fetchItems(forIndex: indexToFetch)
        
        // Then
        viewModel.filteredItemsPublisher
            .sink { items in
                XCTAssertEqual(items.count, expectedItemCount, "Expected \(expectedItemCount) items for index \(indexToFetch)")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFilterItemsWithQuery() {
        // Given
        let indexToFetch = 0
        let filterQuery = "Item 10"
        let expectation = self.expectation(description: "Filter items with query")
        
        // When
        viewModel.fetchItems(forIndex: indexToFetch)
        viewModel.filterItems(with: filterQuery)
        
        // Then
        viewModel.filteredItemsPublisher
            .sink { filteredItems in
                XCTAssertEqual(filteredItems.count, 1, "Expected 1 item in filtered list")
                XCTAssertEqual(filteredItems.first?.label, "List \(indexToFetch) - \(filterQuery)", "Expected item label to match")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
