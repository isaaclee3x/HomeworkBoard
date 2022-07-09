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
    
    @ObservedObject var MM: MemberManager
    @StateObject var CM = ClassManager()
    @StateObject var SM = SubjectManager()
    let BM = BoardManager()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if MM.member?.perm == .member || MM.member?.perm == .subLeader {
                SummaryView(entriesWeek: entriesWeek)
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
                    entriesWeek = BM.homeworkForTheWeek(clas: classes[0])
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
                                entriesWeek = BM.homeworkForTheWeek(clas: classes[0])
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
        .navigationTitle(MM.member?.perm == .member || MM.member?.perm == .subLeader ? "Class" : "Classes")
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
            SettingsView(MM: MM, CM: CM, SM: SM)
        }
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
    }
}

struct SummaryView: View {
    
    var entriesWeek: [Entry]
    
    var body: some View {
        Rectangle()
            .foregroundColor(.black)
            .overlay {
                List {
                    ForEach(entriesWeek) { entry in
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
            .frame(width: 350, height: 300)
            .cornerRadius(10)
            .padding()
    }
}

struct ShowClassesView: View {
    
    @Binding var classes: [Class]
    
    @ObservedObject var CM: ClassManager
    @ObservedObject var MM: MemberManager
    @ObservedObject var SM: SubjectManager
    let BM: BoardManager
    
    var body: some View {
        if classes.isEmpty {
            Text("No Classes Yet")
                .frame(maxWidth: 400)
                .opacity(0.4)
            
        } else {
            ForEach($classes) { $clas in
                NavigationLink {
                    BoardView(clas: $clas, CM: CM, SM: SM, BM: BM, member: MM.member!)
                } label: {
                    Text(clas.name)
                        .blockDisplay()
                }
            }
        }
    }
}
