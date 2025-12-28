import Foundation

public enum AccessLevel: String {
  case none
  case start
  case authenticated
  case coupleCombined
  case complete

  public var toString: String {
    switch self {
    case .start:
      return "start"
    case .authenticated:
      return "authenticated"
    case .coupleCombined:
      return "coupleCombined"
    case .complete:
      return "complete"
    case .none:
      return "none"
    }
  }
}
