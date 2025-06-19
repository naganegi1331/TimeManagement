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
    @State private var showingTimeInput = false
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
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
                
                HStack(spacing: 12) {
                    // Date picker for date only
                    DatePicker("", selection: $selection, displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    
                    // Custom time picker button
                    Button(action: {
                        showingTimeInput = true
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            
                            Text(timeFormatter.string(from: selection))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .sheet(isPresented: $showingTimeInput) {
            FifteenMinuteTimePickerView(selectedTime: $selection)
        }
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

// MARK: - Fifteen Minute Time Picker

struct FifteenMinuteTimePickerView: View {
    @Binding var selectedTime: Date
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedHour: Int = 0
    @State private var selectedMinute: Int = 0
    
    // 15分単位の選択肢
    private let minutes = [0, 15, 30, 45]
    private let hours = Array(0...23)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("時刻を選択")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("15分単位で設定できます")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Time Picker
                VStack(spacing: 24) {
                    // Current Time Display
                    HStack(spacing: 4) {
                        Text(String(format: "%02d", selectedHour))
                            .font(.system(size: 48, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Text(":")
                            .font(.system(size: 48, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        
                        Text(String(format: "%02d", selectedMinute))
                            .font(.system(size: 48, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    
                    // Pickers
                    HStack(spacing: 40) {
                        // Hour Picker
                        VStack(spacing: 12) {
                            Text("時")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Picker("時", selection: $selectedHour) {
                                ForEach(hours, id: \.self) { hour in
                                    Text(String(format: "%02d", hour))
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 150)
                        }
                        
                        // Minute Picker
                        VStack(spacing: 12) {
                            Text("分")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                            
                            Picker("分", selection: $selectedMinute) {
                                ForEach(minutes, id: \.self) { minute in
                                    Text(String(format: "%02d", minute))
                                        .font(.title3)
                                        .fontWeight(.medium)
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80, height: 150)
                        }
                    }
                    
                    // Quick Time Buttons
                    VStack(spacing: 12) {
                        Text("よく使う時間")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                            ForEach(getQuickTimes(), id: \.0) { hour, minute in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedHour = hour
                                        selectedMinute = minute
                                    }
                                }) {
                                    Text(String(format: "%02d:%02d", hour, minute))
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.blue)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            selectedHour == hour && selectedMinute == minute ?
                                            Color.blue.opacity(0.15) : Color(.systemGray6),
                                            in: Capsule()
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .navigationTitle("時刻設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        updateSelectedTime()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                }
            }
        }
        .onAppear {
            initializeTime()
        }
    }
    
    private func initializeTime() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: selectedTime)
        selectedHour = components.hour ?? 0
        
        // 15分単位に丸める
        let originalMinute = components.minute ?? 0
        selectedMinute = roundToNearestFifteenMinutes(originalMinute)
    }
    
    private func roundToNearestFifteenMinutes(_ minute: Int) -> Int {
        let remainder = minute % 15
        if remainder < 8 {
            return minute - remainder
        } else {
            return minute + (15 - remainder)
        }
    }
    
    private func updateSelectedTime() {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedTime)
        components.hour = selectedHour
        components.minute = selectedMinute
        
        if let newDate = calendar.date(from: components) {
            selectedTime = newDate
        }
    }
    
    private func getQuickTimes() -> [(Int, Int)] {
        return [
            (9, 0), (10, 0), (12, 0), (13, 0),
            (14, 0), (15, 0), (17, 0), (18, 0),
            (19, 0), (20, 0), (21, 0), (22, 0)
        ]
    }
}

#Preview {
    ActivityEditView()
        .modelContainer(for: ActivityLog.self, inMemory: true)
} 