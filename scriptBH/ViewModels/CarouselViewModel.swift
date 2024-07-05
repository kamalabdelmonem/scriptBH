//
//  CarouselViewModel.swift
//  scriptBH
//
//  Created by Work on 04/07/2024.
//

import Foundation
import Combine

class CarouselViewModel {
    fileprivate(set) var images: [ImageModel] = []
    private var currentIndexSubject = CurrentValueSubject<Int, Never>(0)

    var currentIndexPublisher: AnyPublisher<Int, Never> {
        return currentIndexSubject.eraseToAnyPublisher()
    }

    // Example function to fetch static images (default)
    func fetchStaticImages() {
        self.images = [
            ImageModel(id: "1", imageName: "image1"),
            ImageModel(id: "2", imageName: "image2"),
            ImageModel(id: "3", imageName: "image3"),
            ImageModel(id: "4", imageName: "image4")
        ]
    }

    // Function to fetch images from API
    func fetchImages(completion: @escaping (Result<Void, Error>) -> Void) {
        fetchStaticImages()

        // Uncomment the following block to fetch images from API
        /*
        API.fetchData(from: "https://api.example.com/images") { [weak self] (result: Result<[ImageModel], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let images):
                self.images = images
                completion(.success(()))
            case .failure(let error):
                print("Error fetching images: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        */
        
        // For now, fetch static images as a placeholder
        completion(.success(()))
    }

    func updateCurrentIndex(_ index: Int) {
        currentIndexSubject.send(index)
    }
}
