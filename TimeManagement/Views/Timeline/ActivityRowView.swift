//
//  ActivityRowView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/19.
//

import SwiftUI
import SwiftData

struct ActivityRowView: View {
    let activity: ActivityLog
    let onEdit: () -> Void
    @State private var isPressed = false
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 16) {
                // Enhanced Category Icon
                ZStack {
                    Circle()
                        .fill(Color(activity.category.color).opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: activity.category.icon)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(activity.category.color))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Time Range & Duration
                    HStack(spacing: 8) {
                        Text("\(timeFormatter.string(from: activity.startTime)) - \(timeFormatter.string(from: activity.endTime))")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        // Duration Badge
                        Text("\(activity.durationInMinutes)分")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.quaternary, in: Capsule())
                    }
                    
                    // Category Name
                    Text(activity.category.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    // Memo
                    if !activity.memo.isEmpty {
                        Text(activity.memo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    // Priority Tag
                    HStack {
                        Text(activity.priority.shortName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Color(activity.priority.color))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Color(activity.priority.color).opacity(0.15),
                                in: Capsule()
                            )
                        
                        Spacer()
                        
                        // Chevron
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Material.regularMaterial)
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: isPressed ? 2 : 8,
                        x: 0,
                        y: isPressed ? 1 : 4
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .accessibilityLabel("\(activity.category.rawValue)、\(timeFormatter.string(from: activity.startTime))から\(timeFormatter.string(from: activity.endTime))、\(activity.durationInMinutes)分")
        .accessibilityHint("タップして編集")
    }
}

#Preview {
    ActivityRowView(activity: ActivityLog(
        startTime: Date(),
        endTime: Date().addingTimeInterval(3600),
        memo: "サンプルメモ",
        category: .work,
        priority: .importantAndUrgent
    )) {
        print("Edit tapped")
    }
    .padding()
    .modelContainer(for: ActivityLog.self, inMemory: true)
}