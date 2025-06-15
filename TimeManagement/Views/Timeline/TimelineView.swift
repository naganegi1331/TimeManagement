//
//  TimelineView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [ActivityLog]
    @State private var selectedDate = Date()
    @State private var showingAddActivity = false
    @State private var editingActivity: ActivityLog?
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }
    
    private var filteredActivities: [ActivityLog] {
        let calendar = Calendar.current
        return activities.filter { activity in
            calendar.isDate(activity.startTime, inSameDayAs: selectedDate)
        }.sorted { $0.startTime < $1.startTime }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Enhanced Date Selection Header
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("今日の活動")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Text(dateFormatter.string(from: selectedDate))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Summary Badge
                        if !filteredActivities.isEmpty {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(filteredActivities.count)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                Text("活動")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    
                    // Improved Date Picker
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Material.regularMaterial)
                
                Divider()
                
                // Enhanced Activity List
                if filteredActivities.isEmpty {
                    EmptyStateView(selectedDate: selectedDate) {
                        showingAddActivity = true
                    }
                } else {
                    List {
                        ForEach(filteredActivities) { activity in
                            ActivityRowView(activity: activity) {
                                editingActivity = activity
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteActivities)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("時間の家計簿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddActivity = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.white, .blue)
                    }
                    .accessibilityLabel("新しい活動を追加")
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: AnalyticsView()) {
                        Image(systemName: "chart.pie.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("分析画面を開く")
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                ActivityEditView(date: selectedDate)
            }
            .sheet(item: $editingActivity) { activity in
                ActivityEditView(activity: activity)
            }
        }
    }
    
    private func deleteActivities(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredActivities[index])
            }
        }
    }
}

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

// MARK: - Empty State View
struct EmptyStateView: View {
    let selectedDate: Date
    let onAddActivity: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: isToday ? "calendar.badge.plus" : "calendar.badge.clock")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue.gradient)
                
                VStack(spacing: 8) {
                    Text(isToday ? "今日の活動を記録しよう" : "この日の活動記録はありません")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text(isToday ? "新しい活動を追加して、時間の使い方を管理しましょう" : "活動を追加して記録を開始できます")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            
            Button(action: onAddActivity) {
                Label("活動を追加", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.blue.gradient, in: Capsule())
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Material.regularMaterial)
    }
}

// MARK: - Press Events Extension
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

#Preview {
    TimelineView()
        .modelContainer(for: ActivityLog.self, inMemory: true)
} 