//
//  APIService.swift
//  scriptBH
//
//  Created by Work on 05/07/2024.
//

import Foundation

// MARK: - API Service
struct API {
    
    // MARK: - Fetch Data Method
    static func fetchData<T: Decodable>(from endpoint: String, completion: @escaping (Result<[T], Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed))
                }
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([T].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedData))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
