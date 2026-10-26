# Install the Gemini Enterprise Looker block

This is a drop-in Looker block. If your BigQuery project already has the
`gemini_analytics` dataset (created by the Terraform pipeline), you can install
it in a couple of minutes without editing any LookML.

For the full export-to-dashboard walkthrough, start with the root `README.md`.

## Before you begin

Confirm these are ready before installing the block:

- Looker 26.4 or later. The dashboard uses LookML dashboard tabs, which arrived in 26.4.
- `gemini_analytics.export_history` contains Gemini Enterprise metric rows.
- The Workspace audit export dataset (we use `workspace_audit` as the example name) has an `activity` table, if you want Workspace Gemini reporting. Set the `workspace_dataset` constant to your actual dataset name.
- Your Looker instance has a BigQuery connection with a PDT/scratch dataset configured (the AI adoption and Workspace explores build persisted derived tables).
- The Looker service account can read the datasets and run BigQuery jobs.
- For individual-level coaching views, create a Looker user attribute named `gemini_individual_access` and set it to `yes` only for authorised change managers and administrators. Set **User Access** to **View** (or **None**), never **Edit**: Looker rejects an access grant on a user-editable attribute, and the whole model fails to load.

Grant the Looker service account (Terraform does the first and third for you if you set `looker_service_account_email`):

- BigQuery Data Viewer on `gemini_analytics`.
- BigQuery Data Viewer on the Workspace audit dataset, if using Workspace Gemini reporting.
- BigQuery Job User on the GCP project.

> The AI adoption tabs join the Workspace audit export to the Gemini Enterprise
> tables, which BigQuery only allows within one location. If the export is
> elsewhere (common: `gemini_analytics` in EU, the audit export in US), copy it
> into the Gemini location (Terraform `workspace_audit_dataset_id` does this daily)
> or set **Workspace audit export** to `separate_region`, which keeps only the
> **Workspace Gemini** tab on it.

You also need the `develop`, `manage_models`, and `deploy` Looker permissions to install.

## Install (recommended): one click from Git

1. In Looker, go to **Marketplace** (the grid icon), open the gear menu and choose **Install via Git URL**.
2. Paste this repository's Git URL and the branch (for example `main`).
3. Looker reads `marketplace.json` and prompts you for:
   - BigQuery Connection: pick the connection that can read `gemini_analytics`.
   - BigQuery Project ID: the GCP project that holds the dataset (e.g. `your-gcp-project-id`).
   - Gemini analytics dataset: prefilled with `gemini_analytics`; leave it unless you renamed it.
   - Workspace audit dataset: prefilled with `workspace_audit`; set it to your Workspace export dataset name.
   - Workspace audit export: `none` (default), `separate_region` or `same_region`. `same_region` adds Gemini for Workspace adoption, the Workspace population and org units to the AI adoption tabs.
   - Optional, all with defaults: reporting time zone, Power and Normal user thresholds, seat costs, loaded hourly rate, currency symbol, minutes saved per AI action, and org-unit depth for departments.
4. Click **Install**, then open the **Data Health** tab of **Gemini | Admin AI Telemetry** to see which sources the block can read. Looker creates a read-only `marketplace_gemini_enterprise_looker_block` project with one model, its explores and three role-based dashboards.

To change any value later, use **Manage** on the block's Marketplace listing.

The dashboards name `Plus Jakarta Sans` first, then fall back to Google Sans,
Roboto and Arial. Looker blocks cannot load web fonts themselves, so viewers see
Plus Jakarta Sans only if the font is already available to their browser or a
Looker admin applies it through an instance theme.

> With **Workspace audit export** left at `none`, the Workspace Gemini tab and
> Workspace tiles load empty instead of erroring, so the block installs cleanly
> before the Workspace export exists.

## Install (alternative): as a plain Git project

If you would rather manage the files yourself instead of through the Marketplace:

1. Go to **Develop > Manage LookML Projects > New LookML Project**, choose "Set up from Git" and point at this repo. The repo root is the project root (`manifest.lkml` lives there; the LookML lives under `looker/`).
2. Open `manifest.lkml` and set the constant values for your instance:

```lkml
constant: connection_name { value: "your_bigquery_connection" }
constant: gemini_project   { value: "your-gcp-project-id" }
constant: gemini_dataset   { value: "gemini_analytics" }
constant: workspace_dataset { value: "workspace_audit" }
constant: workspace_export  { value: "none" }  # none, separate_region or same_region
```

The block uses these constants in SQL table references, so the same LookML points at any instance's BigQuery datasets without editing every view.

## Model

The block installs one model, `gemini_enterprise` (label **Gemini AI Adoption**), so it adds a single entry to the instance's model list. Its explores read three sources, each with its own refresh datagroup:

- The Gemini Enterprise analytics export: adoption, active users and retention, activity and engagement, seats and agents, all built on the full-fidelity `export_history` table. Always present once the exporter runs.
- The redacted log tables (`ge_*`, `antigravity_usage`) that the exporter builds when the Terraform log pipeline is on, plus the cross-product AI adoption layer: `ai_activity_hourly` (every AI action across Gemini Enterprise, Gemini for Workspace and Antigravity), `ai_user_profile` (current cohort, product mix and activation per person), `ai_user_cohort_weekly` (cohort per person per week), the population scope, opportunity and intervention tables, and the Setup Health views. These need a PDT/scratch dataset: the AI adoption tables rebuild daily over the last 400 days, and the Gemini Enterprise rollups rebuild hourly.
- Workspace Gemini activity from the Workspace Admin BigQuery export `activity` table, persisted daily as a PDT.

A source that isn't set up only breaks the explores and tiles that read it.

## Explores

The Explore menu shows four explores under **Gemini AI Adoption**. Everything else is a single-purpose table that a dashboard already shows in full, so it stays hidden. Technical fields (raw IDs, API method names, request settings) are hidden too. Hidden explores and fields still work in the dashboards and drills, and developers can open them by URL.

- AI Activity: start here. Every AI action across Gemini Enterprise, Gemini for Workspace and Antigravity, by person, department, product, feature, use case, day and local hour, with estimated time saved. Needs the log pipeline; Workspace rows also need the Workspace audit export.
- People and Activation: one row per person, with their cohort, product mix, activation, retention, top model and licence state. Use it for activation rates, licence spend and coaching lists.
- Gemini Enterprise Activity: every Gemini Enterprise interaction by feature, agent, model, grounding source and app. Needs the log pipeline.
- Gemini Enterprise Seats: daily active users against seats claimed and purchased, from Google's analytics export. Works without the log pipeline.

AI Activity and Gemini Enterprise Activity include a **Person** section (cohort, product mix, licence, department, org unit), so any chart can be split by cohort or department.

Hidden explores: Cohorts Over Time, Antigravity Activity, Safety and Model Armor, Workspace Gemini Activity, Active Users and Retention, Search and Assistant Activity, Agents, Seats, AI Opportunities, AI Interventions, Intervention Impact, Validated Value Outcomes, Tools and Skills, Model Calls and Tokens, Licences, Admin Changes, Setup Health, Data State, Population Scope and Export History (raw).

### Feature taxonomy

The `feature` dimension on **Gemini Enterprise Activity** is derived by the exporter. The mapping runs in this order:

| Feature | Rule |
|---|---|
| Agent builder | CreateAgent, UpdateAgent, DeleteAgent, SetIamPolicy |
| File upload | UploadSessionFile, AddContextFile |
| Feedback, NotebookLM, Agent gallery, Navigation | WriteUserEvent with feedback, the NotebookLM page, the agent gallery page, or anything else |
| Search / Assistant grounding | Search with a user ID (search bar) / without one (the assistant's own lookups) |
| Scheduled and triggered agents | Assistant calls carrying a schedule or trigger ID |
| Deep Research, Idea Generation, Skill authoring | Assistant calls to the `deep_research`, `idea_generation` or `skill_generation_agent` agents |
| Agent designer, Workflows | `app_catalyst*` agents, `workflow_summary_agent` |
| Actions | The user confirmed an action (send email, create event) |
| Image generation | The answer came from an image model |
| Custom agents | Any other non-core agent |
| Assistant chat | Everything else sent to the assistant |

To change it, edit the `CASE` in `apps/exporter/src/gemini_exporter/sql/logs/ge_user_activity.sql`. New rows pick up the change, but existing rows keep their old label.

## Dashboards

The block installs three role-based dashboards instead of one large dashboard:

- Gemini | Executive AI Adoption (`gemini_ai_executive.dashboard.lookml`): a concise decision view with canonical activation, regular adoption, engagement, retention, licence spend to review, a data-trust indicator and the top recommended actions.
- Gemini | AI Change Management (`gemini_ai_change.dashboard.lookml`): an operational view for opportunity queues, cohort movement, use-case adoption, authorised people/coaching lists and intervention measurement.
- Gemini | Admin AI Telemetry (`gemini_ai_admin.dashboard.lookml`): product telemetry, Workspace Gemini events, agents, models, Antigravity, governance, setup health and definitions.

The old `gemini_ai_adoption` dashboard has been removed. Existing bookmarks to it should be replaced with one of the three role-based dashboards.

Headline definitions are now canonical across the dashboards:

- Activation: eligible people with at least one AI-active day in the last 28 days, divided by eligible people in scope.
- Regular adoption: eligible people with at least `normal_user_min_days` AI-active days in the last 28 days, divided by eligible people in scope.
- Engagement: distinct AI-active days per active user.
- Retention: people active in the previous 28-day window who returned in the current 28-day window.

Product-specific telemetry keeps its own label and denominator. For example, **Daily Active / Seats Claimed** is the Gemini Enterprise Google export metric, while **Active Share of Workspace Gemini Events** is an event share, not a people activation rate.

Dashboard filters are **Date** (default 90 days), **Product**, **Department** and **Gemini Enterprise App** where supported. Rolling 28-day people metrics ignore Date by design and show their effective window in the tile or definition.

The layout uses the 72-column `granular` grid. Outcome tiles come first, explanation charts second, and investigation tables last. Sparse sources use data-state cards so users can distinguish **Not configured**, **No records**, **Insufficient history** and **Zero activity**.

### Population scope and privacy

Employee adoption rates use the optional Marketplace constants `employee_domains`, `excluded_org_units` and `excluded_email_pattern`. Use them to remove external users, guests and service accounts from the denominator. The Data Health tab shows excluded people by reason.

People are identified by email address. When an admin renames an account, the block reads the rename from the Workspace audit log and counts every address the person has used as their current one, so history and cohorts carry over. This needs `workspace_export = same_region`. If an address change doesn't appear as a rename (for example, it happened before the audit export started), add it to the `person_email_overrides` constant as comma-separated pairs of old address, an equals sign and the current address.

Individual user fields are protected by the `can_see_individuals` access grant, driven by the `gemini_individual_access` user attribute. Give that attribute the value `yes` only to roles allowed to use coaching and administration lists.

### Intervention and value tracking

Terraform creates two optional tables:

- `ai_interventions`: training, campaigns, coaching sessions and licence-review actions.
- `ai_value_outcomes`: validated business outcomes from surveys, workflow systems or finance review.

Load these tables when you want the Change Management dashboard to compare adoption before and after an intervention or to report validated outcomes separately from estimated productivity benefits. Intervention impact is labelled as comparison, not proof of causation.

#### Log an intervention

Each row in `ai_interventions` is one action someone owns. The opportunity queue shows the owner, status and follow-up date of any intervention whose `opportunity_type` matches the queue row. For department opportunities, `target_scope` must also name the same department.

| Column | What to put in it |
| --- | --- |
| `intervention_id` | Any stable ID, for example `2026-11-sales-session`. |
| `name` | A short description, for example `Sales team prompt session`. |
| `type` | `training`, `campaign`, `coaching`, `licence_review` or `other`. |
| `start_date`, `end_date` | When the action runs. |
| `target_scope_type`, `target_scope` | `department` and the department name, `email_list` and comma-separated emails, or `organisation` and any label. |
| `owner` | The person accountable. |
| `opportunity_type` | The code from the queue: `build_repeat_usage`, `review_idle_licences`, `expand_department_adoption`, `assign_departments`, `workspace_to_enterprise`, `address_access_friction` or `improve_classification`. |
| `follow_up_date` | When to re-measure. The dashboard shows it as the deadline and flags it as overdue once it passes. |
| `status` | `planned`, `active`, `complete` or `cancelled`. Cancelled interventions drop off the queue. |
| `outcome`, `outcome_notes` | After the follow-up: `improved`, `no_change`, `worse` or `too_early`, and the evidence. |

The quickest way to add a row is from the BigQuery console:

```sql
INSERT INTO `your-project.gemini_analytics.ai_interventions`
  (intervention_id, name, type, start_date, target_scope_type, target_scope, owner, opportunity_type, follow_up_date, status)
VALUES
  ('2026-11-sales-session', 'Sales team prompt session', 'training', '2026-11-03', 'department', 'Sales', 'jane@example.com', 'expand_department_adoption', '2026-12-01', 'planned');
```

If your change team records interventions through a form or app (for example a Google Form or AppSheet app that writes to this table), set the `interventions_form_url` constant to its link. The Interventions tab then shows a **Record an intervention** button. With the default `none`, the button is hidden.

To let a change team log interventions without BigQuery access, keep the list in a Google Sheet with the same column headers, create a BigQuery external table over the sheet, and schedule a daily query that replaces the contents of `ai_interventions` with the sheet's rows. The `outcome` and `outcome_notes` columns were added after the first release; run `terraform apply` to add them to an existing table. The dashboard works without them.

## Validate the block

1. Open the Looker IDE for the installed project.
2. Confirm the connection and project constants are set (Marketplace **Manage**, or the manifest for a Git project).
3. Run **Validate LookML**.
4. Open the dashboard and check each tab for the sources you set up, using the default 90-day filter.

If a tab is empty, test the underlying Explore first. An empty Workspace Gemini tab or Workspace tiles usually mean **Workspace audit export** is `none`, or the Workspace Admin export has not produced Gemini events yet; **Setup Health** shows which. An empty Gemini Enterprise Analytics tab usually means the exporter has not run successfully, so check the Cloud Run job logs for `merge_completed`. Note that the Agents tile stays empty until agents are used on the engine.

## Caveats

- Gemini Enterprise analytics exports only cover a rolling 30-day source window. The pipeline preserves history by merging each export into `export_history`.
- The export API's own user-level metrics need allowlisting from the Google account team. The user-level tabs get their data from Cloud Logging instead, so it needs the Terraform log pipeline (root `README.md`, step 8) and not the allowlist.
- The user-level tabs error until the log pipeline's tables exist. The Gemini Enterprise Analytics, Workspace Gemini and Setup Health tabs are unaffected.
- Discovery Engine apps using CMEK may return incomplete metrics.
- Workspace Gemini audit logs must be enabled separately in the Workspace Admin console.
