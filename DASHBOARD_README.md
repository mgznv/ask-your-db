# ask-your-db 🤖

A Rails application that lets you build interactive dashboards using plain English. Type a question, get automatic SQL generation and visual results — no SQL knowledge required.

Powered by the **Anthropic Claude API** and built with a real-time **Hotwire** interface, with a built-in approval workflow to keep queries safe and auditable.

---

## ✨ Features

- 🤖 **Natural Language to SQL** — Ask questions like "Show sales by month" and get SQL automatically
- 📊 **Multiple Chart Types** — Line, Bar, Pie, Area, and Table visualizations
- ✅ **Approval Workflow** — Review and approve generated SQL before execution
- ⚡ **Hotwire / Turbo** — Reactive interface without page refreshes
- 🔒 **Safe Execution** — SQL review flow prevents unauthorized queries
- 🎨 **Tailwind CSS** — Modern and responsive UI

---

## 🛠️ Tech Stack

![Ruby on Rails](https://img.shields.io/badge/Rails_7.1-CC0000?style=for-the-badge&logo=rubyonrails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Claude API](https://img.shields.io/badge/Claude_API-412991?style=for-the-badge&logo=anthropic&logoColor=white)
![Hotwire](https://img.shields.io/badge/Hotwire-9BDD32?style=for-the-badge&logo=hotwire&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/Tailwind-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)
![Chart.js](https://img.shields.io/badge/Chart.js-FF6384?style=for-the-badge&logo=chartdotjs&logoColor=white)

- **Framework:** Ruby on Rails 7.1.5
- **Database:** PostgreSQL
- **AI:** Anthropic Claude API — natural language to SQL
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS, Chart.js
- **Bundler:** esbuild

---

## 🧠 How It Works

```
User types a natural language question
            ↓
Rails sends question + DB schema to Claude API
            ↓
Claude generates a SQL query
            ↓
User reviews and approves the SQL
            ↓
Rails executes the query (read-only) against PostgreSQL
            ↓
Results rendered as interactive charts via Chart.js
```

---

## 🚀 Getting Started

### Prerequisites

- Ruby 3.x
- PostgreSQL
- Node.js & npm
- Anthropic API Key — [get one here](https://console.anthropic.com/)

### Installation

```bash
# Clone the repo
git clone git@github.com:mgznv/ask-your-db.git
cd ask-your-db

# Install dependencies
bundle install
npm install

# Configure environment
cp .env.example .env
# Edit .env and add your ANTHROPIC_API_KEY

# Setup database
rails db:create db:migrate

# Build assets
npm run build
npm run build:css

# Start the server
bin/dev
```

Visit `http://localhost:3000` to start creating dashboards!

---

## 💬 Example Queries

| Natural Language | Result |
|---|---|
| "Show sales grouped by month" | Line chart with monthly trend |
| "Top 10 best-selling products" | Bar chart ranked by volume |
| "Active customers in the last 30 days" | Table with customer list |
| "Revenue by category this year" | Pie chart by category |
| "Average order value by region" | Bar chart by region |

---

## 🔄 Widget Workflow

1. **Pending** — SQL generated, awaiting your approval
2. **Approved** — Ready to execute the query
3. **Rejected** — Mark incorrect or unsafe SQL for regeneration

---

## 📁 Project Structure

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

---

## 🗄️ Database Schema

```sql
CREATE TABLE dashboards (
  id SERIAL PRIMARY KEY,
  name VARCHAR NOT NULL,
  layout JSONB,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

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

---

## 🛣️ Roadmap

- [ ] Drag & drop widget reordering
- [ ] Export dashboards
- [ ] Share dashboards via URL
- [ ] Query history
- [ ] Dynamic filters
- [ ] Data-driven alerts
- [ ] More visualization types

---

## 📬 Contact

Built by [Manuel](https://github.com/mgznv) · [LinkedIn](https://www.linkedin.com/in/) <!-- agrega tu URL aquí -->

## License

Open source under the [MIT License](LICENSE).
