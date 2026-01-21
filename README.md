# NailMyJob

A mobile-first web application for residential contractors to create quotes and capture change orders via voice input. Nail every job.

## Features

- **Voice-to-Quote**: Create professional quotes in under 5 minutes via voice input
- **Voice-to-Change Order**: Capture verbal scope changes into signed contracts in under 2 minutes
- **Digital Signatures**: ESIGN Act compliant signatures with timestamp, IP address, and geolocation
- **Magic Link Access**: Homeowners can view and sign without creating an account
- **Mobile-First Design**: Optimized for contractors working from their phones
- **Budget Range System**: Realistic price ranges based on project size and quality tier

## Tech Stack

- Ruby on Rails 8.1
- Hotwire (Turbo + Stimulus)
- TailwindCSS 4
- PostgreSQL
- Sidekiq for background jobs
- Prawn for PDF generation
- Deepgram for voice transcription
- OpenAI GPT-4 for AI parsing

## Quick Start

### Prerequisites

- Ruby 3.4.2
- PostgreSQL 16+
- Redis (for Sidekiq)
- Docker & Docker Compose (optional)

### Using Docker (Recommended)

```bash
# Start the database and Redis
docker compose up -d db redis

# Install dependencies
bundle install

# Setup database
DATABASE_HOST=localhost DATABASE_USERNAME=postgres DATABASE_PASSWORD=postgres rails db:setup

# Start the development server
DATABASE_HOST=localhost DATABASE_USERNAME=postgres DATABASE_PASSWORD=postgres bin/dev
```

### Without Docker

```bash
# Install dependencies
bundle install

# Configure database in config/database.yml
# Then setup:
rails db:setup

# Start the server
bin/dev
```

### Demo Account

After seeding, you can log in with:
- Email: `demo@nailmyjob.com`
- Password: `password123`

## Environment Variables

Create a `.env` file (or use Bitwarden for production):

```bash
# Database
DATABASE_HOST=localhost
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=postgres

# Redis
REDIS_URL=redis://localhost:6379/0

# Rails
SECRET_KEY_BASE=your_secret_key_base

# External APIs
OPENAI_API_KEY=sk-your_openai_api_key
DEEPGRAM_API_KEY=your_deepgram_api_key

# AWS S3 (for file storage)
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret_key
AWS_BUCKET=nailmyjob-files
AWS_REGION=us-east-1

# Email (Mailgun API - recommended over SMTP)
MAILGUN_API_KEY=your_mailgun_api_key
MAILGUN_DOMAIN=hey.nailmyjob.com
```

## Deployment

### Docker Production

```bash
# Build and start all services
docker compose -f docker-compose.production.yml up -d

# Run migrations
docker compose -f docker-compose.production.yml exec web rails db:migrate
```

### Hetzner Deployment

1. Set up a Hetzner server with Docker installed
2. Clone the repository
3. Configure environment variables
4. Run `docker compose -f docker-compose.production.yml up -d`

## API Integration

### Voice Transcription (Deepgram)

The app uses Deepgram's Nova-2 model for voice transcription. Enable transcription by setting `DEEPGRAM_API_KEY`.

### AI Parsing (OpenAI)

Project details are extracted from voice transcripts using GPT-4o. Enable by setting `OPENAI_API_KEY`.

### Development Mode

Without API keys, the app uses mock responses for development.

## Project Structure

```
app/
├── controllers/          # Rails controllers
├── models/               # ActiveRecord models
├── views/                # ERB templates
├── services/             # Service objects
│   ├── voice_transcription_service.rb
│   ├── voice_extraction_service.rb
│   ├── quote_pdf_generator.rb
│   └── change_order_pdf_generator.rb
├── jobs/                 # Background jobs
├── mailers/              # Email templates
└── javascript/
    └── controllers/      # Stimulus controllers
```

## Key Models

- **User**: Contractor account with Devise authentication
- **Company**: Company profile with branding and defaults
- **Client**: Homeowner contact information
- **Quote**: Project estimate with line items
- **Job**: Active project (created when quote is signed)
- **LineItem**: Individual items within a quote
- **ChangeOrder**: Scope changes with digital signatures
- **VoiceSession**: Voice recording transcription

## License

Private

## Support

Contact: support@nailmyjob.com
