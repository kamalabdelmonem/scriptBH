//
//  CarouselViewModelTests.swift
//  scriptBHTests
//
//  Created by Work on 06/07/2024.
//

import XCTest
import Combine
@testable import scriptBH

class CarouselViewModelTests: XCTestCase {
    
    // MARK: - Properties
    
    var viewModel: CarouselViewModel!
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Setup / Teardown
    
    override func setUp() {
        super.setUp()
        viewModel = CarouselViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Test Cases
    
    func testFetchStaticImages() {
        // When
        viewModel.fetchImages { result in
            // Then
            switch result {
            case .success:
                XCTAssertEqual(self.viewModel.images.count, 4, "Expected 4 images to be fetched statically")
                XCTAssertNotNil(self.viewModel.images.first { $0.imageName == "image1" }, "Expected 'image1' to be in the fetched images")
            case .failure(let error):
                XCTFail("Fetching static images failed with error: \(error.localizedDescription)")
            }
        }
    }
    
    func testUpdateCurrentIndex() {
        // Given
        let newIndex = 2
        
        // When
        viewModel.updateCurrentIndex(newIndex)
        
        // Then
        viewModel.currentIndexPublisher
            .sink { currentIndex in
                XCTAssertEqual(currentIndex, newIndex, "Expected current index to be updated to \(newIndex)")
            }
            .store(in: &cancellables)
    }
    
}
