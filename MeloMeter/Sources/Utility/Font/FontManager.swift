//
//  FontManager.swift
//  MeloMeter
//
//  Created by walkerhilla on 2023/04/27.
//

import UIKit

/// `FontManager` 클래스는 앱에서 사용할 폰트를 관리하는 싱글톤 클래스입니다.
final class FontManager {
  
  /// `FontManager` 클래스의 공유 인스턴스입니다.
  static let shared = FontManager()
  
  /// `FontManager` 클래스는 외부에서 인스턴스를 생성할 수 없도록 `private init()`을 통해 초기화 방지합니다.
  private init() {}
  
  /// 지정된 크기의 `Pretendard-Regular` 폰트를 반환합니다.
  ///
  /// - Parameter size: 폰트 크기
  /// - Returns: `Pretendard-Regular` 폰트 인스턴스
  func regular(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Pretendard-Regular", size: size)!
  }
  
  /// 지정된 크기의 `Pretendard-Bold` 폰트를 반환합니다.
  ///
  /// - Parameter size: 폰트 크기
  /// - Returns: `Pretendard-Bold` 폰트 인스턴스
  func bold(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "Pretendard-Bold", size: size)!
  }
}
