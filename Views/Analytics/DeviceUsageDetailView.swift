//
//  DeviceUsageDetailView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/22.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct DeviceUsageDetailView: View {
    let selectedDate: Date
    @State private var filter: DeviceActivityFilter
    @Environment(\.dismiss) private var dismiss
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dateInterval = DateInterval(start: startOfDay, end: endOfDay)
        
        self._filter = State(initialValue: DeviceActivityFilter(
            segment: .daily(during: dateInterval),
            users: .all,
            devices: .init([.iPhone, .iPad])
        ))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // ヘッダー
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("デバイス使用時間")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                
                                Text(selectedDate, style: .date)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 総使用時間セクション
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "clock.fill")
                                .font(.headline)
                                .foregroundStyle(.green)
                            
                            Text("総使用時間")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        DeviceActivityReport(.totalActivity, filter: filter)
                            .frame(height: 120)
                            .padding(.horizontal, 20)
                            .background(Material.regularMaterial)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 20)
                    }
                    
                    // アプリ別使用時間セクション
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "apps.iphone")
                                .font(.headline)
                                .foregroundStyle(.blue)
                            
                            Text("アプリ別使用時間")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        Text("全てのアプリの詳細な使用時間を表示")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        DeviceActivityReport(.appUsage, filter: filter)
                            .frame(minHeight: 400)
                            .padding(.horizontal, 20)
                            .background(Material.regularMaterial)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 20)
                    }
                    
                    // カテゴリ別使用時間セクション
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .font(.headline)
                                .foregroundStyle(.orange)
                            
                            Text("カテゴリ別使用時間")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        
                        Text("アプリをカテゴリごとにグループ化して表示")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 20)
                        
                        DeviceActivityReport(.categoryUsage, filter: filter)
                            .frame(minHeight: 300)
                            .padding(.horizontal, 20)
                            .background(Material.regularMaterial)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
            .navigationTitle("デバイス使用時間")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: selectedDate) { _, newDate in
            updateFilter(for: newDate)
        }
    }
    
    private func updateFilter(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let dateInterval = DateInterval(start: startOfDay, end: endOfDay)
        
        filter = DeviceActivityFilter(
            segment: .daily(during: dateInterval),
            users: .all,
            devices: .init([.iPhone, .iPad])
        )
    }
}

#Preview {
    DeviceUsageDetailView(selectedDate: Date())
} 