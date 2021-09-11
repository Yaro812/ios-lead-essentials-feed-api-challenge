//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}

	public func load(completion: @escaping (FeedLoader.Result) -> Void) {
		client.get(from: url) { result in
			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					return completion(.failure(RemoteFeedLoader.Error.invalidData))
				}

				do {
					let feedResult = try JSONDecoder().decode(FeedResult.self, from: data)
					let feedImages = feedResult.items.map { FeedImage($0) }
					completion(.success(feedImages))
				} catch {
					completion(.failure(RemoteFeedLoader.Error.invalidData))
				}
			case let .failure(error):
				completion(.failure(RemoteFeedLoader.Error.connectivity))
			}
		}
	}
}
