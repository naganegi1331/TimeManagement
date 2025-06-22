//
//  AppUsageReportView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/22.
//

import SwiftUI
import DeviceActivity

struct AppUsageReportView: View {
    let selectedDate: Date
    
    @State private var filter: DeviceActivityFilter
    
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
        VStack(spacing: 16) {
            // 総使用時間レポート
            VStack(spacing: 12) {
                Text("総使用時間")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                DeviceActivityReport(.totalActivity, filter: filter)
                    .frame(height: 80)
            }
            .padding(16)
            .background(Material.regularMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // アプリ別使用時間レポート
            VStack(spacing: 12) {
                Text("アプリ別使用時間")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                DeviceActivityReport(.appUsage, filter: filter)
                    .frame(minHeight: 200)
            }
            .padding(16)
            .background(Material.regularMaterial)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
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
    AppUsageReportView(selectedDate: Date())
} 