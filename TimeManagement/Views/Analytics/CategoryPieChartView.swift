//
//  CategoryPieChartView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI

struct CategoryPieChartView: View {
    let activities: [ActivityLog]
    
    private var chartData: [QuadrantChartData] {
        // グループ化：カテゴリ別に象限も考慮
        let grouped = Dictionary(grouping: activities) { 
            "\($0.category.rawValue)_\($0.priority.quadrant)" 
        }
        let totalMinutes = activities.reduce(0) { $0 + $1.durationInMinutes }
        
        return grouped.compactMap { key, activities in
            let minutes = activities.reduce(0) { $0 + $1.durationInMinutes }
            guard minutes > 0, let firstActivity = activities.first else { return nil }
            
            let percentage = Double(minutes) / Double(totalMinutes)
            return QuadrantChartData(
                category: firstActivity.category,
                quadrant: firstActivity.priority.quadrant,
                minutes: minutes,
                percentage: percentage,
                color: quadrantColor(for: firstActivity.priority.quadrant),
                priority: firstActivity.priority
            )
        }.sorted { 
            if $0.quadrant == $1.quadrant {
                return $0.minutes > $1.minutes
            }
            return $0.quadrant < $1.quadrant
        }
    }
    
    // 象限別の色定義
    private func quadrantColor(for quadrant: Int) -> Color {
        switch quadrant {
        case 1: return .red        // 重要かつ緊急
        case 2: return .blue       // 重要だが緊急でない
        case 3: return .orange     // 重要でないが緊急
        case 4: return .gray       // 重要でも緊急でもない
        default: return .gray
        }
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
                    // Enhanced Pie Chart with Navigation
                    NavigationLink(destination: MatrixChartView(activities: activities)) {
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
                                
                                // タップヒント
                                Text("タップで詳細")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                                    .opacity(0.8)
                            }
                            .padding(16)
                            .background(Material.regularMaterial, in: Circle())
                        }
                        .frame(width: 170, height: 170)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Enhanced Legend with Quadrant Info
                    VStack(spacing: 16) {
                        // Legend by Quadrant
                        ForEach([1, 2, 3, 4], id: \.self) { quadrant in
                            let quadrantData = chartData.filter { $0.quadrant == quadrant }
                            if !quadrantData.isEmpty {
                                QuadrantLegendSection(quadrant: quadrant, data: quadrantData)
                            }
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