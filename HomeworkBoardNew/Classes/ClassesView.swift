//
//  ClassesView.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 17/6/22.
//

import SwiftUI
import Firebase

struct ClassesView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var createClass = false
    @State var deleteClass = false
    @State var showSettings = false
    
    @State var classes = [Class(name: "", date: "")]
    @State var subjects: [Subject] = []
    @State var entriesWeek: [Entry] = []
    
    @Binding var member: Member
    @Binding var success: Bool
    @Binding var chooseClassView: Bool
    
    var MM = MemberManager()
    var CM = ClassManager()
    var SM = SubjectManager()
    let BM = BoardManager()
    
    var body: some View {
        VStack {
            if member.perm == .member || member.perm == .leader || member.perm == .teacher {
                SummaryView(clas: $classes[0], subjects: $subjects, CM: CM, SM: SM, BM: BM, member: member)
            }
            ShowClassesView(member: member, classes: $classes, subjects: $subjects, CM: CM, MM: MM, SM: SM, BM: BM)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if member.perm == .admin || member.perm == .teacher {
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
                        
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(Color(colorScheme == .light ? "murkyBlue" : "lightestBlue"))
                    
                }
            }
        }
        .navigationTitle(member.perm == .member || member.perm == .leader ? "Classes" : "Class")
        .sheet(isPresented: $createClass) {
            CreateClassView(CM: CM, isSheetPresented: $createClass)
        }
        .sheet(isPresented: $deleteClass) {
            DeleteClassView(isSheetPresented: $deleteClass, CM: CM)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(classes: $classes, subjects: $subjects, MM: MM, CM: CM, SM: SM, member: member)
        }
        .background(color: colorScheme == .light ? "lightestBlue" : "murkyBlue")
        .onChange(of: member.clas) { newValue in
            if newValue == "" {
                success = false
                chooseClassView = false
            }
        }
        .onAppear {
            let ref = Database.database().reference()
            let anotherPath = ref.child("subjects")
            anotherPath.observe(.value) { snapshot in
                let value = snapshot.value as? NSDictionary
                
                guard value?.allValues != nil else { subjects = []; return }
                
                let subjects = value?.allValues as! [String]
                let decodedSubjects = subjects.map { subj -> Subject in
                    let decoder = JSONDecoder()
                    let decoded = try? decoder.decode(Subject.self, from: subj.data(using: .utf8)!)
                    return decoded!
                }
                self.subjects = []
                self.subjects = decodedSubjects
            }
            
            let path = (member.perm == .member ? ref.child("classes").child(member.clas) : ref.child("classes"))
            path.observe(.value) { snapshot in
                let value = snapshot.value as? NSDictionary
                
                guard value?.allValues != nil else { classes = []; return }
                let classes = value?.allValues as! [String]
                let decodedClasses = classes.map { clas -> Class in
                    let decoder = JSONDecoder()
                    let decoded = try? decoder.decode(Class.self, from: clas.data(using: .utf8)!)
                    return decoded!
                }
                self.classes = decodedClasses
            }
            
            let newPath = ref.child("users").child(member.name)
            newPath.observe(.value) { snapshot in
                let value = snapshot.value as? String
                
                let decoder = JSONDecoder()
                self.member = try! decoder.decode(Member.self, from: value!.data(using: .utf8)!)
                
            }
        }
    }
}


struct SummaryView: View {
    
    @Binding var clas: Class
    @Binding var subjects: [Subject]
    
    var CM: ClassManager
    var SM: SubjectManager
    
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
                                .foregroundColor(.white)
                        } maximumValueLabel: {
                            Text("10")
                                .bold()
                                .foregroundColor(.white)
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
                                    BoardView(date: $date, subjects: $subjects, clas: $clas, CM: CM, SM: SM, BM: BM, member: member)
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
    var member: Member
    
    @Binding var classes: [Class]
    @Binding var subjects: [Subject]
    
    var CM: ClassManager
    var MM: MemberManager
    var SM: SubjectManager
    
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
            LazyVGrid(columns: columns) {
                ForEach($classes) { $clas in
                    NavigationLink {
                        BoardView(date: $date, subjects: $subjects, clas: $clas, CM: CM, SM: SM, BM: BM, member: member)
                    } label: {
                        Text(clas.name)
                            .bold()
                            .blockDisplay()
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
