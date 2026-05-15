-- Collection Journey App - Database Schema
-- Members 1 (Core API & Data) responsibility
-- Naming: database fields use snake_case; API responses use camelCase

CREATE TABLE IF NOT EXISTS collections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  category TEXT,
  date_acquired TEXT,
  location TEXT,
  story TEXT,
  image_url TEXT,
  tags TEXT,  -- JSON array stored as string, e.g. '["旅行","明信片","东京"]'
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- Minimal users table for Member 5 (user profile, stats)
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE,
  email TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

-- Categories table for Member 2 (dynamic forms) and Member 3 (filtering)
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  fields TEXT,
  display_priority INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now'))
);

-- ============================================================
-- Phase 4 migrations (safe to re-run - connection.js catches duplicates)
-- ============================================================

ALTER TABLE collections ADD COLUMN user_id INTEGER;
ALTER TABLE collections ADD COLUMN visibility TEXT DEFAULT 'private';
ALTER TABLE collections ADD COLUMN category_template TEXT;
ALTER TABLE collections ADD COLUMN custom_fields TEXT;

-- ============================================================
-- Phase 4 task 4: AI usage log for Member 5 (AI module)
-- ============================================================

CREATE TABLE IF NOT EXISTS ai_usage_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER,
  feature TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);
