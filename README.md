# Real Estate CRM (Malta)

A Ruby on Rails application for managing a real estate brokerage's pipeline: property listings, owner records, prospective tenants/buyers (leads), agent assignments, in-app conversations, and notifications. Geographically scoped to Malta (locations, areas, EUR pricing, country-code phone handling).

**Stack:** Ruby 2.5.1, Rails 5.2.2, PostgreSQL, Redis (Resque + ActionCable), Puma. Auth via Devise + `simple_token_authentication`; authorization via CanCanCan; admin UI via Rails Admin; search via Ransack; geocoding via Geocoder + Gmaps4Rails; mail via Mailgun; file storage via Active Storage with AWS S3; secrets via Figaro.

## Domain model

The core entities and how they relate:

- **User** — Staff member. Roles: `agent`, `editor`, `manager`, `admin`. Authenticated via Devise + token authentication, authorized via CanCanCan.
- **Property** — A listing (rent, sale, commercial lease, commercial sale, management). Belongs to an `Owner`, an `Area`, and a `Location`. Geocoded by full address. Many photos via Active Storage. Rich enums for property type, condition, style, permit class, payment format.
- **Owner** — The property owner (deduplicated by phone number).
- **Lead** — A prospective renter/buyer with budget bracket, preferred areas/locations, bedrooms, contract type, and check-in date. Linked to candidate properties via `LeadProperty`, and tracked through pipeline stages via `LeadPhase`.
- **Area / Location** — Geographic taxonomy used by both leads and properties for matching.
- **Candidate** — A property put forward to a lead as a match.
- **Conversation / Message** — In-app messaging between users, backed by ActionCable.
- **Notification** — In-app notifications, also backed by ActionCable.
- **Bookmark** — A user's saved property.
- **Setting** — Per-user preferences (e.g. email opt-in).

Lead-to-property matching is driven by the `Lead.budget_range` scope, which maps a property's price + contract type into the lead's bracketed budget enum.

## Application structure

```
.
├── Gemfile                 Ruby 2.5.1 / Rails 5.2.2 dependencies
├── app/
│   ├── assets/             Stylesheets, images, JS
│   ├── channels/           ActionCable: messages, notifications
│   ├── controllers/
│   │   ├── api/v1/         JSON API (versioned, Grape + ActiveModel::Serializers)
│   │   ├── concerns/
│   │   ├── exception_handler/
│   │   ├── properties/     Nested property routes
│   │   ├── users/          Devise overrides / user-scoped routes
│   │   └── *.rb            leads, properties, owners, candidates,
│   │                       conversations, messages, notifications,
│   │                       bookmarks, areas, locations, settings,
│   │                       pages, users
│   ├── helpers/
│   ├── jobs/               Notification jobs (Resque-backed)
│   ├── mailers/            Lead, candidate, property emails (Mailgun)
│   ├── models/             Domain models + Ability (CanCan)
│   ├── serializers/        JSON serializers (currently: property)
│   └── views/              ERB views + .js.erb partial responses
├── bin/                    bundle, rails, rake, setup, update, yarn
├── config/
│   ├── application.yml     Figaro-managed env vars (gitignored in practice)
│   ├── database.yml        Postgres config (real_estate_crm_{development,test,staging,production})
│   ├── cable.yml, puma.rb, storage.yml, routes.rb, ...
│   ├── credentials.yml.enc + master.key
│   ├── environments/
│   ├── initializers/
│   └── locales/
└── db/
    ├── schema.rb
    ├── seeds.rb
    └── migrate/            ~41 migrations
```

## Notable mechanics

- **Authorization** — `app/models/ability.rb` defines per-role permissions. Admins manage everything; managers manage properties/users/leads and can access Rails Admin; editors and agents manage properties and owners.
- **Role-aware notifications** — `Lead#create_notification` routes notifications to the assigned agent if there is one, otherwise to all managers/admins (excluding user `id: 4`).
- **Background jobs** — Lifecycle events fire dedicated `ActiveJob` notifications (new lead, lead assignment, dropped lead, contract signed, signature/check-in/visit dates, deposit/commission paid, reminder-to-call, etc.).
- **Active Storage** — Property photos, user avatars, lead avatars. Image variants generated on the fly with `mini_magick`-style options (resize, gravity, auto-orient).
- **Geocoding** — `Property` is `geocoded_by :full_address` (Malta-anchored).
- **Multi-tenant branding** — `Property#cover_photo` switches placeholder images based on host (e.g. `rocklandmalta.com`), suggesting the codebase serves more than one branded deployment.
- **Rails Admin** — Managers and above can access `/admin`; models declare `rails_admin` blocks that customize fields.
- **Search** — `Ransack` is used on `Property` (custom `ransacker` for `id` and `old_id`).

## API

Versioned JSON endpoints live under `app/controllers/api/v1/`. Property responses are shaped by `app/serializers/property_serializer.rb`. Authentication uses `acts_as_token_authenticatable` on `User`.

## Running locally

### Prerequisites

- **Ruby 2.5.1** (pinned in `Gemfile`; use rbenv/asdf/rvm)
- **PostgreSQL** ≥ 9.1 (the `to_char` ransackers and `pg` adapter are Postgres-specific)
- **Redis** (used by Resque for background jobs and by ActionCable in production)
- **Node.js + Yarn** (asset pipeline / `bin/yarn`)
- **ImageMagick** (for `mini_magick` Active Storage variants)

### Setup

```sh
# 1. Install dependencies
bundle install
yarn install

# 2. Configure secrets via Figaro (config/application.yml)
#    Required env vars (at minimum):
#      db_password                     # Postgres password for development/test
#      REAL_ESTATE_CRM_DATABASE_PASSWORD  # Postgres password for staging/production
#      MAILGUN_API_KEY                 # Outbound mail
#      AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION, AWS_BUCKET
#      REDIS_URL                       # for Resque / ActionCable
#      GEOCODER_API_KEY                # if using a paid geocoding lookup
#    Plus config/master.key for credentials.yml.enc (do NOT commit).

# 3. Create and migrate the database
bin/rails db:create db:migrate db:seed

# 4. Run the app
bin/rails server                 # web (Puma on :3000)
bundle exec rake resque:work QUEUE=*   # background workers
bundle exec rake resque:scheduler      # scheduled jobs
```

The default databases are `real_estate_crm_development` and `real_estate_crm_test` (see `config/database.yml`).

### Background jobs

Jobs are queued through Resque (`resque`, `resque-scheduler`, `resque_mailer`) and require a running Redis instance and at least one worker process. Lifecycle events that fire jobs include: new lead, lead assignment, dropped lead, contract signed, signature/check-in/visit-date reminders, deposit/commission paid, and reminder-to-call.

### Realtime

ActionCable channels (`MessagesChannel`, `NotificationsChannel`) drive in-app messaging and notifications. In production, point `cable.yml` at the Redis adapter; development uses the async adapter by default.

## License

Not specified.
