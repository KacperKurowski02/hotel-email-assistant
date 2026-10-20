# Hotel Email Assistant

AI assistant that drafts replies to guest emails for a 4-star hotel (Hotel Narvil Conference & Spa). It **never sends anything**: every reply lands as a Gmail draft in the original thread, and a person reviews and sends it.

Result: drafting time for complex offer emails dropped from up to 15 minutes to about 2.

## How it works

```
Gmail (label AI-do-odpowiedzi)
  → Claude Haiku: classify (category, language, needs reply?)
      ├─ spam/newsletter → label AI-pominiete, log, stop
      └─ needs reply
           → knowledge base: Airtable (rooms, FAQ, offers) + Google Sheets (reply guidelines per category)
           → Claude Sonnet: draft reply as JSON (HTML body, missing facts, confidence)
           → Gmail API: create draft in thread (In-Reply-To / References headers)
           → label AI-szkic, log run to Postgres (Supabase)
  → KPI dashboard on Netlify reads aggregate SQL views
```

## Design decisions

- **Human in the loop** – prices and availability change daily, so the system only drafts; a person sends.
- **No hallucinated facts** – the model may use only the knowledge base; anything missing becomes `[DO UZUPEŁNIENIA: ...]` and is listed in `braki`.
- **Two models** – a fast, cheap model for classification; a stronger model only for emails that need a reply.
- **Prompt-injection guard** – email content is wrapped in XML tags and treated as data, never as instructions.
- **Privacy** – the SQL log stores no guest data (no names, addresses or email text), only categories and metrics. The public dashboard can read only aggregate views (RLS on the raw table).
- **Editable without code** – facts live in Airtable and tone/guidelines in Google Sheets, so non-technical staff can update them.

## Stack

n8n (self-hosted) · Claude API (Haiku + Sonnet) · Gmail API · OAuth2 · Airtable API · Google Sheets API · PostgreSQL / Supabase · SQL views · HTML + Chart.js · GitHub · Netlify · built with Claude Code in VS Code

## Repository

| Path | Contents |
| --- | --- |
| `n8n/workflow.json` | Exported n8n workflow (no credentials) |
| `prompts/` | Classification and drafting prompts |
| `knowledge-base/` | Seed data for Airtable and Google Sheets (from the public hotel website) |
| `sql/schema.sql` | Log table, RLS, KPI views |
| `sql/kpi_queries.sql` | Analysis queries |
| `dashboard/index.html` | KPI dashboard (Supabase REST + Chart.js) |
