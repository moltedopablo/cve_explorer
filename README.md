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

### 4. Use sample CVE files

You can find sample CVE JSON files in the `samples` directory.

## Testing

Run the test suite with:

```bash
mix test
```

# API Endpoints

You can access the API documentation at [http://localhost:4000/api/swagger](http://localhost:4000/api/swagger).

- `GET /api/cves` - Retrieve all stored CVEs in JSON format
- `GET /api/cves/:cve_id` - Retrieve the complete JSON of a specific CVE by CVE Id

# Development Log

Started with a basic Phoenix LiveView app and added PostgreSQL for persistence. Got the foundation working with a Makefile for common dev tasks.

Built out the core CVE functionality, created a CVE model with proper validations and got file uploads working through LiveView events. Had to write a CVE parser from scratch and made sure it was well tested with unit tests covering edge cases like invalid dates, missing fields, cve id format.

I added daisyUI for better components and styling. I added date ordering (newest first) and built out a detailed view for individual CVEs.

Added a REST API so the CVE data could be consumed as JSON - both for listing all CVEs and getting individual ones. This required a new controller.

Updated the visuals and made the interface responsive by fixing the navbar to work on mobile. Updated the visual design with a new logo, proper button colors, tables, etc.

I added comprehensive unit tests for the CVE parser, ThreatIntel module, and API controllers. Also wrote integration tests for the upload functionality and list ordering. Added navigation tests to ensure proper routing between list and detail views.

Had to do some cleanup along the way. Removed unused controllers, templates, and handlers that were left over from the installing phase. Moved the "new" screen to its own route for better organization.

The download functionality went through a few iterations before settling on using LiveView events properly. Originally had a separate download controller but ended up removing it in favor of the LiveView approach.

Current state is a fully functional CVE management system with upload, parsing, listing, detailed views, and a JSON API.

## Tasks left behind

- [ ] Add linting like credo and Dialyzer
- [x] Add API documentation using OpenAPI or similar
- [ ] Create a Dockerfile for production deployment and deploy to a cloud provider
- [ ] Add integration tests for uploading multiple files. I tried for a while but it kept crashing. Related link: https://github.com/phoenixframework/phoenix_live_view/issues/3480
- [ ] Add pagination to the CVE list view
- [ ] Implement search functionality for CVEs
- [ ] Add user authentication and authorization
- [ ] Add property based testing for trying different edge cases in CVE files
