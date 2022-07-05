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
    
    @State var classes = [Class(name: "", date: "")]
    @State var entriesWeek: [Entry] = []
    
    @Binding var success: Bool
    
    @ObservedObject var MM: MemberManager
    @StateObject var CM = ClassManager()
    @StateObject var BM = BoardManager()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if MM.member?.perm == .member || MM.member?.perm == .subLeader {
                Rectangle()
                    .frame(width: 350, height: 300)
                    .foregroundColor(.black)
                    .overlay {
                        VStack {
                            
                            Spacer()
                                .frame(height: 15)
                            
                            Text("Summary")
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 300, alignment: .leading)
                                .offset(y: 10)
                                .font(.system(size: 30))
                                .padding()
                            
                            List {
                                ForEach(entriesWeek) { entry in
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
                                    }.frame(alignment: .leading)
                                }
                            }
                        }
                        .frame(height: 350)
                    }
                    .cornerRadius(10)
                    .padding()
            }
            
            LazyVGrid(columns: columns) {
                if classes.isEmpty {
                    Text("No Classes Yet")
                        .frame(maxWidth: 400)
                        .opacity(0.4)
                    
                } else {
                    ForEach($classes) { $clas in
                        NavigationLink {
                            BoardView(clas: $clas, CM: CM, member: MM.member!, BM: BM)
                        } label: {
                            Text(clas.name)
                                .blockDisplay()
                        }
                    }
                }
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
                ToolbarItemGroup {
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
        }
    }
}
