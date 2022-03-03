# RemoteImage

## Integration

Add `https://github.com/pwc3/RemoteImage.git` as a package dependency in your XCode project, or add:

```
.package(url: "https://github.com/pwc3/RemoteImage.git", from: "1.0.0"),
```

to your `Package.swift` file.

## Usage

Use the `RemoteImage` view to load and display an image from the Internet.

```
import RemoteImage

...

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

```
import RemoteImage

...

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

The `RemoteImage` view type uses the `ImageLoader` class to load images. A default `ImageLoader` is provided via the environment. You can provide your own `ImageLoader` (with a different cache size) via the `\.imageLoader` environment key.

```
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
