# COWKit

COWKit is a copy-on-write helper library for Swift. It offers a simple
property wrapper `Cowable` to optimize caller-site performance and memory
usage of large monolithic data structures.

## Usage

You can simply wrap a property of a large struct with `@Cowable`. Then all
things done.

Before:

```swift
struct Record {

  var title: String

  var subtitle: String

  var releaseDate: Date

  var tracks: [Tracks]

}

struct Tracks {

  var trackName: String

  var artist: String
  
  var length: TimeInterval

}

struct Foo {

  var record: Record

  init(record: Record) {
    self.record = record
  }

}

let foo = Foo(record: Record)

```

After:

```swift
struct Record {

  var title: String

  var subtitle: String

  var releaseDate: Date

  @Cowable // Add @Cowable at here
  var tracks: [Tracks]

}

struct Tracks {

  var trackName: String

  var artist: String
  
  var length: TimeInterval

}

struct Foo {

  @Cowable // Add @Cowable at here
  var record: Record

  init(record: Record) {
    // You initializer may need a little bit of tweaks if you choose
    // explicitly declare the memberwise initializer.
    self._record = Cowable(wrappedValue: record)
  }

}

let foo = Foo(record: Record)

```

## License

MIT
