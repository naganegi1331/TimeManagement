//
//  TimelineView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI
import SwiftData
import DeviceActivity
import FamilyControls

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [ActivityLog]
    @State private var selectedDate = Date()
    @State private var showingAddActivity = false
    @State private var editingActivity: ActivityLog?
    @State private var showingDeviceUsage = false
    
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
                    TimelineEmptyStateView(selectedDate: selectedDate) {
                        showingAddActivity = true
                    }
                } else {
                    List {
                        // アプリ使用時間レポートセクション
                        Section {
                            DeviceUsageCompactView(selectedDate: selectedDate) {
                                showingDeviceUsage = true
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        } header: {
                            Text("デバイス使用時間")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        
                        // 活動記録セクション
                        Section {
                            ForEach(filteredActivities) { activity in
                                ActivityRowView(activity: activity) {
                                    editingActivity = activity
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: deleteActivities)
                        } header: {
                            Text("活動記録")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("時間の家計簿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // デバイス使用時間ボタン
                        Button(action: {
                            showingDeviceUsage = true
                        }) {
                            Image(systemName: "iphone")
                                .font(.title3)
                                .foregroundStyle(.orange)
                        }
                        .accessibilityLabel("デバイス使用時間を確認")
                        
                        // 活動追加ボタン
                        Button(action: {
                            showingAddActivity = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white, .blue)
                        }
                        .accessibilityLabel("新しい活動を追加")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: AnalyticsView()) {
                        Image(systemName: "chart.pie.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                    }
                    .accessibilityLabel("分析画面を開く")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: DailyAppUsageView()) {
                        Image(systemName: "apps.iphone")
                            .font(.title3)
                            .foregroundStyle(.green)
                    }
                    .accessibilityLabel("アプリ使用時間を確認")
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                ActivityEditView(date: selectedDate)
            }
            .sheet(item: $editingActivity) { activity in
                ActivityEditView(activity: activity)
            }
            .sheet(isPresented: $showingDeviceUsage) {
                DeviceUsageDetailView(selectedDate: selectedDate)
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

// MARK: - Timeline Components (moved to separate files)

#Preview {
    TimelineView()
        .modelContainer(for: ActivityLog.self, inMemory: true)
} 