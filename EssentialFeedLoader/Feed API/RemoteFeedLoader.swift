//
//  RemoteFeedLoader.swift
//  EssentialFeedLoader
//
//  Created by Ayaz Rahman on 2/6/21.
//

import Foundation

// Turn abstract classes into protocol
public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (Error) -> Void)
}

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> Void = { _ in }){
        //avoid using shared replace with injection.
        
        client.get(from: url) { error in
            completion(.connectivity)
        }
    }
}