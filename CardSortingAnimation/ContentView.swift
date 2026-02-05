//
//  ContentView.swift
//  CardSortingAnimation
//
//  Created by khoasdyn on 5/2/26.
//

import SwiftUI

struct Item: Identifiable {
    let id = UUID()
    let title: String
    let color: Color
}

struct ContentView: View {
    @State private var items: [Item] = [
        Item(title: "Item 1", color: .red),
        Item(title: "Item 2", color: .blue),
        Item(title: "Item 3", color: .green),
        Item(title: "Item 4", color: .orange),
        Item(title: "Item 5", color: .purple)
    ]
    
    var body: some View {
        VStack {
            ForEach(items) { item in
                Text(item.title)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(item.color)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button("Shuffle") {
                withAnimation {
                    items.shuffle()
                }
            }
            .buttonStyle(.bordered)
            .padding(.top)
        }
        .padding()
    }
}


#Preview {
    ContentView()
}
