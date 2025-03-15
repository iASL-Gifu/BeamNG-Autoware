# BeamNG - Autoware 自動運転プロジェクト

このプロジェクトは、BeamNG.techの車両をAutowareで自動運転させるために、Zenohを利用してWindowsとLinux間でデータ通信を行うシステムです。

## システム構成
### Windows側
1. **BeamNG.tech** の起動
2. **beamng_zenoh_bridge** の起動
   - [zenoh_beamng_bridge](https://github.com/peregrine-884/zenoh_beamng_bridge) リポジトリを使用

### Linux側
1. **zenoh-plugin-ros2dds** の起動
2. **Autoware** の起動

## セットアップ手順

### 1. Windowsのセットアップ
[zenoh_beamng_bridge](https://github.com/peregrine-884/zenoh_beamng_bridge) のREADMEに従ってセットアップを行ってください。

### 2. Linuxのセットアップ
#### (1) zenoh-plugin-ros2dds のセットアップ
- **Rustのインストール**
  ```bash
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  ```
- **LLVMおよびClang開発パッケージのインストール**
  ```bash
  sudo apt install llvm-dev libclang-dev
  ```
- **zenoh-plugin-ros2dds のクローンとビルド**  
  Windows側のZenohとバージョンを揃える必要があります。
  ```bash
  git clone -b release/1.0.0-alpha.6 https://github.com/eclipse-zenoh/zenoh-plugin-ros2dds.git
  cd zenoh-plugin-ros2dds
  cargo build --release
  ```
- **設定ファイルの配置**  
  - `config.json5` を `zenoh-plugin-ros2dds/config/` に配置してください。  
  - `run_zenoh_bridge.sh` を編集し、`zenoh-plugin-ros2dds/` に配置してください。

#### (2) Autoware のセットアップ
- Autowareのビルドは[公式ドキュメント](https://autowarefoundation.github.io/autoware-documentation/main/installation/autoware/source-installation/)に従って行います。
- リポジトリのクローン時には、以下のコマンドを使用してください。
  ```bash
  git clone -b beamng https://github.com/peregrine-884/custom_autoware.git
  ```
- DDS設定も[こちら](https://autowarefoundation.github.io/autoware-documentation/main/installation/additional-settings-for-developers/network-configuration/dds-settings/)を参考に行ってください。

#### (3) Zenohの通信設定
Windows側とLinux側のZenoh設定ファイルでIPアドレスを修正し、2台のPC間で通信できるようにしてください。

## 起動手順

### 1. Windows側
1. **BeamNG.tech** の起動
   ```bash
   # BeamNGを起動
   ```
2. **beamng_zenoh_bridge** の起動
   ```bash
   cd zenoh_beamng_bridge
   python3 bridge.py
   ```

### 2. Linux側
1. **zenoh-plugin-ros2dds** の起動
   ```bash
   cd zenoh-plugin-ros2dds
   cargo run --release
   ```
2. **Autoware** の起動
   ```bash
   cd custom_autoware
   source install/setup.bash
   ros2 launch autoware.launch.xml
   ```
