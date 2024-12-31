//
//  NetworkManager.swift
//  GitHubViewer
//
//  Created by Duong Pham on 30/12/24.
//

import Combine
import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(endpoint: EndpointType, responseType: T.Type) -> AnyPublisher<T, APIError>
}

class NetworkService: NetworkServiceProtocol {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func request<T: Decodable>(endpoint: EndpointType, responseType: T.Type) -> AnyPublisher<T, APIError> {
        let request = endpoint.urlRequest()
        
        return urlSession.dataTaskPublisher(for: request)
            .mapError { error in APIError.requestFailed(error) }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.unknown).eraseToAnyPublisher()
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    return Just(decodedData)
                        .setFailureType(to: APIError.self)
                        .eraseToAnyPublisher()
                } catch {
                    return Fail(error: APIError.decodingFailed(error)).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}


