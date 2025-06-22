//
//  TimelineEmptyStateView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/19.
//

import SwiftUI

struct TimelineEmptyStateView: View {
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

#Preview {
    TimelineEmptyStateView(selectedDate: Date()) {
        print("Add activity tapped")
    }
    .padding()
}