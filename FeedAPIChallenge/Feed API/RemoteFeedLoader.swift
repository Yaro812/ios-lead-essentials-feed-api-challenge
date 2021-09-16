//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
	enum Constants {
		static let okCode = 200
	}

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
				completion(RemoteFeedLoader.feedLoaderResult(from: data, response: response))

			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	private static func feedLoaderResult(from data: Data, response: HTTPURLResponse) -> FeedLoader.Result {
		guard
			response.statusCode == Constants.okCode,
			let feedResult = try? JSONDecoder().decode(FeedResult.self, from: data) else {
			return .failure(Error.invalidData)
		}

		return .success(feedResult.items.map { FeedImage($0) })
	}
}
