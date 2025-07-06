# CVE Explorer

A Phoenix LiveView application for exploring and uploading Common Vulnerabilities and Exposures (CVE) data. This tool allows to upload, parse, store, and analyze CVE information from JSON files.

## Features

- **CVE Data Management**: Upload and parse multiple CVE JSON files at once directly through the web interface
- **Data Validation**: Automatic validation of CVE ID format and required fields
- **Database Storage**: Persistent storage of CVE data with PostgreSQL
- **Browse**: List and view detailed information about stored CVEs
- **JSON API**: RESTful API endpoints for programmatic access to CVE data
- **Responsive Design**: Modern UI built with Tailwind CSS and DaisyUI

## Technology Stack

- **Backend**: Elixir & Phoenix Framework
- **Database**: PostgreSQL
- **Frontend**: Phoenix LiveView, Tailwind CSS, DaisyUI
- **Container**: Docker Compose for development database

## Prerequisites

- Elixir 1.14 or later
- Node.js and npm (for asset compilation)
- Docker and Docker Compose (for database)
- Make (for running development commands)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/moltedopablo/cve_explorer.git
cd cve_explorer
```

### 2. Set up the development environment

```bash
# Start PostgreSQL database
make up

# Install dependencies and set up the database
make setup
```

### 3. Start the development server

```bash
# Start Phoenix server with interactive Elixir shell
make start
```

The application will be available at [http://localhost:4000](http://localhost:4000).

### API Endpoints

- `GET /api/cves` - Retrieve all stored CVEs in JSON format
- `GET /api/cves/:cve_id` - Retrieve the complete JSON of a specific CVE by CVE Id

## Testing

Run the test suite with:

```bash
mix test
```
