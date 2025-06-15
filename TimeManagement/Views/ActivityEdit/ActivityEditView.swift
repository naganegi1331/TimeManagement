//
//  ActivityEditView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI
import SwiftData

struct ActivityEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var selectedCategory: ActivityCategory = .work
    @State private var selectedPriority: PriorityMatrix = .notImportantNotUrgent
    @State private var memo: String = ""
    
    private let activity: ActivityLog?
    private let isEditing: Bool
    
    // 新規作成用のイニシャライザ
    init(date: Date = Date()) {
        self.activity = nil
        self.isEditing = false
        
        let calendar = Calendar.current
        let now = Date()
        
        // 選択された日付の現在時刻で初期化
        _ = calendar.startOfDay(for: date)
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = currentTime.hour
        startComponents.minute = currentTime.minute
        
        var endComponents = startComponents
        endComponents.hour = (currentTime.hour ?? 0) + 1
        
        self._startTime = State(initialValue: calendar.date(from: startComponents) ?? date)
        self._endTime = State(initialValue: calendar.date(from: endComponents) ?? date.addingTimeInterval(3600))
    }
    
    // 編集用のイニシャライザ
    init(activity: ActivityLog) {
        self.activity = activity
        self.isEditing = true
        
        self._startTime = State(initialValue: activity.startTime)
        self._endTime = State(initialValue: activity.endTime)
        self._selectedCategory = State(initialValue: activity.category)
        self._selectedPriority = State(initialValue: activity.priority)
        self._memo = State(initialValue: activity.memo)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with icon
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(selectedCategory.color).opacity(0.15))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: selectedCategory.icon)
                                .font(.title)
                                .fontWeight(.medium)
                                .foregroundStyle(Color(selectedCategory.color))
                        }
                        
                        Text(selectedCategory.rawValue)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                    .padding(.top, 16)
                    
                    VStack(spacing: 20) {
                        // Time Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeaderView(title: "時間設定", icon: "clock.fill")
                            
                            VStack(spacing: 12) {
                                TimePickerRow(
                                    title: "開始時刻",
                                    selection: $startTime,
                                    icon: "play.circle.fill"
                                )
                                
                                Divider()
                                    .padding(.horizontal, 16)
                                
                                TimePickerRow(
                                    title: "終了時刻",
                                    selection: $endTime,
                                    icon: "stop.circle.fill"
                                )
                                
                                // Duration Display
                                if startTime < endTime {
                                    HStack {
                                        Image(systemName: "timer")
                                            .foregroundStyle(.blue)
                                        Text("継続時間: \(Int(endTime.timeIntervalSince(startTime) / 60))分")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 8)
                                }
                            }
                            .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Category Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeaderView(title: "カテゴリ", icon: "tag.fill")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(ActivityCategory.allCases, id: \.self) { category in
                                    CategorySelectionCard(
                                        category: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedCategory = category
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Priority Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeaderView(title: "重要度・緊急度", icon: "exclamationmark.triangle.fill")
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                ForEach(PriorityMatrix.allCases, id: \.self) { priority in
                                    PrioritySelectionCard(
                                        priority: priority,
                                        isSelected: selectedPriority == priority
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedPriority = priority
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Memo Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeaderView(title: "メモ", icon: "note.text")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("活動の詳細や振り返りを記録", text: $memo, axis: .vertical)
                                    .textFieldStyle(.plain)
                                    .font(.body)
                                    .padding(16)
                                    .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                    .lineLimit(4...8)
                                
                                HStack {
                                    Spacer()
                                    Text("\(memo.count) / 200文字")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle(isEditing ? "活動を編集" : "活動を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveActivity()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(isValidInput ? .blue : .secondary)
                    .disabled(!isValidInput)
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    private var isValidInput: Bool {
        startTime < endTime
    }
    
    private func saveActivity() {
        if let existingActivity = activity {
            // 編集
            existingActivity.startTime = startTime
            existingActivity.endTime = endTime
            existingActivity.category = selectedCategory
            existingActivity.priority = selectedPriority
            existingActivity.memo = memo
        } else {
            // 新規作成
            let newActivity = ActivityLog(
                startTime: startTime,
                endTime: endTime,
                memo: memo,
                category: selectedCategory,
                priority: selectedPriority
            )
            modelContext.insert(newActivity)
        }
        
        dismiss()
    }
}

// MARK: - Supporting Views

struct SectionHeaderView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct TimePickerRow: View {
    let title: String
    @Binding var selection: Date
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                DatePicker("", selection: $selection, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct CategorySelectionCard: View {
    let category: ActivityCategory
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(category.color).opacity(isSelected ? 0.3 : 0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: category.icon)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(category.color))
                }
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(category.color).opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(category.color) : .clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
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
        .accessibilityLabel(category.rawValue)
        .accessibilityValue(isSelected ? "選択済み" : "未選択")
    }
}

struct PrioritySelectionCard: View {
    let priority: PriorityMatrix
    let isSelected: Bool
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(priority.shortName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? Color(priority.color) : .primary)
                    .multilineTextAlignment(.center)
                
                Text("第\(priority.quadrant)象限")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(priority.color).opacity(0.15) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(priority.color) : .clear, lineWidth: 2)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
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
        .accessibilityLabel("\(priority.shortName), 第\(priority.quadrant)象限")
        .accessibilityValue(isSelected ? "選択済み" : "未選択")
    }
}

#Preview {
    ActivityEditView()
        .modelContainer(for: ActivityLog.self, inMemory: true)
} 