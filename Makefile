# ============================================================
# FlacMusicApp - Makefile
# 交叉编译 macOS (Universal) 和 iOS
# 前置依赖: Xcode + Command Line Tools
# ============================================================

APP_NAME       = FlacMusicApp
SCHEME_MACOS   = FlacMusicApp-macOS
SCHEME_IOS     = FlacMusicApp-iOS
XCODEPROJ      = FlacMusicApp.xcodeproj
BUILD_DIR      = .build
ARCHIVE_DIR    = $(BUILD_DIR)/archives
EXPORT_DIR     = $(BUILD_DIR)/export
IOS_SDK        = iphoneos
IOS_SIM_SDK    = iphonesimulator

# ── 默认目标 ────────────────────────────────────────────────
.DEFAULT_GOAL := help

.PHONY: help
help:
	@echo ""
	@echo "  FlacMusicApp 构建工具"
	@echo "  ─────────────────────────────────────────────"
	@echo "  make build-macos        构建 macOS (arm64 + x86_64 Universal)"
	@echo "  make build-ios          构建 iOS 真机 (arm64)"
	@echo "  make build-ios-sim      构建 iOS 模拟器 (arm64 + x86_64)"
	@echo "  make build-xcframework  打包 iOS XCFramework"
	@echo "  make build-all          同时构建 macOS + iOS"
	@echo "  make archive-macos      打包 macOS .xcarchive"
	@echo "  make archive-ios        打包 iOS .xcarchive"
	@echo "  make export-macos       导出 macOS .app"
	@echo "  make export-ios         导出 iOS .ipa"
	@echo "  make release            发布 GitHub Release (需要 gh CLI)"
	@echo "  make release-dry-run    预览 release 内容"
	@echo "  make spm-resolve        解析 Swift Package 依赖"
	@echo "  make spm-build          SPM 编译（macOS）"
	@echo "  make clean              清理构建缓存"
	@echo "  make clean-derived      清理 Xcode DerivedData"
	@echo ""

# ── 依赖检查 ────────────────────────────────────────────────
.PHONY: check-deps
check-deps:
	@which xcodebuild > /dev/null 2>&1 || \
		(echo "❌ 未找到 xcodebuild，请安装 Xcode" && exit 1)
	@which swift > /dev/null 2>&1 || \
		(echo "❌ 未找到 swift，请安装 Swift 工具链" && exit 1)
	@echo "✅ 依赖检查通过"

# ── Swift Package 操作 ──────────────────────────────────────
.PHONY: spm-resolve
spm-resolve:
	swift package resolve

.PHONY: spm-build
spm-build:
	swift build -c release

# ── macOS 构建 ──────────────────────────────────────────────
.PHONY: build-macos
build-macos: check-deps
	@echo "🍎 构建 macOS..."
	@mkdir -p $(BUILD_DIR)/macos
	xcodebuild build \
		-project $(XCODEPROJ) \
		-scheme $(SCHEME_MACOS) \
		-sdk macosx \
		-configuration Debug \
		-derivedDataPath $(BUILD_DIR)/macos \
		| xcpretty 2>/dev/null || cat
	@echo "✅ macOS 构建完成 → $(BUILD_DIR)/macos/"

.PHONY: lipo-macos
lipo-macos:
	@mkdir -p $(BUILD_DIR)/macos-universal
	@APP_ARM64=$$(find $(BUILD_DIR)/macos-arm64 -name "$(APP_NAME).app" -type d | head -1); \
	 APP_X86=$$(find $(BUILD_DIR)/macos-x86_64 -name "$(APP_NAME).app" -type d | head -1); \
	 if [ -n "$$APP_ARM64" ] && [ -n "$$APP_X86" ]; then \
	   # 合并 Frameworks
	   FRAMEWORKS_ARM64=$$(find "$$APP_ARM64/Contents/Frameworks" -name "*.framework" 2>/dev/null); \
	   FRAMEWORKS_X86=$$(find "$$APP_X86/Contents/Frameworks" -name "*.framework" 2>/dev/null); \
	   echo "✅ macOS app 构建完成 (arm64) → $$APP_ARM64"; \
	   echo "✅ macOS app 构建完成 (x86_64) → $$APP_X86"; \
	   echo "✅ Universal Binary 合并需手动通过 Xcode 完成"; \
	 else \
	   echo "⚠️  未找到 .app，跳过"; \
	 fi

# ── iOS 构建 ────────────────────────────────────────────────
.PHONY: build-ios
build-ios: check-deps
	@echo "📱 构建 iOS 真机 (arm64)..."
	@mkdir -p $(BUILD_DIR)/ios
	xcodebuild build \
		-project $(XCODEPROJ) \
		-scheme $(SCHEME_IOS) \
		-sdk $(IOS_SDK) \
		-configuration Release \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty 2>/dev/null || cat
	@echo "✅ iOS 构建完成 → $(BUILD_DIR)/ios/"

.PHONY: build-ios-sim
build-ios-sim: check-deps
	@echo "🖥️  构建 iOS 模拟器 (arm64 + x86_64)..."
	@mkdir -p $(BUILD_DIR)/ios-sim
	xcodebuild build \
		-project $(XCODEPROJ) \
		-scheme $(SCHEME_IOS) \
		-sdk $(IOS_SIM_SDK) \
		-configuration Debug \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty 2>/dev/null || cat
	@echo "✅ iOS Simulator 构建完成 → $(BUILD_DIR)/ios-sim/"

.PHONY: build-xcframework
build-xcframework: build-ios build-ios-sim
	@echo "📦 打包 XCFramework..."
	@IOS_FW=$$(find $(BUILD_DIR)/ios -name "$(APP_NAME).framework" -type d | head -1); \
	 SIM_FW=$$(find $(BUILD_DIR)/ios-sim -name "$(APP_NAME).framework" -type d | head -1); \
	 xcodebuild -create-xcframework \
	   -framework "$$IOS_FW" \
	   -framework "$$SIM_FW" \
	   -output $(BUILD_DIR)/$(APP_NAME).xcframework
	@echo "✅ XCFramework → $(BUILD_DIR)/$(APP_NAME).xcframework"

# ── 同时构建 ────────────────────────────────────────────────
.PHONY: build-all
build-all: build-macos build-ios
	@echo ""
	@echo "🎉 全部平台构建完成"
	@echo "   macOS → $(BUILD_DIR)/macos-universal/"
	@echo "   iOS   → $(BUILD_DIR)/ios/"

# ── Archive（需要签名配置）──────────────────────────────────
.PHONY: archive-macos
archive-macos: check-deps
	@mkdir -p $(ARCHIVE_DIR)
	@echo "📦 Archive macOS..."
	xcodebuild archive \
		-project $(XCODEPROJ) \
		-scheme $(SCHEME_MACOS) \
		-sdk macosx \
		-archivePath $(ARCHIVE_DIR)/$(APP_NAME)-macOS.xcarchive \
		-configuration Release \
		PRODUCT_BUNDLE_IDENTIFIER=com.example.FlacMusicApp.macOS \
		CODE_SIGN_IDENTITY="-" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty 2>/dev/null || cat
	@echo "✅ Archive → $(ARCHIVE_DIR)/$(APP_NAME)-macOS.xcarchive"

.PHONY: archive-ios
archive-ios: check-deps
	@mkdir -p $(ARCHIVE_DIR)
	@echo "📦 Archive iOS..."
	xcodebuild archive \
		-project $(XCODEPROJ) \
		-scheme $(SCHEME_IOS) \
		-sdk $(IOS_SDK) \
		-archivePath $(ARCHIVE_DIR)/$(APP_NAME)-iOS.xcarchive \
		-configuration Release \
		PRODUCT_BUNDLE_IDENTIFIER=com.example.FlacMusicApp.iOS \
		CODE_SIGN_IDENTITY="-" \
		CODE_SIGNING_REQUIRED=NO \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty 2>/dev/null || cat
	@echo "✅ Archive → $(ARCHIVE_DIR)/$(APP_NAME)-iOS.xcarchive"

# ── Export（直接从 Archive 提取 .app/.ipa，无需签名）───────────────
# 用于本地测试打包，无需 Apple Developer 账号

.PHONY: export-macos
export-macos: archive-macos
	@echo "📦 提取 macOS .app..."
	@PRODUCTS_PATH=$(ARCHIVE_DIR)/$(APP_NAME)-macOS.xcarchive/Products/Applications && \
		APP_PATH=$$(find "$$PRODUCTS_PATH" -name "*.app" -type d | head -1) && \
		if [ -n "$$APP_PATH" ]; then \
			mkdir -p $(EXPORT_DIR)/macos && \
			cp -r "$$APP_PATH" $(EXPORT_DIR)/macos/ && \
			echo "✅ macOS .app → $(EXPORT_DIR)/macos/$$(basename $$APP_PATH)"; \
		else \
			echo "❌ 未找到 .app"; exit 1; \
		fi

.PHONY: export-ios
export-ios: archive-ios
	@echo "📱 创建 iOS IPA..."
	@PRODUCTS_PATH=$(ARCHIVE_DIR)/$(APP_NAME)-iOS.xcarchive/Products/Applications && \
		APP_PATH=$$(find "$$PRODUCTS_PATH" -name "*.app" -type d | head -1) && \
		if [ -n "$$APP_PATH" ]; then \
			mkdir -p $(EXPORT_DIR)/ios/Payload && \
			cp -r "$$APP_PATH" $(EXPORT_DIR)/ios/Payload/ && \
			cd $(EXPORT_DIR)/ios && \
			zip -r FlacMusicApp.ipa Payload/ && \
			rm -rf Payload && \
			echo "✅ iOS .ipa → $(EXPORT_DIR)/ios/FlacMusicApp.ipa"; \
		else \
			echo "❌ 未找到 .app"; exit 1; \
		fi

# ── Release ────────────────────────────────────────────────────
VERSION ?= 1.0.0

.PHONY: release
release: export-macos export-ios
	@echo "📦 计算文件哈希..."
	@MACOS_APP=$(EXPORT_DIR)/macos/FlacMusicApp-macOS.app && \
	IOS_IPA=$(EXPORT_DIR)/ios/FlacMusicApp.ipa && \
	MACOS_HASH=$$(shasum -a 256 "$$MACOS_APP" | cut -d' ' -f1) && \
	IOS_HASH=$$(shasum -a 256 "$$IOS_IPA" | cut -d' ' -f1) && \
	echo "macOS .app SHA256: $$MACOS_HASH" && \
	echo "iOS .ipa SHA256: $$IOS_HASH" && \
	echo "" && \
	echo "📝 生成 Changelog..." && \
	LAST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo "") && \
	if [ -n "$$LAST_TAG" ]; then \
		RANGE="$$LAST_TAG..HEAD"; \
	else \
		RANGE="-30"; \
	fi && \
	FEATS=$$(git log $$RANGE --pretty=format:"- %s" --no-merges | grep -E "^\\- feat[:(]" || true) && \
	FIXES=$$(git log $$RANGE --pretty=format:"- %s" --no-merges | grep -E "^\\- fix[:(]" || true) && \
	OTHER=$$(git log $$RANGE --pretty=format:"- %s" --no-merges | grep -vE "^\\- (feat|fix|chore|docs)[:(]" || true) && \
	{ \
		echo "## Downloads"; \
		echo ""; \
		echo "- **macOS**: FlacMusicApp-macOS.app (SHA256: \`$$MACOS_HASH\`)"; \
		echo "- **iOS**: FlacMusicApp.ipa (SHA256: \`$$IOS_HASH\`)"; \
		echo ""; \
		echo "## Changelog"; \
		echo ""; \
		if [ -n "$$FEATS" ]; then \
			echo "### ✨ New Features"; \
			echo "$$FEATS" | sed 's/^feat: /- /'; \
			echo ""; \
		fi; \
		if [ -n "$$FIXES" ]; then \
			echo "### 🐛 Bug Fixes"; \
			echo "$$FIXES" | sed 's/^fix: /- /'; \
			echo ""; \
		fi; \
		if [ -n "$$OTHER" ]; then \
			echo "### Other Changes"; \
			echo "$$OTHER"; \
		fi; \
	} > /tmp/changelog.md && \
	cat /tmp/changelog.md && \
	echo "" && \
	echo "🚀 创建 GitHub Release v$(VERSION)..." && \
	gh release create v$(VERSION) \
		"$$MACOS_APP" \
		"$$IOS_IPA" \
		--title "v$(VERSION)" \
		--notes-file /tmp/changelog.md || \
	(echo "❌ Release 创建失败,请确认 gh CLI 已登录" && exit 1)
	@echo "✅ Release v$(VERSION) 已发布"

.PHONY: release-dry-run
release-dry-run: export-macos export-ios
	@echo "📦 文件哈希 (预览):"
	@echo "macOS: $$(shasum -a 256 $(EXPORT_DIR)/macos/FlacMusicApp-macOS.app | cut -d' ' -f1)"
	@echo "iOS:   $$(shasum -a 256 $(EXPORT_DIR)/ios/FlacMusicApp.ipa | cut -d' ' -f1)"
	@echo ""
	@echo "📝 Changelog (预览):"
	@LAST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo "") && \
	if [ -n "$$LAST_TAG" ]; then \
		RANGE="$$LAST_TAG..HEAD"; \
	else \
		RANGE="-30"; \
	fi && \
	FEATS=$$(git log $$RANGE --pretty=format:"- %s" --no-merges | grep -E "^\\- feat[:(]" || true) && \
	FIXES=$$(git log $$RANGE --pretty=format:"- %s" --no-merges | grep -E "^\\- fix[:(]" || true) && \
	OTHER=$$(git log $$RANGE --pretty=format:"- %s" --no-merges | grep -vE "^\\- (feat|fix|chore|docs)[:(]" || true) && \
	if [ -n "$$FEATS" ]; then \
		echo "### ✨ New Features"; \
		echo "$$FEATS" | sed 's/^feat: /- /'; \
		echo ""; \
	fi; \
	if [ -n "$$FIXES" ]; then \
		echo "### 🐛 Bug Fixes"; \
		echo "$$FIXES" | sed 's/^fix: /- /'; \
		echo ""; \
	fi; \
	if [ -n "$$OTHER" ]; then \
		echo "### Other Changes"; \
		echo "$$OTHER"; \
	fi
	@echo ""
	@echo "ℹ️  实际发布请运行: make release VERSION=x.x.x"

# ── 清理 ─────────────────────────────────────────────────────
.PHONY: clean
clean:
	@echo "🧹 清理构建缓存..."
	rm -rf $(BUILD_DIR)
	swift package clean
	@echo "✅ 清理完成"

.PHONY: clean-derived
clean-derived:
	@echo "🧹 清理 Xcode DerivedData..."
	rm -rf ~/Library/Developer/Xcode/DerivedData/$(APP_NAME)-*
	@echo "✅ DerivedData 已清理"
