//
//  RemoteFeedLoader.swift
//  EssentialFeedLoader
//
//  Created by Ayaz Rahman on 2/6/21.
//

import Foundation

public enum HTTPClientResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

// Turn abstract classes into protocol
public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void){
        //avoid using shared replace with injection.
        
        client.get(from: url) { result in
            switch result {
            case .success:
                completion(.invalidData)
            case .failure:
                completion(.connectivity)
            }
            
        }
    }
}
