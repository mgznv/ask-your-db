# Ask Your DB

A Rails application that allows you to create interactive dashboards with natural language queries. Simply ask questions in plain language and get automatic SQL generation with visual results.

## Features

- 🤖 **Natural Language Queries**: Write questions like "Show sales by month" and get SQL automatically
- 📊 **Multiple Chart Types**: Line, Bar, Pie, Area, and Table visualizations
- ✅ **Approval Workflow**: Review and approve generated SQL before execution
- ⚡ **Hotwire/Turbo**: Reactive interface without page refreshes
- 🎨 **Tailwind CSS**: Modern and responsive UI
- 📈 **Chart.js**: Interactive visualizations
- 🔒 **Safe Execution**: SQL review and approval flow prevents unauthorized queries

## How It Works

1. **Create a Dashboard**: Start by creating a new dashboard
2. **Add Widgets**: Click the "+" button to add a widget
3. **Ask in Natural Language**: Type your query like "Top 10 best-selling products"
4. **Review the SQL**: The system generates SQL using Claude AI - review it before execution
5. **Approve & Execute**: Approve the SQL and execute to see visualized results
6. **Choose Visualization**: Select the best chart type for your data

## Tech Stack

- **Ruby on Rails 7.1.5**
- **PostgreSQL**
- **Anthropic Claude API** - Natural language to SQL conversion
- **Hotwire/Turbo** - Real-time updates without heavy JavaScript
- **Stimulus** - Lightweight JavaScript controllers
- **Tailwind CSS** - Utility-first CSS framework
- **Chart.js** - Charting library
- **esbuild** - JavaScript bundling

## Setup

### Prerequisites

- Ruby 3.x
- PostgreSQL
- Node.js & npm
- Anthropic API Key ([get one here](https://console.anthropic.com/))

### Installation

1. Clone the repository:
```bash
git clone git@github.com:mgznv/ask-your-db.git
cd ask-your-db
```

2. Install dependencies:
```bash
bundle install
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
```

Edit `.env` and add your Anthropic API key:
```
ANTHROPIC_API_KEY=your_api_key_here
```

4. Setup database:
```bash
rails db:create
rails db:migrate
```

5. Build assets:
```bash
npm run build
npm run build:css
```

6. Start the server:
```bash
bin/dev
```

Visit `http://localhost:3000` to start creating dashboards!

## Usage Examples

### Natural Language Queries

- "Show sales grouped by month"
- "Top 10 best-selling products"
- "Active customers in the last 30 days"
- "Revenue by category this year"
- "Average order value by region"

### Widget Workflow

1. **Pending**: SQL generated, awaiting your approval
2. **Approved**: Ready to execute the query
3. **Rejected**: Mark inappropriate or incorrect SQL

### Chart Types

- **Line**: Perfect for time-based trends
- **Bar**: Compare categories side by side
- **Pie**: Show proportions and percentages
- **Area**: Display cumulative data over time
- **Table**: Raw data in tabular format

## Development

### Useful Commands

```bash
# Development with auto-reload
bin/dev

# Run Rails server only
rails server

# Run tests
rails test

# Rails console
rails console

# View routes
rails routes
```

### Project Structure

```
app/
├── controllers/
│   ├── dashboards_controller.rb
│   └── dashboard_widgets_controller.rb
├── models/
│   ├── dashboard.rb
│   └── dashboard_widget.rb
├── services/
│   └── natural_query_service.rb      # Natural language → SQL conversion
├── views/
│   ├── dashboards/
│   └── dashboard_widgets/
└── javascript/
    ├── application.js
    └── dashboard.js                   # Chart.js integration
```

## API Endpoints

```
GET     /dashboards                                             # List dashboards
POST    /dashboards                                             # Create dashboard
GET     /dashboards/:id                                         # View dashboard
PATCH   /dashboards/:id                                         # Update dashboard
DELETE  /dashboards/:id                                         # Delete dashboard

POST    /dashboards/:id/dashboard_widgets                       # Create widget
PATCH   /dashboards/:id/dashboard_widgets/:id                   # Update widget
DELETE  /dashboards/:id/dashboard_widgets/:id                   # Delete widget
PATCH   /dashboards/:id/dashboard_widgets/:id/approve           # Approve widget SQL
PATCH   /dashboards/:id/dashboard_widgets/:id/reject            # Reject widget SQL
POST    /dashboards/:id/dashboard_widgets/:id/execute           # Execute query
POST    /dashboards/:id/dashboard_widgets/:id/regenerate_sql    # Regenerate SQL
```

## Database Schema

```sql
-- Dashboards
CREATE TABLE dashboards (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  layout JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Dashboard Widgets
CREATE TABLE dashboard_widgets (
  id SERIAL PRIMARY KEY,
  dashboard_id INTEGER REFERENCES dashboards(id),
  title VARCHAR NOT NULL,
  natural_query TEXT NOT NULL,
  sql_query TEXT,
  chart_type VARCHAR,
  chart_config JSONB,
  position JSONB,
  status VARCHAR DEFAULT 'pending',
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Roadmap

- [ ] Drag & drop widget reordering
- [ ] Save chart configurations
- [ ] Export dashboards
- [ ] Share dashboards via URL
- [ ] Query history
- [ ] More visualization types
- [ ] Dynamic filters
- [ ] Data-driven alerts

## Troubleshooting

### API Key Issues
If you get Anthropic API errors, verify that `ANTHROPIC_API_KEY` is set correctly in `.env`.

### Database Connection Errors
Ensure PostgreSQL is running and credentials in `config/database.yml` are correct.

### Assets Not Loading
Run `npm run build` and `npm run build:css` to recompile assets.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).
