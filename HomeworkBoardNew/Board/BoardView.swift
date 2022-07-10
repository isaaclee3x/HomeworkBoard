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
    
    @State var date = ""
    @State var daysFromToday = 0
    
    @State var createEntry = false
    @State var index = 0
    @State var deleteEntry = false
    @State var showCache = false
    @State var dueDates: [String] = []
    
    @Binding var clas: Class
    
    var pullDate: String
    
    @ObservedObject var CM: ClassManager
    @ObservedObject var SM: SubjectManager
    
    let BM: BoardManager
    let CCM = CacheManager()
    
    var member: Member
    
    var body: some View {
        VStack {
            
            ChangeDateView(date: $date, daysFromToday: $daysFromToday )
            
            EntriesView(date: date, member: member, clas: $clas, createEntry: $createEntry, index: $index, CM: CM, CCM: CCM)
        }
        .navigationTitle(clas.name)
        .onAppear {
            Task {
                self.date = Date().toFormat("dd MMMM yyyy")
                await CM.getClass(name: clas.name)
                await BM.cleanBoard(clas: clas)
            }
        }
        .sheet(isPresented: $createEntry) {
            Task {
                await CM.getClass(name: clas.name)
            }
        } content: {
            CreateEntryView(username: member.username ,date: date, index: index, isSheetPresented: $createEntry, clas: $clas, CM: CM, SM: SM)
        }
        .sheet(isPresented: $showCache) {
            CacheView(board: clas.board)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
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
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color("lightestBlue"))
                }
            }
        }
        .onChange(of: daysFromToday) { newValue in
            Task {
                let tomorrow = Date().addingTimeInterval(TimeInterval(newValue * 86400))
                let date = tomorrow.toFormat("dd MMMM yyyy")
                self.date = date
                if clas.board.entries[date] == nil {
                    self.clas = await BM.createBoard(clas: clas, date: date)
                    await CM.getClass(name: clas.name)
                    
                }
            }
        }
    }
}

struct ChangeDateView: View {
    
    @Binding var date: String
    @Binding var daysFromToday: Int
    
    var body: some View {
        VStack {
            Text(date)
                .font(.system(size: 25, design: .rounded))
                .bold()
            
            HStack {
                Button {
                    if daysFromToday > 0 {
                        daysFromToday -= 1
                    }
                } label: {
                    Text("Yesterday")
                        .font(.system(size: 15))
                        .bold()
                }
                
                Button {
                    daysFromToday += 1
                } label: {
                    Text("Tomorrow")
                        .font(.system(size: 15))
                        .bold()
                }
            }
        }
    }
}

struct EntriesView: View {
    
    var date: String
    var member: Member
    
    @Binding var clas: Class
    @Binding var createEntry: Bool
    @Binding var index: Int
    
    @ObservedObject var CM: ClassManager
    let CCM: CacheManager
    
    var body: some View {
        List {
            if let entries = clas.board.entries[date] {
                ForEach(entries) { entry in
                    HStack {
                        if let subject = entry.subject {
                            VStack {
                                Circle()
                                    .frame(width: 10)
                                    .foregroundColor(Color.init(red: subject.colour.r, green: subject.colour.g, blue: subject.colour.b))
                                
                                Text(subject.name)
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        Text(entry.entry)
                            .bold()
                    }
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
                                clas.board.entries[date]![index].subject = nil
                                
                                await CCM.updateCache(clas: clas, did: "\(member.username) REMOVED ENTRY \(entries[index])")
                                await CM.saveClass(clas: clas)
                            }
                        }
                        .tint(.red)
                    }
                }
            }
        }
    }
}
