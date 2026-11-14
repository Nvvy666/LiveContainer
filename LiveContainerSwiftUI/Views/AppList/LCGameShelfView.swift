import SwiftUI

/// Console-style shelf: a large focused panel plus a strip of thumbnails.
/// Long-press a tile for 卸载.
struct LCGameShelfView: View {
    let apps: [LCAppModel]
    var onDelete: ((LCAppModel) -> Void)? = nil

    @State private var selectedIndex: Int = 0
    @State private var launching: String? = nil

    private var selected: LCAppModel? {
        apps.indices.contains(selectedIndex) ? apps[selectedIndex] : apps.first
    }

    var body: some View {
        VStack(spacing: 26) {
            hero
            strip
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            Color.black

            if let icon = selected?.appInfo.iconIsDarkIcon(false) {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 470)
                    .blur(radius: 55)
                    .opacity(0.45)
                    .clipped()
            }

            LinearGradient(
                colors: [Color.black.opacity(0.10), Color.black.opacity(0.94)],
                startPoint: .top, endPoint: .bottom)

            HStack(alignment: .bottom, spacing: 34) {
                cover(selected, size: 230, radius: 50)

                VStack(alignment: .leading, spacing: 14) {
                    Text(selected?.displayName ?? "")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(selected?.version ?? "")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))

                    Button {
                        if let app = selected { launch(app) }
                    } label: {
                        HStack(spacing: 10) {
                            if launching == selected?.bundleIdentifier {
                                ProgressView().tint(.black)
                            } else {
                                Image(systemName: "play.fill").font(.system(size: 17, weight: .bold))
                            }
                            Text("开始游戏").font(.system(size: 19, weight: .semibold))
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 34)
                        .padding(.vertical, 15)
                        .background(Color.white, in: Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                }
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 44)
            .padding(.bottom, 40)
        }
        .frame(height: 470)
        .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
        .padding(.horizontal, 40)
        .shadow(color: .white.opacity(0.05), radius: 30, y: 14)
    }

    private var strip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(Array(apps.enumerated()), id: \.offset) { idx, app in
                    Button {
                        withAnimation(.easeOut(duration: 0.18)) { selectedIndex = idx }
                    } label: {
                        cover(app, size: 118, radius: 26)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26, style: .continuous)
                                    .stroke(Color.white.opacity(idx == selectedIndex ? 0.95 : 0.10),
                                            lineWidth: idx == selectedIndex ? 3 : 1)
                            )
                            .opacity(idx == selectedIndex ? 1 : 0.55)
                            .scaleEffect(idx == selectedIndex ? 1.0 : 0.92)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            onDelete?(app)
                        } label: {
                            Label("卸载", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private func cover(_ app: LCAppModel?, size: CGFloat, radius: CGFloat) -> some View {
        if let icon = app?.appInfo.iconIsDarkIcon(false) {
            Image(uiImage: icon)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(Color(white: 0.12))
                .frame(width: size, height: size)
                .overlay(
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: size * 0.32))
                        .foregroundStyle(.white.opacity(0.22))
                )
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
