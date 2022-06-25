//
//  BoardView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI

struct BoardView: View {
    
    @State var daysFromToday = 0
    @State var date = ""
    
    @State var createEntry = false
    @State var index = 0
    @State var deleteEntry = false
    @State var showCache = false
    
    @Binding var clas: Class
    @ObservedObject var CM: ClassManager
    
    var member: Member
    
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
                        let due = dateFormatter.string(from: entry.due ?? Date().addingTimeInterval(-86400))
                        VStack {
                            Text(entry.entry)
                            
                            if dateFormatter.date(from: due)! > Date() {
                                Text(due)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                createEntry = true
                                index = entries.firstIndex(of: entry)!
                            } label: {
                                Text("Create")
                            }
                            
                            Button {
                                Task {
                                    index = entries.firstIndex(of: entry)!
                                    clas.board.entries[date]![index].entry = " "
                                    await CM.saveClass(clas: clas)
                                }
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
            Task {
                dateFormatter.locale = .current
                dateFormatter.dateFormat = "dd MMMM yyyy"
                self.date = dateFormatter.string(from: Date())
                
                await CM.getClass(name: clas.name)
            }
        }
        .sheet(isPresented: $createEntry) {
            Task {
                await CM.getClass(name: clas.name)
            }
        } content: {
            CreateEntryView(username: member.username ,date: date, index: index, isSheetPresented: $createEntry, clas: $clas, CM: CM)
        }
        .sheet(isPresented: $showCache) {
            CacheView(board: clas.board)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    Task { await CM.getClass(name: clas.name) }
                } label: {
                    Text("Reload")
                }
                
                if member.perm == .admin || member.perm == .teacher {
                    Button {
                        showCache = true
                    } label: {
                        Text("Cache")
                    }
                }
            }
        }
        .onChange(of: daysFromToday) { newValue in
            Task {
                dateFormatter.locale = .current
                dateFormatter.dateFormat = "dd MMMM yyyy"
                let tomorrow = Date().addingTimeInterval(TimeInterval(newValue * 86400))
                let date = dateFormatter.string(from: tomorrow)
                self.date = date
                if clas.board.entries[date] == nil {
                    self.clas = await CM.createBoard(clas: clas, date: date)
                    await CM.getClass(name: clas.name)
                    
                }
            }
        }
    }
}
