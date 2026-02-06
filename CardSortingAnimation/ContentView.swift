//
//  ContentView.swift
//  CardSortingAnimation
//
//  Created by khoasdyn on 5/2/26.
//

import SwiftUI

struct Student: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let scores: [Int]
}

struct ContentView: View {
    @State private var selectedTest: Int = 1
    
    // Tracks which student card is currently expanded. nil means all cards are collapsed.
    @State private var expandedStudentID: UUID? = nil
    
    let students: [Student] = [
        Student(name: "Alice", color: .red, scores: [78, 89, 65, 92, 88, 71, 95, 82, 76, 90]),
        Student(name: "Bob", color: .blue, scores: [70, 92, 88, 75, 69, 94, 80, 85, 91, 72]),
        Student(name: "Charlie", color: .green, scores: [85, 78, 92, 68, 95, 82, 74, 90, 88, 81]),
        Student(name: "Diana", color: .orange, scores: [92, 71, 80, 89, 76, 88, 91, 68, 95, 84]),
        Student(name: "Eve", color: .purple, scores: [68, 95, 74, 91, 82, 79, 86, 93, 70, 97])
    ]
    
    var sortedStudents: [Student] {
        students.sorted { $0.scores[selectedTest - 1] > $1.scores[selectedTest - 1] }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Test \(selectedTest)")
                .font(.title)
                .fontWeight(.bold)
                .contentTransition(.numericText())
            
            VStack(spacing: 12) {
                ForEach(sortedStudents) { student in
                    StudentCardView(
                        student: student,
                        selectedTest: selectedTest,
                        isExpanded: expandedStudentID == student.id
                    )
                    .onTapGesture {
                        withAnimation(.smooth) {
                            // If tapping the already-expanded card, collapse it.
                            // Otherwise, expand the tapped card (and collapse the previous one).
                            if expandedStudentID == student.id {
                                expandedStudentID = nil
                            } else {
                                expandedStudentID = student.id
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { Double(selectedTest) },
                    set: { selectedTest = Int($0) }
                ), in: 1...10, step: 1)
                
                HStack {
                    ForEach(1...10, id: \.self) { test in
                        Text("\(test)")
                            .font(.caption)
                            .fontWeight(test == selectedTest ? .bold : .regular)
                            .foregroundStyle(test == selectedTest ? .primary : .secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .animation(.smooth, value: selectedTest)
    }
}

struct StudentCardView: View {
    let student: Student
    let selectedTest: Int
    let isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // The main card row that always shows (name + current test score)
            HStack {
                Text(student.name)
                    .fontWeight(.medium)
                Spacer()
                Text("\(student.scores[selectedTest - 1])")
                    .fontWeight(.bold)
                    .contentTransition(.numericText())
            }
            .padding()
            
            // The expandable section showing all 10 test scores as horizontal bars
            if isExpanded {
                VStack(spacing: 6) {
                    ForEach(1...10, id: \.self) { testNumber in
                        let score = student.scores[testNumber - 1]
                        
                        HStack(spacing: 8) {
                            // Label for each test
                            Text("T\(testNumber)")
                                .font(.caption)
                                .fontWeight(testNumber == selectedTest ? .bold : .regular)
                                .frame(width: 24, alignment: .leading)
                            
                            // The bar that fills proportionally to the score out of 100
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background track
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.white.opacity(0.2))
                                    
                                    // Filled portion based on the score
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.white.opacity(testNumber == selectedTest ? 0.9 : 0.5))
                                        .frame(width: geometry.size.width * CGFloat(score) / 100)
                                }
                            }
                            .frame(height: 10)
                            
                            // Score number on the right
                            Text("\(score)")
                                .font(.caption)
                                .fontWeight(testNumber == selectedTest ? .bold : .regular)
                                .frame(width: 28, alignment: .trailing)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity)
        .background(student.color)
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


#Preview {
    ContentView()
}
