//
//  AnalyticsCardComponents.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/19.
//

import SwiftUI
import SwiftData

struct AnalyticsCardView<Content: View>: View {
    let title: String
    let icon: String
    let description: String
    let content: Content
    
    init(title: String, icon: String, description: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct EnhancedSummaryStatsView: View {
    let activities: [ActivityLog]
    
    private var totalTime: Int {
        activities.reduce(0) { $0 + $1.durationInMinutes }
    }
    
    private var categoryStats: [(category: ActivityCategory, minutes: Int, percentage: Double)] {
        let grouped = Dictionary(grouping: activities) { $0.category }
        return grouped.map { category, activities in
            let minutes = activities.reduce(0) { $0 + $1.durationInMinutes }
            let percentage = totalTime > 0 ? Double(minutes) / Double(totalTime) * 100 : 0
            return (category: category, minutes: minutes, percentage: percentage)
        }.sorted { $0.minutes > $1.minutes }
    }
    
    private var priorityStats: [(priority: PriorityMatrix, minutes: Int, percentage: Double)] {
        let grouped = Dictionary(grouping: activities) { $0.priority }
        return grouped.map { priority, activities in
            let minutes = activities.reduce(0) { $0 + $1.durationInMinutes }
            let percentage = totalTime > 0 ? Double(minutes) / Double(totalTime) * 100 : 0
            return (priority: priority, minutes: minutes, percentage: percentage)
        }.sorted { $0.priority.quadrant < $1.priority.quadrant }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Category Statistics
            VStack(alignment: .leading, spacing: 12) {
                Text("カテゴリ別分析")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                ForEach(categoryStats, id: \.category) { stat in
                    StatRow(
                        icon: stat.category.icon,
                        iconColor: Color(stat.category.color),
                        title: stat.category.rawValue,
                        minutes: stat.minutes,
                        percentage: stat.percentage
                    )
                }
            }
            
            Divider()
            
            // Priority Statistics
            VStack(alignment: .leading, spacing: 12) {
                Text("重要度・緊急度別分析")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                ForEach(priorityStats, id: \.priority) { stat in
                    StatRow(
                        icon: "circle.fill",
                        iconColor: Color(stat.priority.color),
                        title: stat.priority.shortName,
                        minutes: stat.minutes,
                        percentage: stat.percentage
                    )
                }
            }
        }
    }
}

struct StatRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let minutes: Int
    let percentage: Double
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(iconColor)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.primary)
            
            Spacer()
            
            HStack(spacing: 8) {
                Text("\(minutes)分")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("(\(String(format: "%.1f", percentage))%)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AnalyticsCardView(
        title: "テストカード",
        icon: "chart.pie.fill",
        description: "サンプル説明"
    ) {
        Text("サンプルコンテンツ")
    }
    .padding()
}