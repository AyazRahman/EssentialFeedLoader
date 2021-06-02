//
//  RemoteFeedLoader.swift
//  EssentialFeedLoader
//
//  Created by Ayaz Rahman on 2/6/21.
//

import Foundation

// Turn abstract classes into protocol
public protocol HTTPClient{
    func get(from url: URL)
}

public final class RemoteFeedLoader {
    let url: URL
    let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(){
        //avoid using shared replace with injection.
        
        client.get(from: url)
    }
}
