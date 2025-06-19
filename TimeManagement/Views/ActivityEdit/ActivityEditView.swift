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
        
        // 選択された日付の現在時刻で初期化し、15分単位に丸める
        _ = calendar.startOfDay(for: date)
        let currentTime = calendar.dateComponents([.hour, .minute], from: now)
        
        // 15分単位に丸める
        let roundedMinute = Self.roundToNearestFifteenMinutes(currentTime.minute ?? 0)
        
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = currentTime.hour
        startComponents.minute = roundedMinute
        
        var endComponents = startComponents
        endComponents.minute = (roundedMinute + 60) % 60
        if roundedMinute + 60 >= 60 {
            endComponents.hour = (currentTime.hour ?? 0) + 1
        }
        
        self._startTime = State(initialValue: calendar.date(from: startComponents) ?? date)
        self._endTime = State(initialValue: calendar.date(from: endComponents) ?? date.addingTimeInterval(3600))
    }
    
    // 15分単位に丸める静的メソッド
    private static func roundToNearestFifteenMinutes(_ minute: Int) -> Int {
        let remainder = minute % 15
        if remainder < 8 {
            return minute - remainder
        } else {
            return minute + (15 - remainder)
        }
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
                            
                            VStack(spacing: 12) {
                                Picker("カテゴリを選択", selection: $selectedCategory) {
                                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                                        HStack(spacing: 8) {
                                            Image(systemName: category.icon)
                                                .foregroundStyle(Color(category.color))
                                            Text(category.rawValue)
                                        }
                                        .tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                
                                // Selected category preview
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(selectedCategory.color).opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: selectedCategory.icon)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundStyle(Color(selectedCategory.color))
                                    }
                                    
                                    Text("選択中: \(selectedCategory.rawValue)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(selectedCategory.color).opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        
                        // Priority Section
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeaderView(title: "重要度・緊急度", icon: "exclamationmark.triangle.fill")
                            
                            VStack(spacing: 12) {
                                Picker("重要度・緊急度を選択", selection: $selectedPriority) {
                                    ForEach(PriorityMatrix.allCases, id: \.self) { priority in
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(priority.shortName)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            Text("第\(priority.quadrant)象限")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        .tag(priority)
                                    }
                                }
                                .pickerStyle(.menu)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                                
                                // Selected priority preview
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(selectedPriority.color).opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        
                                        Text("\(selectedPriority.quadrant)")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundStyle(Color(selectedPriority.color))
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("選択中: \(selectedPriority.shortName)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.secondary)
                                        
                                        Text("第\(selectedPriority.quadrant)象限")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(selectedPriority.color).opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
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

#Preview {
    ActivityEditView()
        .modelContainer(for: ActivityLog.self, inMemory: true)
}

#Preview {
    ActivityEditView()
        .modelContainer(for: ActivityLog.self, inMemory: true)
} 