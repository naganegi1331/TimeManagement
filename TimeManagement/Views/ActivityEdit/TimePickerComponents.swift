//
//  TimePickerComponents.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//  Refactored: Separated from ActivityEditView.swift for better organization
//

import SwiftUI

// MARK: - Time Picker Row

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