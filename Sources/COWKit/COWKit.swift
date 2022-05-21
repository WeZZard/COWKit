/// A copy-on-write-able container.
@propertyWrapper
@frozen
public struct Cowable<Value> {

    @_transparent
    public var wrappedValue: Value {
        _read {
            yield storage.value
        }
        _modify {
            makeUniquelyReferencedStorage()
            yield &storage.value
        }
    }

    @_transparent
    public var projectedValue: Cowable<Value> {
        _read {
            yield self
        }
        _modify {
            yield &self
        }
    }

    @usableFromInline
    internal var storage: Storage

    @_transparent
    public init(wrappedValue: Value) {
        assert(_canBeClass(Value.self) != 1, "Wrapping a class instance in a copy-on-write container makes no sense.")
        self.storage = Storage(value: wrappedValue)
    }

    @_transparent
    public init(_ cowable: Cowable<Value>) {
        self.storage = cowable.storage
    }

    @_transparent
    public mutating func withMutableWrappedValue<R>(
        do body: (inout Value) -> R
    ) -> R {
        makeUniquelyReferencedStorage()
        return body(&storage.value)
    }

    @inlinable
    internal mutating func makeUniquelyReferencedStorage() {
        guard !isKnownUniquelyReferenced(&storage) else {
            return
        }
        storage = Storage(storage)
    }

    @usableFromInline
    internal class Storage {

        @usableFromInline
        internal var value: Value

        @inlinable
        internal init(value: Value) {
            self.value = value
        }

        @inlinable
        internal init(_ storage: Storage) {
            self.value = storage.value
        }

    }

}

// MARK: Sequence & Collection Support

extension Cowable: Sequence where Value : Sequence {

    public typealias Iterator = CowableIterator
    
    public typealias Element = Cowable<Value.Element>

    @inlinable
    public func makeIterator() -> CowableIterator {
        return CowableIterator(self)
    }

    public struct CowableIterator: IteratorProtocol {

        public typealias Element = Cowable<Value.Element>

        @usableFromInline
        internal var iterator: Value.Iterator

        @inlinable
        public init(_ value: Cowable<Value>) {
            self.iterator = value.wrappedValue.makeIterator()
        }

        @inlinable
        public mutating func next() -> Element? {
            guard let value = iterator.next() else {
                return nil
            }
            return Cowable<Value.Element>(wrappedValue: value)
        }

    }

}

extension Cowable: Collection where Value : Collection {

    public typealias Index = Value.Index

    @inlinable
    public var startIndex: Index { 
        return wrappedValue.startIndex 
    }

    @inlinable
    public var endIndex: Index { 
        return wrappedValue.endIndex 
    }

    @inlinable
    public func index(after i: Index) -> Index {
        return wrappedValue.index(after: i)
    }

    @inlinable
    public subscript(position: Index) -> Element {
        Cowable<Value.Element>(wrappedValue: wrappedValue[position])
    }

}

extension Cowable: BidirectionalCollection where Value : BidirectionalCollection {

    @inlinable
    public func index(before i: Index) -> Index {
        return wrappedValue.index(before: i)
    }

}

extension Cowable: RandomAccessCollection where Value : RandomAccessCollection {

    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        return wrappedValue.index(i, offsetBy: distance)
    }

}

extension Cowable: MutableCollection where Value : MutableCollection {

    @inlinable
    public subscript(position: Index) -> Element {
        get { 
            Cowable<Value.Element>(wrappedValue: wrappedValue[position]) 
        }
        set { 
            wrappedValue[position] = newValue.wrappedValue
        }
    }

}

extension Cowable: RangeReplaceableCollection where Value : RangeReplaceableCollection {

    @inlinable
    public init() {
        self.init(wrappedValue: Value())
    }

    @inlinable
    public mutating func removeSubrange(_ bounds: Range<Value.Index>) {
        wrappedValue.removeSubrange(bounds)
    }

    @inlinable
    public mutating func replaceSubrange<C>(_ subrange: Range<Value.Index>, with newElements: C) where C : Collection, Cowable<Value.Element> == C.Element {
        var unwrappedNewElement = Value()
        unwrappedNewElement.reserveCapacity(newElements.count)
        for each in newElements {
            unwrappedNewElement.append(each.wrappedValue)
        }
        wrappedValue.replaceSubrange(subrange, with: unwrappedNewElement)
    }

}
