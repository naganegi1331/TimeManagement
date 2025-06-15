//
//  CategoryPieChartView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI

struct CategoryPieChartView: View {
    let activities: [ActivityLog]
    
    private var chartData: [ChartData] {
        let grouped = Dictionary(grouping: activities) { $0.category }
        let totalMinutes = activities.reduce(0) { $0 + $1.durationInMinutes }
        
        return grouped.compactMap { category, activities in
            let minutes = activities.reduce(0) { $0 + $1.durationInMinutes }
            guard minutes > 0 else { return nil }
            
            let percentage = Double(minutes) / Double(totalMinutes)
            return ChartData(
                category: category,
                minutes: minutes,
                percentage: percentage,
                color: Color(category.color)
            )
        }.sorted { $0.minutes > $1.minutes }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if chartData.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 32))
                        .foregroundStyle(.tertiary)
                    
                    Text("データがありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                VStack(spacing: 24) {
                    // Enhanced Pie Chart
                    ZStack {
                        // Background circle with shadow
                        Circle()
                            .fill(.quaternary)
                            .frame(width: 170, height: 170)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        // Pie slices
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            EnhancedPieSlice(
                                startAngle: startAngle(for: index),
                                endAngle: endAngle(for: index),
                                color: data.color,
                                isHighlighted: false
                            )
                        }
                        
                        // Center circle with total time
                        VStack(spacing: 2) {
                            Text("合計")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Text(formatTotalTime())
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                        }
                        .padding(16)
                        .background(Material.regularMaterial, in: Circle())
                    }
                    .frame(width: 170, height: 170)
                    
                    // Enhanced Legend
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(chartData, id: \.category) { data in
                            LegendItem(data: data)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatTotalTime() -> String {
        let total = chartData.reduce(0) { $0 + $1.minutes }
        let hours = total / 60
        let minutes = total % 60
        
        if hours > 0 {
            return "\(hours)h\(minutes > 0 ? " \(minutes)m" : "")"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func startAngle(for index: Int) -> Angle {
        let previousPercentages = chartData.prefix(index).reduce(0) { $0 + $1.percentage }
        return Angle(degrees: previousPercentages * 360 - 90)
    }
    
    private func endAngle(for index: Int) -> Angle {
        let percentagesThroughIndex = chartData.prefix(index + 1).reduce(0) { $0 + $1.percentage }
        return Angle(degrees: percentagesThroughIndex * 360 - 90)
    }
}

struct ChartData {
    let category: ActivityCategory
    let minutes: Int
    let percentage: Double
    let color: Color
}

struct EnhancedPieSlice: View {
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    let isHighlighted: Bool
    
    var body: some View {
        Path { path in
            let center = CGPoint(x: 85, y: 85)
            let outerRadius: CGFloat = isHighlighted ? 82 : 80
            let innerRadius: CGFloat = 45
            
            // Outer arc
            path.addArc(
                center: center,
                radius: outerRadius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
            
            // Inner arc (reverse)
            path.addArc(
                center: center,
                radius: innerRadius,
                startAngle: endAngle,
                endAngle: startAngle,
                clockwise: true
            )
            
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                colors: [color, color.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            Path { path in
                let center = CGPoint(x: 85, y: 85)
                let outerRadius: CGFloat = isHighlighted ? 82 : 80
                let innerRadius: CGFloat = 45
                
                path.addArc(
                    center: center,
                    radius: outerRadius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false
                )
                
                path.addArc(
                    center: center,
                    radius: innerRadius,
                    startAngle: endAngle,
                    endAngle: startAngle,
                    clockwise: true
                )
                
                path.closeSubpath()
            }
            .stroke(.white, lineWidth: 1.5)
        )
        .scaleEffect(isHighlighted ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
}

struct LegendItem: View {
    let data: ChartData
    
    var body: some View {
        HStack(spacing: 8) {
            // Icon with category symbol
            ZStack {
                Circle()
                    .fill(data.color.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                Image(systemName: data.category.icon)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(data.color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(data.category.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text("\(data.minutes)分")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                    
                    Text("(\(String(format: "%.1f", data.percentage * 100))%)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(.quaternary, in: Capsule())
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(data.category.rawValue): \(data.minutes)分, \(String(format: "%.1f", data.percentage * 100))パーセント")
    }
}

#Preview {
    let sampleActivities = [
        ActivityLog(
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            memo: "サンプル1",
            category: .work,
            priority: .importantAndUrgent
        ),
        ActivityLog(
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            memo: "サンプル2",
            category: .learning,
            priority: .importantNotUrgent
        ),
        ActivityLog(
            startTime: Date().addingTimeInterval(7200),
            endTime: Date().addingTimeInterval(9000),
            memo: "サンプル3",
            category: .exercise,
            priority: .notImportantAndUrgent
        )
    ]
    
    CategoryPieChartView(activities: sampleActivities)
        .padding()
} 