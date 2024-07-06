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
    
    /// Fetches data from a specified endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: The URL string representing the API endpoint.
    ///   - completion: Completion handler returning a result of type `[T]` or an `Error`.
    static func fetchData<T: Decodable>(from endpoint: String, completion: @escaping (Result<[T], Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
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
                    completion(.failure(NetworkError.decodingFailed))
                }
            }
        }.resume()
    }
}
