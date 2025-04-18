# TheTeam App

A modern web application for team management and content organization.

## Features

- User authentication and authorization
- Company management
- Role-based access control
- Content management
- Tag organization
- Menu section management
- Debug tools

## Tech Stack

- Vue 3 with TypeScript
- Pinia for state management
- Vue Router for navigation
- Supabase for backend services
- Tailwind CSS for styling
- Lucide Icons for icons

## Prerequisites

- Node.js 16.x or later
- npm 7.x or later
- Supabase account and project

## Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd theteamapp
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory with your Supabase credentials:
```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Start the development server:
```bash
npm run dev
```

## Project Structure

```
src/
├── components/     # Reusable UI components
├── composables/    # Vue composition functions
├── layouts/        # Layout components
├── lib/           # Utility functions and types
├── pages/         # Page components
├── router/        # Vue Router configuration
├── stores/        # Pinia stores
└── types/         # TypeScript type definitions
```

## Development

- Use `npm run dev` for development
- Use `npm run build` for production build
- Use `npm run test` to run tests

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT