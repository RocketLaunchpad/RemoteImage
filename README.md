# RemoteImage

`RemoteImage` provides a simple interface to asynchronously load images over the network in SwiftUI. It makes use of Apple's built-in `URLCache` for offline caching of images, helping to reduce network usage in your app.

## Integration

Add `https://github.com/RocketLaunchpad/RemoteImage.git` as a package dependency in your XCode project, or add:

```
.package(url: "https://github.com/RocketLaunchpad/RemoteImage.git", from: "1.0.0"),
```

to your `Package.swift` file.

## Usage

Use the `RemoteImage` view to load and display an image from the Internet.

```swift
RemoteImage(url: url) { phase in
    if case .success(let image) = phase {
        // Display the image if successfully loaded 
        image.resizable()
    }
    else {
        // Display a gray placeholder if the image is being loaded or an error occurred
        Color.gray
    }
}
.frame(width: 200, height: 200)
.padding()
```

Or:

```swift
RemoteImage(url: url) { phase in
    switch phase {
    case .empty:
        // Display a progress spinner over a gray background when loading. 
        ZStack {
            Color.gray
            ProgressView()
        }

    case .success(let image):
        // Display the image 
        image.resizable()

    case .failure:
        // Show a gray placeholder if the image couldn't be loaded 
        Color.gray
    }
}
.frame(width: 200, height: 200)
.padding()
```

## Environment

The `RemoteImage` view type uses the `ImageLoader` class to load images. A default `ImageLoader` is provided via the environment. You can provide your own `ImageLoader` via the `\.imageLoader` environment key.

Generally the default `ImageLoader` instance (accessible via `ImageLoader.default`) should be sufficient. Providing a custom `ImageLoader` allows you to change the identifier and log level, as well as the disk cache and in-memory cache sizes.

```swift
import SwiftUI
import RemoteImage

struct ContentView: View {
    var body: some View {
        NavigationView {
            ...
        }
        .environment(\.imageLoader, ImageLoader(identifier: "custom", ...))
    }
}
```
