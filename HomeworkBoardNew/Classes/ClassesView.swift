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
    
    @ObservedObject var MM: AccountManager
    @StateObject var CM = ClassManager()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns) {
            if classes.isEmpty {
                Text("No Classes Yet")
                    .frame(maxWidth: 400)
                    .multilineTextAlignment(.center)
                    .opacity(0.4)
                    
            } else {
                ForEach($classes) { $clas in
                    NavigationLink {
                        BoardView(clas: $clas, CM: CM, member: MM.account!)
                    } label: {
                        Text(clas.name)
                            .blockDisplay()
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
                        .foregroundColor(colorScheme == .light ? Color("murkyBlue") : Color("lightestBlue"))
                        .bold()
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
                classes = CM.classes ?? []
            }
        } content: {
            DeleteClassView(isSheetPresented: $deleteClass, CM: CM)
        }
    }
}
