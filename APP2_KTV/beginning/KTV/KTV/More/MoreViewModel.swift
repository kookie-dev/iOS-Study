//
//  MoreViewModel.swift
//  KTV
//
//  Created by Choi Oliver on 2023/11/16.
//

import Foundation

struct MoreViewModel {
    let items: [MoreItem] = [
        .init(title: "화질 변경", rightText: "자동 720"),
        .init(title: "자동 재생", rightText: "On"),
        .init(title: "공유하기", rightText: nil),
        .init(title: "신고하기", rightText: nil),
    ]
}

struct MoreItem {
    let title: String
    let rightText: String?
}
