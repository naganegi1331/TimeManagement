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
    @State private var authorizationCenter = AuthorizationCenter.shared
    @State private var isAuthorized = false
    @State private var showingAuthorizationAlert = false
    
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
                    
                    // 認証状態チェックとメッセージ
                    if !isAuthorized {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.orange)
                                
                                Text("認証が必要です")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("デバイス使用時間を表示するには、以下の条件が必要です：")
                                    .font(.headline)
                                    .padding(.horizontal, 20)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "1.circle.fill")
                                            .foregroundStyle(.blue)
                                        Text("Family Controlsの認証")
                                    }
                                    
                                    HStack {
                                        Image(systemName: "2.circle.fill")
                                            .foregroundStyle(.blue)
                                        Text("実機での実行（シミュレーターでは制限あり）")
                                    }
                                    
                                    HStack {
                                        Image(systemName: "3.circle.fill")
                                            .foregroundStyle(.blue)
                                        Text("スクリーンタイムの有効化")
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 16)
                            .background(Material.regularMaterial)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                            
                            Button("認証を試行") {
                                requestAuthorization()
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.horizontal, 20)
                            
                            // シミュレーター環境でのサンプルデータ表示
                            SimulatorUsageDataView(selectedDate: selectedDate)
                                .padding(.horizontal, 20)
                        }
                    } else {
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
                    }
                    
                    if isAuthorized {
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
        .onAppear {
            checkAuthorizationStatus()
        }
        .onChange(of: selectedDate) { _, newDate in
            updateFilter(for: newDate)
        }
        .alert("認証エラー", isPresented: $showingAuthorizationAlert) {
            Button("OK") { }
        } message: {
            Text("Family Controlsの認証に失敗しました。設定アプリでスクリーンタイムが有効になっているか確認してください。")
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
    
    private func requestAuthorization() {
        Task {
            do {
                try await authorizationCenter.requestAuthorization(for: .individual)
                await MainActor.run {
                    checkAuthorizationStatus()
                }
            } catch {
                await MainActor.run {
                    showingAuthorizationAlert = true
                }
                print("Authorization request failed: \(error)")
            }
        }
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
    DeviceUsageDetailView(selectedDate: Date())
} 