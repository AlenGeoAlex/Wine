# Wine - Screenshot Utility

## Overview

Wine is a free, self-hosted screenshot and screen recording application similar to CleanShotX. It consists of a macOS client application and a backend server for cloud storage capabilities. The application allows users to easily capture, edit, and share screenshots with options for local storage or cloud storage using various providers including S3 and Cloudflare R2.

## Project Structure

The project uses a monorepo structure managed by pnpm workspaces:

- `/apps/wine-server`: NestJS backend server providing cloud storage functionality
- `/apps/macos-client`: macOS native client application for screenshot and recording capabilities
- `/packages`: Shared packages between client and server
  - `/packages/common-models`: Shared database models and types
  - `/packages/open-api-spec`: OpenAPI specification for the server API
  - `/packages/vue-app`: Web components used in the project

## Features

- **Screen Capture**: Take screenshots and record screen activity
- **Self-Hosted Cloud**: Store and share your captures through your own server
- **Multiple Storage Options**: Support for local filesystem, Amazon S3, and Cloudflare R2 storage
- **Multiple Database Options**: Support for PostgreSQL and SQLite
- **Flexible Deployment**: Run the server on your own infrastructure
- **macOS Native Client**: Optimized for macOS with system integration

## Getting Started

### Prerequisites

- Node.js (recommended latest LTS)
- pnpm v10.12.2 (package manager)
- PostgreSQL or SQLite database
- S3-compatible storage (optional)

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd wine

# Install dependencies
pnpm install
```

### Server Setup

```bash
# Navigate to server directory
cd apps/wine-server

# Development mode
pnpm run start:dev

# Production mode
pnpm run build
pnpm run start:prod
```

### Server Configuration

The server supports different storage and database providers that can be configured through environment variables:

#### Storage Providers:
- `FS` - Local filesystem storage
- `S3` - Amazon S3 compatible storage
- `R2` - Cloudflare R2 storage

#### Database Providers:
- `PG` - PostgreSQL database
- `SQLITE` - SQLite database

Create a `.env` file in the wine-server directory with your configuration.

### CLI Commands

The server includes CLI utilities for administrative tasks:

```bash
# In development
pnpm run cli <command>

# In production
pnpm run cli:prod <command>
```

### macOS Client

The macOS client application can be built and run using Xcode. Open the project at `apps/macos-client/Wine/Wine.xcodeproj`.

## Development

### Server Development

```bash
cd apps/wine-server

# Run tests
pnpm run test

# Format code
pnpm run format

# Lint code
pnpm run lint
```

### API Documentation

API documentation is available through the OpenAPI specification in the `packages/open-api-spec` directory.

## Roadmap

- Windows client application
- Additional storage providers
- Enhanced editing capabilities
- Mobile application for viewing and managing captures

## License

This project is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
