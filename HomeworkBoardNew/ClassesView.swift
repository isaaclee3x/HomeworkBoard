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
    
    @State var clas = Class(name: "", date: "")
    @State var classes = [Class(name: "", date: "")]
    
    @ObservedObject var MM: AccountManager
    @StateObject var CM = ClassManager()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            if MM.account?.perm == .member || MM.account?.perm == .subLeader {
                NavigationLink {
                    BoardView(clas: $clas, CM: CM)
                } label: {
                    Text((MM.account?.clas) ?? "")
                }
                
                
            } else {
                ForEach($classes) { $clas in
                    NavigationLink {
                        BoardView(clas: $clas, CM: CM)
                    } label: {
                        Text(clas.name)
                    }
                }
                
            }
        }
        .onAppear {
            Task {
                await CM.getClasses()
                classes = CM.classes!
                await CM.getClass(name: MM.account!.clas)
                clas = CM.classes![0]
                
            }
        }
        .toolbar {
            ToolbarItemGroup {
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
            }
        }
        .navigationTitle(MM.account?.perm == .member || MM.account?.perm == .subLeader ? "Class" : "Classes")
        .sheet(isPresented: $createClass) {
            CreateClassView(CM: CM, isSheetPresented: $createClass)
        }
        .sheet(isPresented: $deleteClass) {
            DeleteClassView(CM: CM)
        }
    }
}
