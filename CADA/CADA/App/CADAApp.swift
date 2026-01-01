import SwiftUI
import SwiftData

@main
struct CADAApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Habit.self,
                HabitEntry.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
