//
//  InMemoryFeedStore.swift
//  FeedStoreChallenge
//
//  Created by slchen on 2020/1/17.
//  Copyright © 2020 Essential Developer. All rights reserved.
//

import Foundation

public class InMemoryFeedStore: FeedStore {

    private let queue = DispatchQueue(label: "\(type(of: InMemoryFeedStore.self))Queue", qos: .userInitiated, attributes: .concurrent)

    private var feed: [LocalFeedImage]?
    private var timestamp: Date?

    public init() { }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        queue.async { [weak self] in
            guard let self = self else { return }

            if let feed = self.feed, let timestamp = self.timestamp {
                completion(.found(feed: feed, timestamp: timestamp))
            }
            else {
                completion(.empty)
            }
        }
    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            self.feed = feed
            self.timestamp = timestamp
            completion(nil)
        }
    }

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            if self.feed != nil {
                self.feed = nil
            }
            if self.timestamp != nil {
                self.timestamp = nil
            }
            completion(nil)
        }
    }
}
