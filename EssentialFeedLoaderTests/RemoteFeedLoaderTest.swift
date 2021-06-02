//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedLoaderTests
//
//  Created by Ayaz Rahman on 27/5/21.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load(){
        //avoid using shared replace with injection.
        
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

// Turn abstract classes into protocol
protocol HTTPClient{
    func get(from url: URL)
}


class HTTPClientSpy: HTTPClient{
    func get(from url: URL) {
        requestedURL = url
    }
    
    var requestedURL: URL?
}


class RemoteFeedLoaderTests: XCTestCase{
    
    func test_init_doesNotRequestDataFromURL(){
        
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
