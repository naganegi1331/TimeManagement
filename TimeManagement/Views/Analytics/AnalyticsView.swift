//
//  AnalyticsView.swift
//  TimeManagement
//
//  Created by Hiroki Kashihara on 2025/06/15.
//

import SwiftUI
import SwiftData
import DeviceActivity
import FamilyControls

extension DeviceActivityReport.Context {
    static let totalActivity = Self("TotalActivity")
    static let appUsage = Self("AppUsage")
    static let categoryUsage = Self("CategoryUsage")
}

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [ActivityLog]
    @State private var selectedDate = Date()
    @State private var authorizationCenter = AuthorizationCenter.shared
    @State private var isAuthorized = false
    @State private var showingAuthorizationAlert = false
    @State private var authorizationError: String?
    
    private var filteredActivities: [ActivityLog] {
        let calendar = Calendar.current
        return activities.filter { activity in
            calendar.isDate(activity.startTime, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Enhanced Header with Date Selection
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("時間分析")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text("活動データの詳細な分析")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    // Date Selection Card
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.headline)
                                .foregroundStyle(.blue)
                            
                            Text("分析対象日")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(Material.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 20)
                }
                
                if filteredActivities.isEmpty {
                    AnalyticsEmptyStateView(selectedDate: selectedDate)
                        .frame(minHeight: 300)
                        .padding(.horizontal, 20)
                } else {
                    VStack(spacing: 24) {
                        // Quick Stats Overview
                        QuickStatsView(activities: filteredActivities)
                            .padding(.horizontal, 20)
                        
                        // Charts Section
                        VStack(spacing: 20) {
                            // Category Chart by Quadrant
                            AnalyticsCardView(
                                title: "カテゴリ別時間分析（象限別）",
                                icon: "chart.pie.fill",
                                description: "重要度・緊急度の象限ごとにカテゴリを色分け表示（タップで詳細分析）"
                            ) {
                                CategoryPieChartView(activities: filteredActivities)
                                    .frame(height: 400)
                            }
                            
                            // Detailed Statistics
                            AnalyticsCardView(
                                title: "詳細統計",
                                icon: "list.bullet.rectangle.fill",
                                description: "カテゴリと優先度の詳細分析"
                            ) {
                                EnhancedSummaryStatsView(activities: filteredActivities)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // アプリ使用時間レポート
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "apps.iphone")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        
                        Text("アプリ使用時間レポート")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Text("デバイスのアプリ使用時間を表示")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                    
                    // デバイス使用時間確認画面への遷移ボタン
                    HStack(spacing: 12) {
                        if isAuthorized {
                            NavigationLink(destination: DeviceUsageDetailView(selectedDate: selectedDate)) {
                                DeviceUsageNavigationButton(isAuthorized: true)
                            }
                        } else {
                            Button(action: requestAuthorization) {
                                DeviceUsageNavigationButton(isAuthorized: false)
                            }
                        }
                        
                        // 新しいDailyAppUsageViewへの遷移ボタン
                        NavigationLink(destination: DailyAppUsageView()) {
                            HStack(spacing: 8) {
                                Image(systemName: "apps.iphone")
                                    .font(.title2)
                                    .foregroundStyle(.green)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("アプリ使用時間")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.primary)
                                    
                                    Text("日別アプリ使用状況")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .background(Material.regularMaterial)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                    if isAuthorized {
                        // 簡易プレビュー（認証済みの場合のみ）
                        AppUsageReportView(selectedDate: selectedDate)
                            .frame(height: 200)
                            .padding(.horizontal, 20)
                    } else {
                        // 認証が必要な旨を表示
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .font(.headline)
                                    .foregroundStyle(.orange)
                                
                                Text("認証が必要です")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            
                            Text("詳細画面でFamily Controlsの認証を行ってください")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(16)
                        .background(Material.regularMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("分析")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            checkAuthorizationStatus()
        }
        .alert("認証エラー", isPresented: $showingAuthorizationAlert) {
            Button("OK") { }
        } message: {
            Text(authorizationError ?? "Family Controlsの認証に失敗しました")
        }
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
                    authorizationError = "認証に失敗しました: \(error.localizedDescription)"
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

// MARK: - Enhanced Analytics Components (moved to separate files)

#Preview {
    NavigationView {
        AnalyticsView()
    }
    .modelContainer(for: ActivityLog.self, inMemory: true)
} 