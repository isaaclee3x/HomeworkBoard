//
//  Modifiers.swift
//  HomeworkBoardNew
//
//  Created by Isaac Lee Jing Zhi on 10/7/22.
//

import Foundation
import SwiftUI

struct Header: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.black)
            .font(.system(size: 40))
            .frame(width: 250, alignment: .leading)
    }
}

struct ClassBlock: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .frame(width: 150, height: 70, alignment: .center)
            .background(colorScheme == .dark ? Color("lightestBlue") : Color("murkyBlue"))
            .cornerRadius(10)
            .foregroundColor(.black)
    }
}

struct BottomButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 200, height: 50)
            .font(.system(size: 20))
            .background(Color("murkyBlue"))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension View {
    func header() -> some View {
        modifier(Header())
    }
    
    func blockDisplay() -> some View {
        modifier(ClassBlock())
    }
    
    func background(color: String) -> some View {
        ZStack {
            Color(color)
                .ignoresSafeArea()
            
            self
            
        }
    }
    
    func bottomButton() -> some View {
        modifier(BottomButton())
    }
    
    func credStyle(width: Double, height: Double) -> some View {
        return self
            .frame(width: width, height: height)
            .textInputAutocapitalization(.never)
            .foregroundColor(.black)
            .background(Color("lighterBlue"))
            .cornerRadius(10)
            .padding()
    }
}
