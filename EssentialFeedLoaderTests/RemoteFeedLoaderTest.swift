//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedLoaderTests
//
//  Created by Ayaz Rahman on 27/5/21.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load(){
        //avoid using shared replace with injection.
        
        client.get(from: url)
    }
}

// Turn abstract classes into protocol
protocol HTTPClient{
    func get(from url: URL)
}



class RemoteFeedLoaderTests: XCTestCase{
    
    func test_init_doesNotRequestDataFromURL(){
        
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }

    func test_load_requestDataFromURL(){
        let url = URL(string: "https://a-given-url.com")!
        
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient{
        
        var requestedURL: URL?
        
        func get(from url: URL) {
            requestedURL = url
        }

    }
    
}
