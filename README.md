# PAGES - Bad file descriptor 에러 완전 수정

## 이전 에러 원인
```
Failed to map /.../Unknown.app/(null): Bad file descriptor
```
1. project.pbxproj를 직접 수정하면서 ,, 이중 콤마 생성 -> Xcode 프로젝트 깨짐
2. pod install 실패 -> App.app 실행파일 없는 불완전한 IPA 생성
3. zip -r로 symlink 보존 안 함 -> Bad file descriptor

## 이번 수정
1. **pbxproj 직접 수정 안 함** - CocoaPods 정식 방법으로 BackgroundTTS 추가
   - ios-plugin/BackgroundTTS.podspec 생성
   - Podfile에 `pod 'BackgroundTTS', :path => '../../ios-plugin'` 추가
   - pod install이 자동으로 컴파일

2. **ditto + zip -ry로 IPA 생성** - symlink 보존으로 Bad file descriptor 해결
   - 이전: cp -R + zip -r (symlink 깨짐)
   - 수정: ditto + zip -ry (symlink 보존)

3. **Info.plist background audio 모드 유지**

## 빌드 확인
- Podfile에 BackgroundTTS pod 추가됐는지
- Pods/BackgroundTTS 폴더 생기는지
- App.app 안에 실행파일 App이 있는지
- IPA 안에 Payload/App.app/App 실행파일 있는지

## 테스트
- SideStore에서 Install 시 Bad file descriptor 에러 없어야 함
- 설치 후 읽기 시작 -> 잠금화면에서도 소리 계속 나야 함