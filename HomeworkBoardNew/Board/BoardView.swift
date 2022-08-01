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
    
    @Binding var date: String
    @Binding var subjects: [Subject]
    @State var daysFromToday = 0
    
    @State var createEntry = false
    @State var index = 0
    @State var deleteEntry = false
    @State var dueDates: [String] = []
    
    @Binding var clas: Class
    
    var CM: ClassManager
    var SM: SubjectManager
    
    let BM: BoardManager
    
    var member: Member
    
    var body: some View {
        VStack {
            ChangeDateView(date: $date, daysFromToday: $daysFromToday)
                
            Spacer()
            
            EntriesView(date: date, member: member, clas: $clas, createEntry: $createEntry, index: $index, CM: CM)
        }
        .background(color: colorScheme == .dark ? "murkyBlue" : "lightestBlue")
        .navigationTitle(clas.name)
        .onAppear {
            Task {
                await BM.cleanBoard(clas: clas)
            }
        }
        .toolbar() {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    createEntry = true
                } label: {
                    Text("Add Entry")
                        .bold()
                        .foregroundColor(.black)
                }
            }
        }
        .sheet(isPresented: $createEntry) {
            CreateEntryView(username: member.name, index: index, isSheetPresented: $createEntry, clas: $clas, subjects: $subjects, CM: CM, SM: SM)
        }
        .onAppear {
            clas.board.entries[date] = []
        }
        .onChange(of: daysFromToday) { newValue in
            let dateFormatter = DateFormatter()
            dateFormatter.locale = .current
            dateFormatter.dateFormat = "dd MMM yyyy"
            date = dateFormatter.string(from: Date().addingTimeInterval(Double(newValue*86400)))
            if clas.board.entries[date] == nil {
                clas.board.entries[date] = []
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
                    if daysFromToday > 1 {
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
    
    var CM: ClassManager
    
    var body: some View {
        if let entries = clas.board.entries[date] {
            if !entries.isEmpty {
                List {
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
                            
                            Spacer()
                            
                            Text(entry.author)
                                .italic()
                                .font(.system(size: 10))
                        }
                        .swipeActions(edge: .trailing) {
                            Button("Delete") {
                                Task {
                                    index = entries.firstIndex(of: entry)!
                                    clas.board.entries[date] = nil
                                    
                                    await CM.saveClass(clas: clas)
                                }
                            }
                            .tint(.red)
                        }
                    }
                }
            } else {
                Text("There is no homework today")
                    .foregroundColor(.gray)
                    .font(.system(size: 15))
            }
        }
    }
}
