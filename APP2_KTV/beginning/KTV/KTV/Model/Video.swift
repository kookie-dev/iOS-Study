//
//  Video.swift
//  KTV
//
//  Created by Choi Oliver on 2023/11/16.
//

import Foundation

struct Video: Decodable {
    
    let videoId: Int
    let videoURL: URL
    let title: String
    let uploadTimestamp: TimeInterval
    let playCount: Int
    let favoriteCount: Int
    let channelImageUrl: URL
    let channel: String
    let channelId: Int
    let recommends: [VideoListItem]
}
