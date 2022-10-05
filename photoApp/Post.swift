//
//  Post.swift
//  photoApp
//
//  Created by 백찬우 on 2022/09/19.
//

import Foundation

struct Storage: Codable, Hashable, Identifiable {
    let id: Int
    var title: String
    var document: String
}
