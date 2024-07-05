//
//  NetworkLayer.swift
//  scriptBH
//
//  Created by Work on 05/07/2024.
//

import Foundation

// MARK: - Network Error Enumeration
enum NetworkError: Error {
    case invalidURL
    case requestFailed
    // Add more error cases as needed
}

// MARK: - Network Manager
class NetworkManager {
    
    // MARK: - Singleton Instance
    static let shared = NetworkManager()
    
    // MARK: - Initializer
    private init() {}
    
    // MARK: - Fetch Method
    func fetch<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.requestFailed))
                return
            }
            
            do {
                let decodedObject = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(decodedObject))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
