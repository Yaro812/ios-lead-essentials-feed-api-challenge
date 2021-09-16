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
			guard let self = self else { return }

			switch result {
			case let .success((data, response)):
				guard response.statusCode == 200 else {
					return completion(.failure(Error.invalidData))
				}

				do {
					let feedImages = try self.feedImages(from: data)
					completion(.success(feedImages))
				} catch {
					completion(.failure(Error.invalidData))
				}

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
