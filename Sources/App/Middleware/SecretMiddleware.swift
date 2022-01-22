

import Vapor

/// Rejects requests that do not contain correct secret.final class SecretMiddleware: Middleware {
final class SecretMiddleware: Middleware {
  // 1
  let secret: String

  init(secret: String) {
    self.secret = secret
  }

  // 2
  func respond(
    to request: Request,
    chainingTo next: Responder
  ) -> EventLoopFuture<Response> {
    // 3
    guard
      request.headers.first(name: .xSecret) == secret
    else {
      // 4
      return request.eventLoop.makeFailedFuture(
        Abort(
          .unauthorized,
          reason: "Incorrect X-Secret header."))
    }
    // 5
    return next.respond(to: request)
  }
}

extension SecretMiddleware {
  // 1
  static func detect() throws -> Self {
    // 2
    guard let secret = Environment.get("SECRET") else {
      // 3
      throw Abort(
        .internalServerError,
        reason: """
          No SECRET set on environment. \
          Use export SECRET=<secret>
          """)
    }
    // 4
    return .init(secret: secret)
  }
}

extension HTTPHeaders.Name {
  /// Contains a secret key.
  ///
  /// `HTTPHeaderName` wrapper for "X-Secret".
  static var xSecret: Self {
    return .init("X-Secret")
  }
}
