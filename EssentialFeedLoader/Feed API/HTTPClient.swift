//
//  HTTPClient.swift
//  EssentialFeedLoader
//
//  Created by Ayaz Rahman on 24/6/21.
//

import Foundation


import Foundation

public enum HTTPClientResult{
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

// Turn abstract classes into protocol
public protocol HTTPClient{
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
