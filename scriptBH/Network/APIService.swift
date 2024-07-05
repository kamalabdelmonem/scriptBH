//
//  APIService.swift
//  scriptBH
//
//  Created by Work on 05/07/2024.
//

import Foundation

struct API {
    static func fetchData<T: Decodable>(from endpoint: String, completion: @escaping (Result<[T], Error>) -> Void) {
        let url = URL(string: endpoint)!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "com.example.app", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([T].self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
