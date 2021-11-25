# pinentry-swift

Modern PGP pinentry program for MacOS. The features are almost the same as `pinentry-touchid`, except that it supports MacOS 12 because it uses the native `Cocoa` and `LocalAuthentication` library.

## Usage

1. Download/Build the executable, put it somewhere (e.g. `~/pinentry-swift/pinentry-swift.app`)
2. Edit gpg-agent to use it by setting `pinentry-program ~/pinentry-swift/pinentry-swift.app/Contents/MacOS/pinentry-swift`
3. Done

## Author

Meng
