//
//  RemoteFeedLoader.swift
//  EssentialFeedLoader
//
//  Created by Ayaz Rahman on 2/6/21.
//


public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void){
        //avoid using shared replace with injection.
        
        client.get(from: url) { result in
            switch result {
            case let .success(data, response):
                completion(FeedItemsMapper.map(data, from: response))
                
            case .failure:
                completion(.failure(.connectivity))
            }
            
        }
    }
    
    
}



