//
//  CarouselViewModel.swift
//  scriptBH
//
//  Created by Work on 04/07/2024.
//

import Foundation
import Combine

class CarouselViewModel {
    private(set) var images: [ImageModel] = []
    private var currentIndexSubject = CurrentValueSubject<Int, Never>(0)

    var currentIndexPublisher: AnyPublisher<Int, Never> {
        return currentIndexSubject.eraseToAnyPublisher()
    }

    func fetchImages(completion: @escaping (Result<Void, Error>) -> Void) {
        // Using local data for now
        self.images = [
            ImageModel(id: "1", imageName: "image1"),
            ImageModel(id: "2", imageName: "image2"),
            ImageModel(id: "3", imageName: "image3"),
            ImageModel(id: "4", imageName: "image4")
        ]
        completion(.success(()))
    }

    func updateCurrentIndex(_ index: Int) {
        currentIndexSubject.send(index)
    }
}
