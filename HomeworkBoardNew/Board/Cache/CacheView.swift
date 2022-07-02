//
//  CacheView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 25/6/22.
//

import SwiftUI

struct CacheView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var board: Board
    
    var body: some View {
        VStack {
            if board.cache.isEmpty {
                Text("No items in the cache yet")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20))
                    .opacity(0.4)
            } else {
                ForEach(board.cache, id: \.self) { item in
                    Text(item)
                        .multilineTextAlignment(.leading)
                        .padding()
                }
            }
        }
        .frame(width: 350)
        .navigationTitle("Cache")
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
    }
}
