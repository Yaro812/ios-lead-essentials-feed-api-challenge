//
//  FeedResult.swift
//  FeedAPIChallenge
//
//  Created by Yaroslav Pasternak on 11.09.2021.
//  Copyright © 2021 Essential Developer Ltd. All rights reserved.
//

import Foundation

struct FeedResult: Decodable {
	struct FeedImage: Decodable {
		private enum CodingKeys: String, CodingKey {
			case id = "image_id"
			case description = "image_desc"
			case location = "image_loc"
			case url = "image_url"
		}

		let id: UUID
		let description: String?
		let location: String?
		let url: URL
	}

	let items: [FeedResult.FeedImage]
}

extension FeedImage {
	init(_ feedImage: FeedResult.FeedImage) {
		self.id = feedImage.id
		self.description = feedImage.description
		self.location = feedImage.location
		self.url = feedImage.url
	}
}
