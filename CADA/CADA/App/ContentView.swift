import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var showingDailyEntry = false
    @Namespace private var animation

    enum Tab: String, CaseIterable {
        case dashboard = "Dashboard"
        case habits = "Habits"
        case statistics = "Statistics"
        case settings = "Settings"

        var icon: String {
            switch self {
            case .dashboard: return "square.grid.2x2"
            case .habits: return "checkmark.circle"
            case .statistics: return "chart.bar.xaxis"
            case .settings: return "gearshape"
            }
        }

        var selectedIcon: String {
            switch self {
            case .dashboard: return "square.grid.2x2.fill"
            case .habits: return "checkmark.circle.fill"
            case .statistics: return "chart.bar.xaxis.ascending"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        ZStack {
            // Dynamic background gradient
            LiquidGlassBackground()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Main content area
                TabView(selection: $selectedTab) {
                    DashboardView(showingDailyEntry: $showingDailyEntry)
                        .tag(Tab.dashboard)

                    HabitsListView()
                        .tag(Tab.habits)

                    StatisticsView()
                        .tag(Tab.statistics)

                    SettingsView()
                        .tag(Tab.settings)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom tab bar with liquid glass effect
                CustomTabBar(selectedTab: $selectedTab, animation: animation)
            }
        }
        .sheet(isPresented: $showingDailyEntry) {
            DailyEntryView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.ultraThinMaterial)
        }
        .onAppear {
            NotificationService.shared.requestAuthorization()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    var animation: Namespace.ID

    var body: some View {
        HStack(spacing: 0) {
            ForEach(ContentView.Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    animation: animation
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = tab
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
    }
}

struct TabBarButton: View {
    let tab: ContentView.Tab
    let isSelected: Bool
    var animation: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22, weight: .medium))
                    .symbolEffect(.bounce, value: isSelected)

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                if isSelected {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(0.6),
                                    Color.accentColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .matchedGeometryEffect(id: "TAB", in: animation)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitEntry.self], inMemory: true)
}
