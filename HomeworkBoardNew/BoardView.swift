//
//  BoardView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct BoardView: View {
    
    @State var daysFromToday: Double = 0
    @State var date = ""
    
    @State var createEntry = false
    @State var index = 0
    @State var deleteEntry = false
    
    @Binding var clas: Class
    @ObservedObject var CM: ClassManager
    
    let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack {
            
            Text(date)
            HStack {
                Button {
                    if daysFromToday > 0 {
                        daysFromToday -= 1
                    }
                } label: {
                    Text("Yesterday")
                }
                
                Button {
                    daysFromToday += 1
                } label: {
                    Text("Tomorrow")
                }
            }
            
            if let entries = clas.board.entries[date] {
                List {
                    ForEach(entries) { entry in
                        Text(entry.entry)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    createEntry = true
                                    index = entries.firstIndex(of: entry)!
                                } label: {
                                    Text("Create")
                                }
                                
                                Button {
                                    index = entries.firstIndex(of: entry)!
                                    clas.board.entries[date]![index].entry = " "
                                    CM.saveClass(clas: clas)
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                    }
                }
            }
        }
        .navigationTitle(clas.name)
        .onAppear {
            dateFormatter.dateFormat = "dd MMMM yyyy"
            date = dateFormatter.string(from: Date().addingTimeInterval(daysFromToday * 86400))
        }
        .sheet(isPresented: $createEntry) {
            Task {
                await CM.getClass(name: clas.name)
            }
        } content: {
            CreateEntryView(date: date, index: index, isSheetPresented: $createEntry, clas: $clas, CM: CM)
        }
        .onChange(of: daysFromToday) { newValue in
            Task {
                date = dateFormatter.string(from: Date().addingTimeInterval(daysFromToday * 86400))
                if clas.board.entries[date] == nil {
                    await CM.createBoard(clas: clas, date: date)
                    try await Task.sleep(nanoseconds: 100_000)
                }
            }
        }
    }
}
