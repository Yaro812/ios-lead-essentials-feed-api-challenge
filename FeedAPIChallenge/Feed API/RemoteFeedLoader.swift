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
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					return completion(.failure(Error.invalidData))
				}

				completion(Result { try self.feedImages(from: data) })

			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private func feedImages(from data: Data) throws -> [FeedImage] {
		guard let feedResult = try? JSONDecoder().decode(FeedResult.self, from: data) else {
			throw Error.invalidData
		}
		return feedResult.items.map { FeedImage($0) }
	}
}
