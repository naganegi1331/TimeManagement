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

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [ActivityLog]
    @State private var selectedDate = Date()
    @State private var authorizationCenter = AuthorizationCenter.shared
    @State private var isAuthorized = false
    
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
                            
                            Spacer()
                        }
                        
                        DatePicker(
                            "分析対象日",
                            selection: $selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.compact)
                        .labelsHidden()
                    }
                    .padding(20)
                    .background(Material.regularMaterial)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                }
                
                // Statistics Summary
                StatisticsSummaryView(activities: filteredActivities)
                    .padding(.horizontal, 20)
                
                // Category Analysis with Quadrant Colors
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "chart.pie.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        Text("カテゴリ別時間分析（象限別）")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    Text("重要度・緊急度の象限ごとにカテゴリを色分け表示（タップで詳細分析）")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                    
                    if filteredActivities.isEmpty {
                        // Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            
                            Text("データがありません")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Text("この日の活動記録がありません")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 40)
                        .frame(maxWidth: .infinity)
                        .background(Material.regularMaterial)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                    } else {
                        CategoryPieChartView(activities: filteredActivities)
                            .frame(height: 400)
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
                    
                    if isAuthorized {
                        AppUsageReportView(selectedDate: selectedDate)
                            .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "lock.shield")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            
                            Text("アプリ使用時間を表示するには認証が必要です")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("認証を許可") {
                                requestAuthorization()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 40)
                        .frame(maxWidth: .infinity)
                        .background(Material.regularMaterial)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .onAppear {
            checkAuthorizationStatus()
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