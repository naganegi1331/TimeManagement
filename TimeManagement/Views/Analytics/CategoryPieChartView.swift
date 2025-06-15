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

// 象限別チャートデータ
struct QuadrantChartData {
    let category: ActivityCategory
    let quadrant: Int
    let minutes: Int
    let percentage: Double
    let color: Color
    let priority: PriorityMatrix
}

// 後方互換性のためのChartData（必要に応じて削除可能）
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

// 象限別Legend セクション
struct QuadrantLegendSection: View {
    let quadrant: Int
    let data: [QuadrantChartData]
    
    private var quadrantTitle: String {
        switch quadrant {
        case 1: return "第1象限（重要・緊急）"
        case 2: return "第2象限（重要・非緊急）"
        case 3: return "第3象限（非重要・緊急）"
        case 4: return "第4象限（非重要・非緊急）"
        default: return "その他"
        }
    }
    
    private var quadrantColor: Color {
        switch quadrant {
        case 1: return .red
        case 2: return .blue
        case 3: return .orange
        case 4: return .gray
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Quadrant Header
            HStack(spacing: 8) {
                Circle()
                    .fill(quadrantColor)
                    .frame(width: 12, height: 12)
                
                Text(quadrantTitle)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                let totalMinutes = data.reduce(0) { $0 + $1.minutes }
                Text("\(totalMinutes)分")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            // Category items in this quadrant
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(data, id: \.category) { item in
                    QuadrantLegendItem(data: item)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(quadrantColor.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(quadrantColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// 象限別Legend アイテム
struct QuadrantLegendItem: View {
    let data: QuadrantChartData
    
    var body: some View {
        HStack(spacing: 6) {
            // Category icon
            ZStack {
                Circle()
                    .fill(data.color.opacity(0.15))
                    .frame(width: 20, height: 20)
                
                Image(systemName: data.category.icon)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(data.color)
            }
            
            VStack(alignment: .leading, spacing: 1) {
                Text(data.category.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 2) {
                    Text("\(data.minutes)分")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("(\(String(format: "%.1f", data.percentage * 100))%)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(Material.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(data.category.rawValue): \(data.minutes)分, \(String(format: "%.1f", data.percentage * 100))パーセント")
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