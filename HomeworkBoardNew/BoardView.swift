//
//  BoardView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct BoardView: View {
    
    @State var daysFromToday: Double = 0
    
    @Binding var clas: Class
    
    @ObservedObject var CM: ClassManager
    
    let dateFormatter = DateFormatter()
    var date: String {
        dateFormatter.string(from: Date().addingTimeInterval(daysFromToday * 86400))
    }
    
    var body: some View {
        VStack {
            if let entries = clas.board.entries[date] {
                List {
                    ForEach(entries) { entry in
                        Text(entry.entry)
                    }
                }
            }
        }
        .onAppear {
            dateFormatter.dateFormat = "dd MMMM yyyy"
        }
    }
}
