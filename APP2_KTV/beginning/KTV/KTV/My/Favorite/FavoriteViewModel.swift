//
//  FavoriteViewModel.swift
//  KTV
//
//  Created by Choi Oliver on 2023/11/14.
//

import Foundation

@MainActor class FavoriteViewModel {
    private(set) var favorite: Favorite?
    var dataChanged: (() -> Void)?
    
    init(
        favorite: Favorite? = nil,
        dataChanged: (() -> Void)? = nil
    ) {
        self.favorite = favorite
        self.dataChanged = dataChanged
    }
    
    func requestData() {
        Task {
            do {
                let favorite = try await DataLoader.load(url: URLDefines.favorite, for: Favorite.self)
                self.favorite = favorite
                self.dataChanged?()
            } catch {
                print("‼️ data load failed: \(error.localizedDescription)")
            }
        }
    }
}
