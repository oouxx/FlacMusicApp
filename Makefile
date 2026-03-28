# ============================================================
# FlacMusicApp - Makefile
# 交叉编译 macOS (Universal) 和 iOS
# 前置依赖: Xcode + Command Line Tools
# ============================================================

APP_NAME       = FlacMusicApp
SCHEME_MACOS   = FlacMusicApp-macOS
SCHEME_IOS     = FlacMusicApp-iOS
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
	@echo "🍎 构建 macOS arm64 (Apple Silicon)..."
	@mkdir -p $(BUILD_DIR)/macos-arm64
	xcodebuild build \
		-target $(SCHEME_MACOS) \
		-sdk macosx \
		-arch arm64 \
		-configuration Release \
		SYMROOT=$(PWD)/$(BUILD_DIR)/macos-arm64 \
		OBJROOT=$(PWD)/$(BUILD_DIR)/macos-arm64/obj \
		| xcpretty 2>/dev/null || cat

	@echo "🍎 构建 macOS x86_64 (Intel)..."
	@mkdir -p $(BUILD_DIR)/macos-x86_64
	xcodebuild build \
		-target $(SCHEME_MACOS) \
		-sdk macosx \
		-arch x86_64 \
		-configuration Release \
		SYMROOT=$(PWD)/$(BUILD_DIR)/macos-x86_64 \
		OBJROOT=$(PWD)/$(BUILD_DIR)/macos-x86_64/obj \
		| xcpretty 2>/dev/null || cat

	@$(MAKE) lipo-macos
	@echo "✅ macOS Universal 构建完成 → $(BUILD_DIR)/macos-universal/"

.PHONY: lipo-macos
lipo-macos:
	@mkdir -p $(BUILD_DIR)/macos-universal
	@APP_ARM64=$$(find $(BUILD_DIR)/macos-arm64 -name "$(APP_NAME)" -type f | head -1); \
	 APP_X86=$$(find $(BUILD_DIR)/macos-x86_64 -name "$(APP_NAME)" -type f | head -1); \
	 if [ -n "$$APP_ARM64" ] && [ -n "$$APP_X86" ]; then \
	   lipo -create -output $(BUILD_DIR)/macos-universal/$(APP_NAME) \
	     "$$APP_ARM64" "$$APP_X86"; \
	   file $(BUILD_DIR)/macos-universal/$(APP_NAME); \
	   echo "✅ lipo Universal Binary 合并完成"; \
	 else \
	   echo "⚠️  未找到可执行文件，跳过 lipo"; \
	 fi

# ── iOS 构建 ────────────────────────────────────────────────
.PHONY: build-ios
build-ios: check-deps
	@echo "📱 构建 iOS 真机 (arm64)..."
	@mkdir -p $(BUILD_DIR)/ios
	xcodebuild build \
		-target $(SCHEME_IOS) \
		-sdk $(IOS_SDK) \
		-arch arm64 \
		-configuration Release \
		SYMROOT=$(PWD)/$(BUILD_DIR)/ios \
		OBJROOT=$(PWD)/$(BUILD_DIR)/ios/obj \
		CODE_SIGNING_ALLOWED=NO \
		| xcpretty 2>/dev/null || cat
	@echo "✅ iOS 构建完成 → $(BUILD_DIR)/ios/"

.PHONY: build-ios-sim
build-ios-sim: check-deps
	@echo "🖥️  构建 iOS 模拟器 (arm64 + x86_64)..."
	@mkdir -p $(BUILD_DIR)/ios-sim
	xcodebuild build \
		-target $(SCHEME_IOS) \
		-sdk $(IOS_SIM_SDK) \
		-arch arm64 \
		-arch x86_64 \
		-configuration Release \
		SYMROOT=$(PWD)/$(BUILD_DIR)/ios-sim \
		OBJROOT=$(PWD)/$(BUILD_DIR)/ios-sim/obj \
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
		-target $(SCHEME_MACOS) \
		-sdk macosx \
		-archivePath $(ARCHIVE_DIR)/$(APP_NAME)-macOS.xcarchive \
		-configuration Release \
		| xcpretty 2>/dev/null || cat
	@echo "✅ Archive → $(ARCHIVE_DIR)/$(APP_NAME)-macOS.xcarchive"

.PHONY: archive-ios
archive-ios: check-deps
	@mkdir -p $(ARCHIVE_DIR)
	@echo "📦 Archive iOS..."
	xcodebuild archive \
		-target $(SCHEME_IOS) \
		-sdk $(IOS_SDK) \
		-arch arm64 \
		-archivePath $(ARCHIVE_DIR)/$(APP_NAME)-iOS.xcarchive \
		-configuration Release \
		| xcpretty 2>/dev/null || cat
	@echo "✅ Archive → $(ARCHIVE_DIR)/$(APP_NAME)-iOS.xcarchive"

# ── Export（需要 ExportOptions.plist）────────────────────────
.PHONY: export-macos
export-macos: archive-macos
	@mkdir -p $(EXPORT_DIR)/macos
	xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_DIR)/$(APP_NAME)-macOS.xcarchive \
		-exportPath $(EXPORT_DIR)/macos \
		-exportOptionsPlist ExportOptions-macOS.plist
	@echo "✅ macOS .app → $(EXPORT_DIR)/macos/"

.PHONY: export-ios
export-ios: archive-ios
	@mkdir -p $(EXPORT_DIR)/ios
	xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_DIR)/$(APP_NAME)-iOS.xcarchive \
		-exportPath $(EXPORT_DIR)/ios \
		-exportOptionsPlist ExportOptions-iOS.plist
	@echo "✅ iOS .ipa → $(EXPORT_DIR)/ios/"

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
