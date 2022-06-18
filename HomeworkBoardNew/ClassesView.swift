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
    
    @ObservedObject var MM: AccountManager
    @StateObject var CM = ClassManager()
    
    let columns = [
           GridItem(.flexible()),
           GridItem(.flexible())
       ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            if MM.account?.perm == .member || MM.account?.perm == .subLeader {
                Text(MM.account!.clas)
            } else {
                if let classes = CM.classes {
                    ForEach(classes) { clas in
                        Text(clas.name)
                    }
                }
            }
        }
        .onAppear {
            Task {
                await CM.getClasses()
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
            
        }
    }
}

struct ClassesView_Previews: PreviewProvider {
    static var previews: some View {
        ClassesView(MM: AccountManager())
    }
}
