//
//  AnalyticsEmptyStateView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/19.
//

import SwiftUI

struct AnalyticsEmptyStateView: View {
    let selectedDate: Date
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "chart.bar.doc.horizontal")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue.gradient)
                
                VStack(spacing: 8) {
                    Text("分析データがありません")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("\(dateFormatter.string(from: selectedDate))の活動記録がありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            
            VStack(spacing: 12) {
                Text("他の日付を選択するか、活動を記録してください")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    AnalyticsEmptyStateView(selectedDate: Date())
        .padding()
}