//
//  FeedLoader.swift
//  EssentialFeedloader
//
//  Created by Ayaz Rahman on 27/5/21.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}


public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
