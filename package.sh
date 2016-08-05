pod install --verbose --no-repo-update && \

xcodebuild -workspace PlatinumBlue.xcworkspace -scheme PlatinumBlue archive -archivePath ./build/PlatinumBlue.xcarchive && \

rm -rf ./build/PlatinumBlue.ipa && \

xcodebuild -exportArchive -exportFormat ipa -archivePath build/PlatinumBlue.xcarchive -exportPath build/PlatinumBlue.ipa && \

fir p build/PlatinumBlue.ipa -T f253f7f8ef8c45ea581b3a382a81ff9d
