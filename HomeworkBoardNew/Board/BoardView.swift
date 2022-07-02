//
//  BoardView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 18/6/22.
//

import SwiftUI
import SwiftDate

struct BoardView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var daysFromToday = 0
    @State var date = ""
    
    @State var createEntry = false
    @State var index = 0
    @State var deleteEntry = false
    @State var showCache = false
    @State var dueDates: [String] = []
    
    @Binding var clas: Class
    @ObservedObject var CM: ClassManager
    let CCM = CacheManager()
    
    var member: Member
    
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
            
            List {
                if let entries = clas.board.entries[date] {
                    ForEach(entries) { entry in
                        Text(entry.entry)
                            .bold()
                            .swipeActions(edge: .trailing) {
                                Button("Create") {
                                    createEntry = true
                                    index = entries.firstIndex(of: entry)!
                                }
                                
                                Button("Delete") {
                                    Task {
                                        index = entries.firstIndex(of: entry)!
                                        clas.board.entries[date]![index].entry = " "
                                        clas.board.entries[date]![index].due = nil
                                        
                                        CCM.updateCache(clas: clas, did: "\(member.username) REMOVED ENTRY \(entries[index])")
                                        await CM.saveClass(clas: clas)
                                    }
                                }
                                .tint(.red)
                            }
                    }
                }
            }
        }
        .navigationTitle(clas.name)
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
        .onAppear {
            self.date = Date().toFormat("dd MMMM yyyy")
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
                        .foregroundColor(colorScheme == .light ? Color("murkyBlue") : Color("lightestBlue"))
                        .bold()
                }
                
                if member.perm == .admin || member.perm == .teacher {
                    Button {
                        showCache = true
                    } label: {
                        Text("Cache")
                            .foregroundColor(colorScheme == .light ? Color("murkyBlue") : Color("lightestBlue"))
                            .bold()
                    }
                }
            }
        }
        .onChange(of: daysFromToday) { newValue in
            Task {
                let tomorrow = Date().addingTimeInterval(TimeInterval(newValue * 86400))
                let date = tomorrow.toFormat("dd MMMM yyyy")
                self.date = date
                if clas.board.entries[date] == nil {
                    self.clas = await CM.createBoard(clas: clas, date: date)
                    await CM.getClass(name: clas.name)
                    
                }
            }
        }
    }
}


