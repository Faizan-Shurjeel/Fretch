# Fretch - Flutter Video Downloader

## Overview

Fretch is a cross-platform video downloader application built with Flutter. It leverages the power of yt-dlp for video fetching capabilities and a Rust backend for high performance processing.

## Features

- Download videos from multiple platforms (YouTube, Vimeo, etc.)
- Select video quality and format
- Background download support
- Download history management
- Concurrent download capabilities
- Video metadata extraction

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Rust
- **Video Processing**: yt-dlp

## Installation

### Prerequisites

- Flutter SDK
- Rust toolchain
- yt-dlp

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/fretch.git
   cd fretch
   ```

2. Install Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. Build the Rust backend:

   ```bash
   cd rust_backend
   cargo build --release
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## Usage

1. Launch the app
2. Paste a video URL in the search bar
3. Select your preferred quality and format
4. Tap the download button
5. Access your downloaded videos in the "Downloads" section

## Architecture

Fretch follows a clean architecture pattern:

- UI Layer: Flutter widgets and state management
- Domain Layer: Business logic and use cases
- Data Layer: Repository pattern implementation
- Infrastructure: Rust backend integration via FFI

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
