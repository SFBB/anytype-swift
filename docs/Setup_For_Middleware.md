# How to setup environment for building middleware
## MacOS

- Make sure you have the latest Xcode version
- Open a terminal.
- Remove all other golang installations (`which go` should report that nothing found)
- Make a dir for golang `mkdir -p $HOME/golang`
- Update brew by `brew update`
- Install from brew only a golang version mentioned [here](https://github.com/anyproto/anytype-heart/blob/main/docs/Build.md#build-from-source), for example: `brew install go@1.xx`
- Remember a golang install path (`/<path-to-golang>/go@1.xx/`) reported by brew

- If you have `~/.zprofile` file then add these lines here, else add these lines to `~/.zshrc`

```
export GOPATH=$HOME/golang
export GOROOT=/<path-to-go>/go@1.xx/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
```
- After restart of the terminal you will achieve all the variables set,
or you can simply load them in the current terminal window by `source ~/.zprofile` or `source ~/.zshrc`

Now you can build the middleware library for iOS.
