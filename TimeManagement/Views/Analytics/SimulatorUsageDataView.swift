//
//  SimulatorUsageDataView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/22.
//

import SwiftUI

struct SimulatorUsageDataView: View {
    let selectedDate: Date
    
    var sampleApps: [SampleAppUsage] = [
        SampleAppUsage(name: "Safari", category: "生産性", usage: "2時間 45分", icon: "safari.fill", color: .blue),
        SampleAppUsage(name: "メール", category: "生産性", usage: "1時間 20分", icon: "envelope.fill", color: .green),
        SampleAppUsage(name: "メッセージ", category: "ソーシャル", usage: "45分", icon: "message.fill", color: .green),
        SampleAppUsage(name: "写真", category: "エンターテイメント", usage: "30分", icon: "photo.fill", color: .orange),
        SampleAppUsage(name: "設定", category: "ユーティリティ", usage: "15分", icon: "gearshape.fill", color: .gray)
    ]
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // ヘッダー
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    Text("シミュレーター環境")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                
                Text("実機では実際のアプリ使用時間が表示されます")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            
            // サンプルデータ
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("サンプルデータ")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                LazyVStack(spacing: 12) {
                    ForEach(sampleApps) { app in
                        HStack(spacing: 16) {
                            Image(systemName: app.icon)
                                .font(.title2)
                                .foregroundStyle(app.color)
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(app.name)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Text(app.category)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(app.usage)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Material.regularMaterial)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

struct SampleAppUsage: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let usage: String
    let icon: String
    let color: Color
}

#Preview {
    @Previewable @State var date = Date()
    SimulatorUsageDataView(selectedDate: date)
        .padding()
} 