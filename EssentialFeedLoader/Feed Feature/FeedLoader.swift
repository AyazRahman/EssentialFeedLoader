//
//  FeedLoader.swift
//  EssentialFeedloader
//
//  Created by Ayaz Rahman on 27/5/21.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
