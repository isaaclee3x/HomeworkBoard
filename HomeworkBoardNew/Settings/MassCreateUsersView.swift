//
//  MassCreateUsersView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 20/7/22.
//

import SwiftUI
import Foundation

struct MassCreateUsersView: View {
    
    @State var chooseFile = false
    @State var createFile = false
    
    @State var students = [Member()]
    @ObservedObject var MM: MemberManager
    @ObservedObject var CM: ClassManager
    
    var body: some View {
        Form {
            VStack {
            Text("**Note** that the excel file has to be in this format")
            
            RoundedRectangle(cornerRadius: 5)
                .frame(width: 200, height: 100, alignment: .center)
                .overlay {
                    VStack {
                        HStack {
                            Text("Row A")
                                .bold()
                            Text("Row B")
                                .bold()
                        }
                        .offset(x: 25)
                        .foregroundColor(.white)
                        ForEach(0 ..< 2) { i in
                            HStack {
                                Text("Col. \(i+1)")
                                    .bold()
                                Text("Name")
                                
                                Text("Class")
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
            }
            
            Button {
                chooseFile = true
            } label: {
                Text("Choose an excel file")
                    .foregroundColor(Color("murkyBlue"))
                    .bold()
            }
            .fileImporter(isPresented: $chooseFile, allowedContentTypes: [.xml]) { result in
                switch result {
                case .success(let url): MM.massCreateAccount(filePath: url)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            Button {
                createFile.toggle()
            } label: {
                Text("Create your own list")
                    .bold()
            }
            
            if createFile {
                List {
                    ForEach($students) { $student in
                        HStack {
                            TextField("Name:", text: $student.name)
                                .disableAutocorrection(true)
                                .frame(width: 100, alignment: .leading)
                            Menu("Class:") {
                                if let classes = CM.classes {
                                    ForEach(classes) { clas in
                                        Button {
                                            student.clas = clas.name
                                        } label: {
                                            Text(clas.name)
                                        }
                                    }
                                }
                            }
                            Text(student.clas)
                        }
                        .onChange(of: student.name) { newValue in
                            if students.count > 1 {
                                if newValue == "" {
                                    let student = students.last
                                    students.removeSubrange(students.firstIndex(of: student!)! ..< students.count)
                                }
                            }
                            if newValue.count == 1 {
                                students.append(Member())
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            Task {
                await CM.getClasses()
            }
        }
        .background(color: "lightestBlue")
    }
}

struct MassCreateUsersView_Previews: PreviewProvider {
    static var previews: some View {
        MassCreateUsersView(MM: MemberManager(), CM: ClassManager())
    }
}
