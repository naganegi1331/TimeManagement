//
//  AnalyticsView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [ActivityLog]
    @State private var selectedDate = Date()
    
    private var filteredActivities: [ActivityLog] {
        let calendar = Calendar.current
        return activities.filter { activity in
            calendar.isDate(activity.startTime, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Enhanced Header with Date Selection
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("時間分析")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text("活動データの詳細な分析")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Date Selection Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.headline)
                                .foregroundStyle(.blue)
                            
                            Text("分析対象日")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                }
                
                if filteredActivities.isEmpty {
                    AnalyticsEmptyStateView(selectedDate: selectedDate)
                        .frame(minHeight: 300)
                        .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 24) {
                        // Quick Stats Overview
                        QuickStatsView(activities: filteredActivities)
                            .padding(.horizontal, 20)
                        
                        // Charts Section
                        VStack(spacing: 20) {
                            // Category Chart by Quadrant
                            AnalyticsCardView(
                                title: "カテゴリ別時間分析（象限別）",
                                icon: "chart.pie.fill",
                                description: "重要度・緊急度の象限ごとにカテゴリを色分け表示（タップで詳細分析）"
                            ) {
                                CategoryPieChartView(activities: filteredActivities)
                                    .frame(height: 400)
                            }
                            
                            // Detailed Statistics
                            AnalyticsCardView(
                                title: "詳細統計",
                                icon: "list.bullet.rectangle.fill",
                                description: "カテゴリと優先度の詳細分析"
                            ) {
                                EnhancedSummaryStatsView(activities: filteredActivities)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("分析")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Enhanced Analytics Components

struct AnalyticsEmptyStateView: View {
    let selectedDate: Date
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue.gradient)
                
                VStack(spacing: 8) {
                    Text("分析データがありません")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("\(dateFormatter.string(from: selectedDate))の活動記録がありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 12) {
                Text("他の日付を選択するか、活動を記録してください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct QuickStatsView: View {
    let activities: [ActivityLog]
    
    private var totalTime: Int {
        activities.reduce(0) { $0 + $1.durationInMinutes }
    }
    
    private var activeCategories: Int {
        Set(activities.map { $0.category }).count
    }
    
    private var activitiesCount: Int {
        activities.count
    }
    
    var body: some View {
        HStack(spacing: 12) {
            QuickStatCard(
                title: "合計時間",
                value: formatTime(totalTime),
                icon: "clock.fill",
                color: .blue
            )
            
            QuickStatCard(
                title: "活動数",
                value: "\(activitiesCount)",
                icon: "list.bullet",
                color: .green
            )
            
            QuickStatCard(
                title: "カテゴリ",
                value: "\(activeCategories)",
                icon: "tag.fill",
                color: .orange
            )
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        if hours > 0 {
            return "\(hours)h \(mins)m"
        } else {
            return "\(mins)m"
        }
    }
}

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

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
    NavigationView {
        AnalyticsView()
    }
    .modelContainer(for: ActivityLog.self, inMemory: true)
} 