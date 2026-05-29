# Install the Gemini Enterprise Looker block

This is a drop-in Looker block. If your BigQuery project already has the
`gemini_analytics` dataset (created by the Terraform pipeline), you can install
it in a couple of minutes — no LookML editing required.

For the full export-to-dashboard walkthrough, start with the root `README.md`.

## Before you begin

Confirm these are ready before installing the block:

- `gemini_analytics.metrics_history` contains Gemini Enterprise metric rows.
- `workspace_audit.activity` exists if you want Workspace Gemini reporting.
- Your Looker instance has a BigQuery connection.
- The Looker service account can read the datasets and run BigQuery jobs.

Grant the Looker service account:

- **BigQuery Data Viewer** on `gemini_analytics`.
- **BigQuery Data Viewer** on `workspace_audit`, if using Workspace Gemini reporting.
- **BigQuery Job User** on the GCP project.

You also need the `develop`, `manage_models`, and `deploy` Looker permissions to install.

## Install (recommended): one click from Git

1. In Looker, go to **Marketplace** (the grid icon) → gear menu → **Install via Git URL**.
2. Paste this repository's Git URL and the branch (for example `main`).
3. Looker reads `marketplace.json` and prompts you for:
   - **BigQuery Connection** — pick the connection that can read `gemini_analytics`.
   - **BigQuery Project ID** — the GCP project that holds the dataset (e.g. `your-gcp-project-id`).
   - **Gemini analytics dataset** — prefilled with `gemini_analytics`; leave it unless you renamed it.
   - **Workspace audit dataset** — prefilled with `workspace_audit`; leave it if you are not using Workspace reporting.
4. Click **Install**. Looker creates a read-only `marketplace_gemini_enterprise_looker_block` project with the models, explores, and dashboards ready to use.

To change any value later, use **Manage** on the block's Marketplace listing.

## Install (alternative): as a plain Git project

If you would rather manage the files yourself instead of through the Marketplace:

1. **Develop → Manage LookML Projects → New LookML Project**, "Set up from Git", and point at this repo. The repo root is the project root (`manifest.lkml` lives there; the LookML lives under `looker/`).
2. Open `manifest.lkml` and set the constant values for your instance:

```lkml
constant: connection_name { value: "your_bigquery_connection" }
constant: gemini_project   { value: "your-gcp-project-id" }
constant: gemini_dataset   { value: "gemini_analytics" }
constant: workspace_dataset { value: "workspace_audit" }
```

The block uses these constants in SQL table references, so the same LookML points at any instance's BigQuery datasets without editing every view.

## Models

- `gemini_enterprise`: adoption, usage, quality, agent, and value metrics from the longitudinal `metrics_history` table.
- `workspace_gemini`: Workspace Gemini activity from the Workspace Admin BigQuery export `activity` table.

## Dashboards

- Adoption overview
- Usage and quality
- Agent activity
- Value realised

## Validate the block

1. Open the Looker IDE for the installed project.
2. Confirm the connection and project constants are set (Marketplace **Manage**, or the manifest for a Git project).
3. Run **Validate LookML**.
4. Open each dashboard with the default 90-day filter.

If a dashboard is empty, test the underlying Explore first. Empty Workspace dashboards usually mean the Workspace Admin export has not produced Gemini events yet. Empty Gemini Enterprise dashboards usually mean the scheduled merge has not written rows into `metrics_history`.

## Caveats

- Gemini Enterprise analytics exports only cover a rolling 30-day source window. The Terraform pipeline preserves history by merging daily exports into `metrics_history`.
- User-level Gemini Enterprise metrics require allowlisting from the Google account team and are not part of the base block.
- Discovery Engine apps using CMEK may return incomplete metrics.
- Workspace Gemini audit logs must be enabled separately in the Workspace Admin console.
