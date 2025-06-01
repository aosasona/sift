# Requirements

- The Go toolchain
- Xcode
- [Mise](https://mise.jdx.dev/)

# Compiling

- You need to install the gomobile command locally for some reason, running `go mod tidy` can accidentally remove it, so you need to re-install it like this:

```sh
go get golang.org/x/mobile/cmd/gomobile
```

- Compile the framework by running the command below from the root of the project (`../`)

```sh
mise run build:core
```
