//
//  DeviceUsageTimelineView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/19.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct DeviceUsageCompactView: View {
    let selectedDate: Date
    let onTapDetail: () -> Void
    @State private var filter: DeviceActivityFilter
    @State private var authorizationCenter = AuthorizationCenter.shared
    @State private var isAuthorized = false
    
    init(selectedDate: Date, onTapDetail: @escaping () -> Void) {
        self.selectedDate = selectedDate
        self.onTapDetail = onTapDetail
        
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
        Button(action: onTapDetail) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "iphone")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    
                    Text("デバイス使用時間")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
                
                if isAuthorized {
                    DeviceActivityReport(.totalActivity, filter: filter)
                        .frame(height: 60)
                        .cornerRadius(8)
                } else {
                    HStack {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                        
                        Text("認証が必要です")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    .frame(height: 60)
                    .padding(.horizontal, 16)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Material.regularMaterial)
                    .shadow(
                        color: .black.opacity(0.05),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
        .accessibilityLabel("デバイス使用時間を確認")
        .accessibilityHint("タップして詳細を表示")
        .onAppear {
            checkAuthorizationStatus()
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
    
    private func checkAuthorizationStatus() {
        switch authorizationCenter.authorizationStatus {
        case .approved:
            isAuthorized = true
        default:
            isAuthorized = false
        }
    }
}

#Preview {
    DeviceUsageCompactView(selectedDate: Date()) {
        print("Device usage tapped")
    }
    .padding()
}