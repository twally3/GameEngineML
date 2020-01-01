import GameplayKit

class SeededRandom: RandomNumberGenerator {
    let seed: UInt64
    private let generator: GKMersenneTwisterRandomSource
    
    convenience init() {
        self.init(seed: 0)
    }
    
    init(seed: UInt64) {
        self.seed = seed
        generator = GKMersenneTwisterRandomSource(seed: seed)
    }
    
    func next<T>(upperBound: T) -> T where T : FixedWidthInteger, T : UnsignedInteger {
        return T(abs(generator.nextInt(upperBound: Int(upperBound))))
    }
    
    func next<T>() -> T where T : FixedWidthInteger, T : UnsignedInteger {
        return T(abs(generator.nextInt()))
    }
}
