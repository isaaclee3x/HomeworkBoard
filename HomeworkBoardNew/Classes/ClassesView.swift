//
//  ClassesView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 17/6/22.
//

import SwiftUI

struct ClassesView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var createClass = false
    @State var deleteClass = false
    @State var showSettings = false
    
    @State var classes = [Class(name: "", date: "")]
    @State var entriesWeek: [Entry] = []
    
    @Binding var success: Bool
    @Binding var chooseClassView: Bool
    
    @ObservedObject var MM: MemberManager
    @StateObject var CM = ClassManager()
    @StateObject var SM = SubjectManager()
    let BM = BoardManager()

    var body: some View {
        VStack {
            if MM.member?.perm == .member || MM.member?.perm == .subLeader {
                SummaryView(clas: $classes[0], CM: CM, SM: SM, BM: BM, member: MM.member!)
            }
            ShowClassesView(classes: $classes, CM: CM, MM: MM, SM: SM, BM: BM)
        }
        .onAppear {
            Task(priority: .high) {
                if MM.member?.perm == .admin || MM.member?.perm == .teacher {
                    await CM.getClasses()
                    classes = CM.classes ?? []
                } else {
                    await CM.getClass(name: MM.member!.clas)
                    classes = CM.classes ?? []
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if MM.member!.perm == .admin || MM.member!.perm == .teacher {
                        Button {
                            createClass = true
                        } label: {
                            Text("Create")
                                .foregroundColor(colorScheme == .light ? Color("murkyBlue") : Color("lightestBlue"))
                                .bold()
                        }
                        
                        Button {
                            deleteClass = true
                        } label: {
                            Text("Delete")
                                .foregroundColor(colorScheme == .light ? Color("murkyBlue") : Color("lightestBlue"))
                                .bold()
                        }
                    }
                    Button {
                        Task {
                            if MM.member?.perm == .admin || MM.member?.perm == .teacher {
                                await CM.getClasses()
                                classes = CM.classes ?? []
                            } else {
                                await CM.getClass(name: MM.member!.clas)
                                classes = CM.classes ?? []
                            }
                        }
                    } label: {
                        Text("Reload")
                            .foregroundColor(colorScheme == .light ? Color("murkyBlue") : Color("lightestBlue"))
                            .bold()
                    }
                    
                    Button {
                        success = false
                    } label: {
                        Text("Logout")
                            .foregroundColor(colorScheme == .light ? Color("murkyBlue") : Color("lightestBlue"))
                            .bold()
                    }
                    
                    Button {
                        showSettings = true
                    } label: {
                        Text("Settings")
                    }
                    
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color(colorScheme == .light ? "murkyBlue" : "lightestBlue"))
                }
                
            }
        }
        .navigationTitle(MM.member?.perm == .member || MM.member?.perm == .subLeader ? "Classes" : "Class")
        .sheet(isPresented: $createClass) {
            Task {
                await CM.getClasses()
                classes = CM.classes!
            }
        } content: {
            CreateClassView(CM: CM, isSheetPresented: $createClass)
        }
        .sheet(isPresented: $deleteClass) {
            Task {
                await CM.getClasses()
                classes = CM.classes ?? []
            }
        } content: {
            DeleteClassView(isSheetPresented: $deleteClass, CM: CM)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(MM: MM, CM: CM, SM: SM, member: MM.member!)
        }
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
        .onChange(of: MM.member?.clas) { newValue in
            if newValue == "" {
                success = false
                chooseClassView = false
            }
        }
    }
}

struct SummaryView: View {
    
    @Binding var clas: Class
    
    @ObservedObject var CM: ClassManager
    @ObservedObject var SM: SubjectManager
    
    @State var date = ""
    @State var entriesWeek: [Entry] = []
    @State var days = 1.0
    
    let BM: BoardManager
    var member: Member
    
    var body: some View {
        Rectangle()
            .foregroundColor(.black)
            .overlay {
                VStack {
                    HStack {
                        Text("Homework due in \(String(format: "%.0f", days)) days:")
                            .bold()
                            .frame(width: 50)
                            .font(.system(size: 9))
                        Slider(value: $days, in: 1...10, step: 1) {
                            Text("Due in \(days) days")
                        } minimumValueLabel: {
                            Text("1")
                                .bold()
                        } maximumValueLabel: {
                            Text("10")
                                .bold()
                        } onEditingChanged: { value in
                            Task {
                                entriesWeek = BM.homeworkDue(clas: clas, in: Int(days))
                            }
                        }
                        .frame(width: 200)
                    }
                    .offset(y: 10)
                    
                    if entriesWeek != [] {
                        List {
                            ForEach(entriesWeek) { entry in
                                NavigationLink {
                                    BoardView(date: $date, clas: $clas, CM: CM, SM: SM, BM: BM, member: member)
                                } label: {
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
                                        
                                        VStack {
                                            Text(entry.entry)
                                                .bold()
                                            if entry.due != nil {
                                                Text(entry.due!)
                                                    .italic()
                                                    .font(.system(size: 10))
                                                    .foregroundColor(.gray)
                                                    .opacity(0.7)
                                            }
                                        }
                                        .frame(alignment: .leading)
                                    }
                                }
                            }
                        }
                    } else {
                        Text("There are no entries due")
                            .foregroundColor(Color("lightestBlue"))
                            .bold()
                    }
                }
            }
            .frame(width: 350, height: 300)
            .cornerRadius(10)
            .padding()
            .onAppear {
                entriesWeek = BM.homeworkDue(clas: clas, in: Int(days))
            }
    }
}

struct ShowClassesView: View {
    
    @State var date = ""
    
    @Binding var classes: [Class]
    
    @ObservedObject var CM: ClassManager
    @ObservedObject var MM: MemberManager
    @ObservedObject var SM: SubjectManager
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let BM: BoardManager
    
    var body: some View {
        if classes.isEmpty {
            Text("No Classes Yet")
                .frame(maxWidth: 400)
                .opacity(0.4)
            
        } else {
            if MM.member != nil {
                LazyVGrid(columns: columns) {
                    ForEach($classes) { $clas in
                        NavigationLink {
                            BoardView(date: $date, clas: $clas, CM: CM, SM: SM, BM: BM, member: MM.member!)
                        } label: {
                            Text(clas.name)
                                .bold()
                                .blockDisplay()
                        }
                    }
                }
                .onAppear {
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = .current
                    dateFormatter.dateFormat = "dd MMMM yyyy"
                    date = dateFormatter.string(from: Date().addingTimeInterval(86400))
                }
            }
        }
    }
}
