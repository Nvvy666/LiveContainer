import SwiftUI

struct LCGameShelfView: View {
    let apps: [LCAppModel]
    @State private var launching: String? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 36) {
                ForEach(apps, id: \.self) { app in
                    Button {
                        launch(app)
                    } label: {
                        tile(app)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 28)
        }
    }

    @ViewBuilder
    private func tile(_ app: LCAppModel) -> some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 46, style: .continuous)
                    .fill(Color(white: 0.10))
                    .frame(width: 260, height: 260)
                if let icon = app.appInfo.iconIsDarkIcon(false) {
                    Image(uiImage: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 260, height: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 46, style: .continuous))
                } else {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white.opacity(0.25))
                }
                if launching == app.bundleIdentifier {
                    RoundedRectangle(cornerRadius: 46, style: .continuous)
                        .fill(Color.black.opacity(0.55))
                        .frame(width: 260, height: 260)
                    ProgressView().tint(.white)
                }
            }
            .shadow(color: .white.opacity(0.06), radius: 24, y: 10)
            Text(app.displayName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: 300)
        }
    }

    private func launch(_ app: LCAppModel) {
        launching = app.bundleIdentifier
        Task {
            do { try await app.runApp(multitask: false) } catch { }
            launching = nil
        }
    }
}
