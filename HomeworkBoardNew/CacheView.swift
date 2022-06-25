//
//  CacheView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 25/6/22.
//

import SwiftUI

struct CacheView: View {
    
    var board: Board
    
    var body: some View {
        VStack {
            Text("If you see this and you're not an admin or teacher.... errrr")
            
            if board.cache.isEmpty {
                Text("No items in the cache yet")
            } else {
                ForEach(board.cache, id: \.self) { item in
                    Text(item)
                }
            }
        }
        .navigationTitle("Cache")
    }
}
