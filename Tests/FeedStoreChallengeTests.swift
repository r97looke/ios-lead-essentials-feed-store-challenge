//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import XCTest
import FeedStoreChallenge

class InMemoryFeedStore: FeedStore {

    let queue = DispatchQueue(label: "\(type(of: InMemoryFeedStore.self))Queue", qos: .userInitiated, attributes: .concurrent)

    var feed: [LocalFeedImage]?
    var timestamp: Date?

    func retrieve(completion: @escaping RetrievalCompletion) {
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

    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }

            self.feed = feed
            self.timestamp = timestamp
            completion(nil)
        }
    }

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
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

class FeedStoreChallengeTests: XCTestCase, FeedStoreSpecs {
	
//
//   We recommend you to implement one test at a time.
//   Uncomment the test implementations one by one.
// 	 Follow the process: Make the test pass, commit, and move to the next one.
//

	func test_retrieve_deliversEmptyOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
	}

	func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_insert_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_insert_overridesPreviouslyInsertedCacheValues() {
		let sut = makeSUT()

		assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
	}

	func test_delete_deliversNoErrorOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
	}

	func test_delete_hasNoSideEffectsOnEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
	}

	func test_delete_deliversNoErrorOnNonEmptyCache() {
		let sut = makeSUT()

		assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
	}

	func test_delete_emptiesPreviouslyInsertedCache() {
		let sut = makeSUT()

		assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
	}

	func test_storeSideEffects_runSerially() {
		let sut = makeSUT()

		assertThatSideEffectsRunSerially(on: sut)
	}

    func test_retrieve_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        var sut: FeedStore? = makeSUT()

        sut?.retrieve(completion: { (result) in
            XCTAssertNil(result, "Expected no completion callback for retrieve after feedstore has been deallocated")
        })

        sut = nil
    }

    func test_insert_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        var sut: FeedStore? = makeSUT()

        sut?.insert(uniqueImageFeed(), timestamp: Date(), completion: { _ in
            XCTFail("Expected no completion callback for insert after feed store has been deallocated")
        })

        sut = nil
    }

    func test_delete_doesNotDeliverResultAfterInstanceHasBeenDeallocated() {
        var sut: FeedStore? = makeSUT()

        sut?.deleteCachedFeed(completion: { _ in
            XCTFail("Expected no completion callback for delete after feed store has been deallocated")
        })

        sut = nil
    }
	// - MARK: Helpers
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = InMemoryFeedStore()
        trackForMemoryLeak(sut, file: file, line: line)
        return sut
	}

    private func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Expect instance be deallocated after each test, got memory leak instead", file: file, line: line)
        }
    }
	
}

//
// Uncomment the following tests if your implementation has failable operations.
// Otherwise, delete the commented out code!
//

//extension FeedStoreChallengeTests: FailableRetrieveFeedStoreSpecs {
//
//	func test_retrieve_deliversFailureOnRetrievalError() {
////		let sut = makeSUT()
////
////		assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
//	}
//
//	func test_retrieve_hasNoSideEffectsOnFailure() {
////		let sut = makeSUT()
////
////		assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableInsertFeedStoreSpecs {
//
//	func test_insert_deliversErrorOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertDeliversErrorOnInsertionError(on: sut)
//	}
//
//	func test_insert_hasNoSideEffectsOnInsertionError() {
////		let sut = makeSUT()
////
////		assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
//	}
//
//}

//extension FeedStoreChallengeTests: FailableDeleteFeedStoreSpecs {
//
//	func test_delete_deliversErrorOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteDeliversErrorOnDeletionError(on: sut)
//	}
//
//	func test_delete_hasNoSideEffectsOnDeletionError() {
////		let sut = makeSUT()
////
////		assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
//	}
//
//}
