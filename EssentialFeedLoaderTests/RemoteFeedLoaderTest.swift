//
//  RemoteFeedLoaderTest.swift
//  EssentialFeedLoaderTests
//
//  Created by Ayaz Rahman on 27/5/21.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient{
    var requestedURL: URL?
}


class RemoteFeedLoaderTests: XCTestCase{
    
    func test_init_doesNotRequestDataFromURL(){
        
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
