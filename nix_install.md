## Nixのinstallから使えるようになるまでの手順書をまとめる

## 検証した環境
- WSL2上のdebian

## 事前依存package
```
sudo apt update
sudo apt install -y curl xz-utils ca-certificates
```

## Nix install 

```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

## reflect setting shell
`. ~/.nix-profile/etc/profile.d/nix.sh`

## Operation confirmation
```
nix --version
```

## Enable configuration file
```
mkdir -p ~/.config/nix
nano ~/.config/nix/nix.conf
```

## Confirmation of reflection
`nix show-config | grep experimental-features`


