import Foundation

enum UpdaterError: Error, CustomStringConvertible {

  case network(String)
  case assetNotFound(String)
  case archive(String)
  case install(String)
  case cancelled

  var description: String {
    switch self {
    case let .network(message):
      message
    case let .assetNotFound(message):
      message
    case let .archive(message):
      message
    case let .install(message):
      message
    case .cancelled:
      "Operation cancelled"
    }
  }

}
