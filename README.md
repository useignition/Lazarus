# Lazarus

Lazarus is a local VPN which harnesses the power of Apple's Network Extension's to create VPN which blocks Enterprise (and 7-day certificates?) revokes.

# It's free

Lazarus is free and always will be. It also does not contain any ads.

### Privacy

Fluid, LLC care about your privacy which is why no data is actually sent to a remote server. If you look in `VPNManager.swift` you will see that data is sent to `0.0.0.0` which is a dead IP.

### Building

You will need to have Xcode 10.1 and you'll need to have carthage installed.

```sh
$ cd ~/Downloads/Lazarus-master
$ carthage update --no-use-binaries --platform ios
$ open Lazarus.xcodeproj
```

### Blocking other URLs

In order to block other URLs you need to open `VPN Rules.conf` and copy one of the `-r ` lines. This will block the URL you chose.


### Development

Want to contribute? Great!

We love improving and will love having you help us make Lazarus even better!
Just make a pull request when you're ready!