//
//  ClassesView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 17/6/22.
//

import SwiftUI

struct ClassesView: View {
    
    @State var createClass = false
    @State var deleteClass = false
    
    @State var classes = [Class(name: "", date: "")]
    
    @ObservedObject var MM: AccountManager
    @StateObject var CM = ClassManager()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            if classes.isEmpty {
                Text("Either there are no classes or something terrible happened")
            } else {
                ForEach($classes) { $clas in
                    NavigationLink {
                        BoardView(clas: $clas, CM: CM, member: MM.account!)
                    } label: {
                        Text(clas.name)
                    }
                }
            }
        }
        .onAppear {
            Task {
                if MM.account?.perm == .admin || MM.account?.perm == .teacher {
                    await CM.getClasses()
                    classes = CM.classes ?? []
                } else {
                    await CM.getClass(name: MM.account!.clas)
                    classes = CM.classes ?? []
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    createClass = true
                } label: {
                    Text("Create")
                }
                
                Button {
                    deleteClass = true
                } label: {
                    Text("Delete")
                }
                
                Button {
                    Task {
                        if MM.account?.perm == .admin || MM.account?.perm == .teacher {
                            await CM.getClasses()
                            classes = CM.classes ?? []
                        } else {
                            await CM.getClass(name: MM.account!.clas)
                            classes = CM.classes ?? []
                        }
                    }
                } label: {
                    Text("Reload")
                }

            }
        }
        .navigationTitle(MM.account?.perm == .member || MM.account?.perm == .subLeader ? "Class" : "Classes")
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
                classes = CM.classes!
            }
        } content: {
            DeleteClassView(isSheetPresented: $deleteClass, CM: CM)
        }
    }
}
