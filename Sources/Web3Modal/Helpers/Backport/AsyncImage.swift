import SwiftUI

@available(iOS, deprecated: 14.0)
public extension UIColor {

    convenience init(_ color: Color) {
        self.init(
            red: color.redComponent ?? 0,
            green: color.greenComponent ?? 0,
            blue: color.blueComponent ?? 0,
            alpha: color.opacityComponent ?? 0
        )
    }
}

@available(iOS, deprecated: 14.0)
private extension SwiftUI.Color {
    var redComponent: Double? {
        let val = description
        guard val.hasPrefix("#") else { return nil }
        let r1 = val.index(val.startIndex, offsetBy: 1)
        let r2 = val.index(val.startIndex, offsetBy: 2)
        return Double(Int(val[r1...r2], radix: 16)!) / 255.0
    }

    var greenComponent: Double? {
        let val = description
        guard val.hasPrefix("#") else { return nil }
        let g1 = val.index(val.startIndex, offsetBy: 3)
        let g2 = val.index(val.startIndex, offsetBy: 4)
        return Double(Int(val[g1...g2], radix: 16)!) / 255.0
    }

    var blueComponent: Double? {
        let val = description
        guard val.hasPrefix("#") else { return nil }
        let b1 = val.index(val.startIndex, offsetBy: 5)
        let b2 = val.index(val.startIndex, offsetBy: 6)
        return Double(Int(val[b1...b2], radix: 16)!) / 255.0
    }

    var opacityComponent: Double? {
        let val = description
        guard val.hasPrefix("#") else { return nil }
        let b1 = val.index(val.startIndex, offsetBy: 7)
        let b2 = val.index(val.startIndex, offsetBy: 8)
        return Double(Int(val[b1...b2], radix: 16)!) / 255.0
    }
}

@available(iOS, deprecated: 15.0)
extension Backport where Wrapped == Any {

    /// Loads and displays an image from the specified URL.
    ///
    /// Until the image loads, SwiftUI displays a default placeholder. When
    /// the load operation completes successfully, SwiftUI updates the
    /// view to show the loaded image. If the operation fails, SwiftUI
    /// continues to display the placeholder. The following example loads
    /// and displays an icon from an example server:
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/icon.png"))
    ///
    /// If you want to customize the placeholder or apply image-specific
    /// modifiers --- like ``Image/resizable(capInsets:resizingMode:)`` ---
    /// to the loaded image, use the ``init(url:scale:content:placeholder:)``
    /// initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    @ViewBuilder
    static func AsyncImage(url: URL?, scale: CGFloat = 1) -> some View {
        _AsyncImage(url: url, scale: scale)
    }

    /// Loads and displays a modifiable image from the specified URL using
    /// a custom placeholder until the image loads.
    ///
    /// Until the image loads, SwiftUI displays the placeholder view that
    /// you specify. When the load operation completes successfully, SwiftUI
    /// updates the view to show content that you specify, which you
    /// create using the loaded image. For example, you can show a green
    /// placeholder, followed by a tiled version of the loaded image:
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { image in
    ///         image.resizable(resizingMode: .tile)
    ///     } placeholder: {
    ///         Color.green
    ///     }
    ///
    /// If the load operation fails, SwiftUI continues to display the
    /// placeholder. To be able to display a different view on a load error,
    /// use the ``init(url:scale:transaction:content:)`` initializer instead.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - content: A closure that takes the loaded image as an input, and
    ///     returns the view to show. You can return the image directly, or
    ///     modify it as needed before returning it.
    ///   - placeholder: A closure that returns the view to show until the
    ///     load operation completes successfully.
    @ViewBuilder
    static func AsyncImage<I: View, P: View>(url: URL?, scale: CGFloat = 1, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) -> some View {
        _AsyncImage(url: url, scale: scale, content: content, placeholder: placeholder)
    }

    /// Loads and displays a modifiable image from the specified URL in phases.
    ///
    /// If you set the asynchronous image's URL to `nil`, or after you set the
    /// URL to a value but before the load operation completes, the phase is
    /// ``AsyncImagePhase/empty``. After the operation completes, the phase
    /// becomes either ``AsyncImagePhase/failure(_:)`` or
    /// ``AsyncImagePhase/success(_:)``. In the first case, the phase's
    /// ``AsyncImagePhase/error`` value indicates the reason for failure.
    /// In the second case, the phase's ``AsyncImagePhase/image`` property
    /// contains the loaded image. Use the phase to drive the output of the
    /// `content` closure, which defines the view's appearance:
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    ///         if let image = phase.image {
    ///             image // Displays the loaded image.
    ///         } else if phase.error != nil {
    ///             Color.red // Indicates an error.
    ///         } else {
    ///             Color.blue // Acts as a placeholder.
    ///         }
    ///     }
    ///
    /// To add transitions when you change the URL, apply an identifier to the
    /// ``AsyncImage``.
    ///
    /// - Parameters:
    ///   - url: The URL of the image to display.
    ///   - scale: The scale to use for the image. The default is `1`. Set a
    ///     different value when loading images designed for higher resolution
    ///     displays. For example, set a value of `2` for an image that you
    ///     would name with the `@2x` suffix if stored in a file on disk.
    ///   - transaction: The transaction to use when the phase changes.
    ///   - content: A closure that takes the load phase as an input, and
    ///     returns the view to display for the specified phase.
    @ViewBuilder
    static func AsyncImage<Content: View>(url: URL?, scale: CGFloat = 1, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) -> some View {
        _AsyncImage(url: url, scale: scale, transaction: transaction, content: content)
    }

    /// The current phase of the asynchronous image loading operation.
    ///
    /// When you create an ``AsyncImage`` instance with the
    /// ``AsyncImage/init(url:scale:transaction:content:)`` initializer, you define
    /// the appearance of the view using a `content` closure. SwiftUI calls the
    /// closure with a phase value at different points during the load operation
    /// to indicate the current state. Use the phase to decide what to draw.
    /// For example, you can draw the loaded image if it exists, a view that
    /// indicates an error, or a placeholder:
    ///
    ///     AsyncImage(url: URL(string: "https://example.com/icon.png")) { phase in
    ///         if let image = phase.image {
    ///             image // Displays the loaded image.
    ///         } else if phase.error != nil {
    ///             Color.red // Indicates an error.
    ///         } else {
    ///             Color.blue // Acts as a placeholder.
    ///         }
    ///     }
    enum AsyncImagePhase {
        /// No image is loaded.
        case empty
        /// An image succesfully loaded.
        case success(Image)
        /// An image failed to load with an error.
        case failure(Error)

        /// The loaded image, if any.
        public var image: Image? {
            guard case let .success(image) = self else { return nil }
            return image
        }

        /// The error that occurred when attempting to load an image, if any.
        public var error: Error? {
            guard case let .failure(error) = self else { return nil }
            return error
        }
    }

    // An iOS 13+ async/await backport implementation
    private struct _AsyncImage<Content: View>: View {
        @State private var phase: AsyncImagePhase = .empty

        var url: URL?
        var scale: CGFloat = 1
        var transaction: Transaction = .init()
        var content: (Backport<Any>.AsyncImagePhase) -> Content

        public var body: some View {
            ZStack {
                content(phase)
            }
            .backport.task(id: url) {
                do {
                    guard !Task.isCancelled, let url = url else { return }
                    let (data, _) = try await URLSession.shared.data(from: url)
                    guard !Task.isCancelled else { return }

                    #if os(macOS)
                    if let image = NSImage(data: data) {
                        withTransaction(transaction) {
                            phase = .success(Image(nsImage: image))
                        }
                    }
                    #else
                    if let image = UIImage(data: data, scale: scale) {
                        withTransaction(transaction) {
                            phase = .success(Image(uiImage: image))
                        }
                    }
                    #endif
                } catch {
                    phase = .failure(error)
                }
            }
        }

        init(url: URL?, scale: CGFloat = 1) where Content == AnyView {
            self.url = url
            self.scale = scale
            self.content = { AnyView($0.image) }
        }

        init<I, P>(url: URL?, scale: CGFloat = 1, @ViewBuilder content: @escaping (Image) -> I, @ViewBuilder placeholder: @escaping () -> P) where Content == _ConditionalContent<I, P> {
            self.url = url
            self.scale = scale
            self.transaction = Transaction()
            self.content = { phase -> _ConditionalContent<I, P> in
                if let image = phase.image {
                    return ViewBuilder.buildEither(first: content(image))
                } else {
                    return ViewBuilder.buildEither(second: placeholder())
                }
            }
        }

        init(url: URL?, scale: CGFloat = 1, transaction: Transaction = Transaction(), @ViewBuilder content: @escaping (Backport<Any>.AsyncImagePhase) -> Content) {
            self.url = url
            self.scale = scale
            self.transaction = transaction
            self.content = content
        }
    }

}

import SwiftUI
import Combine

@available(iOS, deprecated: 15.0)
@available(macOS, deprecated: 12.0)
@available(tvOS, deprecated: 15.0)
@available(watchOS, deprecated: 8.0)
extension Backport where Wrapped: View {

    /// Adds an asynchronous task to perform when this view appears.
    ///
    /// Use this modifier to perform an asynchronous task with a lifetime that
    /// matches that of the modified view. If the task doesn't finish
    /// before SwiftUI removes the view or the view changes identity, SwiftUI
    /// cancels the task.
    ///
    /// Use the `await` keyword inside the task to
    /// wait for an asynchronous call to complete.
    ///
    ///     let url = URL(string: "https://example.com")!
    ///     @State private var message = "Loading..."
    ///
    ///     var body: some View {
    ///         Text(message)
    ///             .task {
    ///                 do {
    ///                     var receivedLines = [String]()
    ///                     for try await line in url.lines {
    ///                         receivedLines.append(line)
    ///                         message = "Received \(receivedLines.count) lines"
    ///                     }
    ///                 } catch {
    ///                     message = "Failed to load"
    ///                 }
    ///             }
    ///     }
    ///
    /// When each new line arrives, the body of the `for`-`await`-`in`
    /// loop stores the line in an array of strings and updates the content of the
    /// text view to report the latest line count.
    ///
    /// - Parameters:
    ///   - priority: The task priority to use when creating the asynchronous
    ///     task. The default priority is `.userInitiated`
    ///   - action: A closure that SwiftUI calls as an asynchronous task
    ///     when the view appears. SwiftUI automatically cancels the task
    ///     if the view disappears before the action completes.
    ///
    ///
    /// - Returns: A view that runs the specified action asynchronously when
    ///   the view appears.
    @ViewBuilder
    func task(priority: TaskPriority = .userInitiated, @_inheritActorContext _ action: @escaping @Sendable () async -> Void) -> some View {
        wrapped.modifier(
            TaskModifier(
                id: 0,
                priority: priority,
                action: action
            )
        )
    }

    /// Adds a task to perform when this view appears or when a specified
    /// value changes.
    ///
    /// This method behaves like ``View/task(priority:_:)``, except that it also
    /// cancels and recreates the task when a specified value changes. To detect
    /// a change, the modifier tests whether a new value for the `id` parameter
    /// equals the previous value. For this to work,
    /// the value's type must conform to the `Equatable` protocol.
    ///
    /// For example, if you define an equatable `Server` type that posts custom
    /// notifications whenever its state changes --- for example, from _signed
    /// out_ to _signed in_ --- you can use the task modifier to update
    /// the contents of a ``Text`` view to reflect the state of the
    /// currently selected server:
    ///
    ///     Text(status ?? "Signed Out")
    ///         .task(id: server) {
    ///             let sequence = NotificationCenter.default.notifications(
    ///                 named: .didChangeStatus,
    ///                 object: server)
    ///             for try await notification in sequence {
    ///                 status = notification.userInfo["status"] as? String
    ///             }
    ///         }
    ///
    /// Elsewhere, the server defines a custom `didUpdateStatus` notification:
    ///
    ///     extension NSNotification.Name {
    ///         static var didUpdateStatus: NSNotification.Name {
    ///             NSNotification.Name("didUpdateStatus")
    ///         }
    ///     }
    ///
    /// The server then posts a notification of this type whenever its status
    /// changes, like after the user signs in:
    ///
    ///     let notification = Notification(
    ///         name: .didUpdateStatus,
    ///         object: self,
    ///         userInfo: ["status": "Signed In"])
    ///     NotificationCenter.default.post(notification)
    ///
    /// The task attached to the ``Text`` view gets and displays the status
    /// value from the notification's user information dictionary. When the user
    /// chooses a different server, SwiftUI cancels the task and creates a new
    /// one, which then starts waiting for notifications from the new server.
    ///
    /// - Parameters:
    ///   - id: The value to observe for changes. The value must conform
    ///     to the `Equatable` protocol.
    ///   - priority: The task priority to use when creating the asynchronous
    ///     task. The default priority is `.userInitiated`
    ///   - action: A closure that SwiftUI calls as an asynchronous task
    ///     when the view appears. SwiftUI automatically cancels the task
    ///     if the view disappears before the action completes. If the
    ///     `id` value changes, SwiftUI cancels and restarts the task.
    ///
    /// - Returns: A view that runs the specified action asynchronously when
    ///   the view appears, or restarts the task with the `id` value changes.
    @ViewBuilder
    func task<T: Equatable>(id: T, priority: TaskPriority = .userInitiated, @_inheritActorContext _ action: @escaping @Sendable () async -> Void) -> some View {
        wrapped.modifier(
            TaskModifier(
                id: id,
                priority: priority,
                action: action
            )
        )
    }

}

private struct TaskModifier<ID: Equatable>: ViewModifier {

    var id: ID
    var priority: TaskPriority
    var action: @Sendable () async -> Void

    @State private var task: Task<Void, Never>?
    @State private var publisher = PassthroughSubject<(), Never>()

    init(id: ID, priority: TaskPriority, action: @Sendable @escaping () async -> Void) {
        self.id = id
        self.priority = priority
        self.action = action
    }

    func body(content: Content) -> some View {
        content
            .backport.onChange(of: id) { _ in
                publisher.send()
            }
            .onReceive(publisher) { _ in
                task?.cancel()
                task = Task(priority: priority, operation: action)
            }
            .onAppear {
                task?.cancel()
                task = Task(priority: priority, operation: action)
            }
            .onDisappear {
                task?.cancel()
                task = nil
            }
    }

}

@available(iOS, deprecated: 14.0)
@available(macOS, deprecated: 11.0)
@available(tvOS, deprecated: 14.0)
@available(watchOS, deprecated: 7.0)
extension Backport where Wrapped: View {

    /// Adds a modifier for this view that fires an action when a specific
    /// value changes.
    ///
    /// `onChange` is called on the main thread. Avoid performing long-running
    /// tasks on the main thread. If you need to perform a long-running task in
    /// response to `value` changing, you should dispatch to a background queue.
    ///
    /// The new value is passed into the closure.
    ///
    /// - Parameters:
    ///   - value: The value to observe for changes
    ///   - action: A closure to run when the value changes.
    ///   - newValue: The new value that changed
    ///
    /// - Returns: A view that fires an action when the specified value changes.
    @ViewBuilder
    func onChange<Value: Equatable>(of value: Value, perform action: @escaping (Value) -> Void) -> some View {
        if #available(iOS 14, tvOS 14, macOS 11, watchOS 7, *) {
            wrapped.onChange(of: value, perform: action)
        } else {
            wrapped.modifier(ChangeModifier(value: value, action: action))
        }
    }

}

private struct ChangeModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let action: (Value) -> Void

    @State var oldValue: Value?

    init(value: Value, action: @escaping (Value) -> Void) {
        self.value = value
        self.action = action
        _oldValue = .init(initialValue: value)
    }

    func body(content: Content) -> some View {
        content
            .onReceive(Just(value)) { newValue in
                guard newValue != oldValue else { return }
                action(newValue)
                oldValue = newValue
            }
    }
}
