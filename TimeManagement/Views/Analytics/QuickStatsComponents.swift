//
//  QuickStatsComponents.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/19.
//

import SwiftUI
import SwiftData

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

#Preview {
    QuickStatsView(activities: [])
        .padding()
        .modelContainer(for: ActivityLog.self, inMemory: true)
}