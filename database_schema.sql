-- ==========================================================
-- TRELLO DATABASE SCHEMA (PostgreSQL / MySQL mos keluvchi)
-- Loyiha: Trello Ma'lumotlar Bazasi Strukturasi
-- Ushbu SQL kodni DrawSQL.app yoki dbdiagram.io ga to'g'ridan-to'g'ri
-- import qilib, vizual ERD diagrammasini avtomatik hosil qilishingiz mumkin.
-- ==========================================================

-- 1. FOYDALANUVCHILAR (USERS)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    avatar_url VARCHAR(255),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. ISHCHI MAYDONLAR (WORKSPACES)
CREATE TABLE workspaces (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL,
    description TEXT,
    workspace_type VARCHAR(50) DEFAULT 'general', -- personal, business, education
    owner_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. ISHCHI MAYDON A'ZOLARI (WORKSPACE MEMBERS)
CREATE TABLE workspace_members (
    id SERIAL PRIMARY KEY,
    workspace_id INT NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- owner, admin, member, guest
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(workspace_id, user_id)
);

-- 4. DOSKALAR (BOARDS)
CREATE TABLE boards (
    id SERIAL PRIMARY KEY,
    workspace_id INT NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    visibility VARCHAR(20) DEFAULT 'workspace', -- private, workspace, public
    background_color VARCHAR(20) DEFAULT '#0079bf',
    background_image_url VARCHAR(255),
    is_template BOOLEAN DEFAULT FALSE,
    is_closed BOOLEAN DEFAULT FALSE,
    created_by INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. DOSKA A'ZOLARI (BOARD MEMBERS)
CREATE TABLE board_members (
    id SERIAL PRIMARY KEY,
    board_id INT NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'normal', -- admin, normal, observer
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(board_id, user_id)
);

-- 6. SHABLONLAR (TEMPLATES)
CREATE TABLE templates (
    id SERIAL PRIMARY KEY,
    board_id INT REFERENCES boards(id) ON DELETE SET NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    category VARCHAR(50) DEFAULT 'Project Management',
    is_public BOOLEAN DEFAULT TRUE,
    created_by INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. USTUNLAR / BO'LIMLAR (LISTS)
CREATE TABLE lists (
    id SERIAL PRIMARY KEY,
    board_id INT NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    position NUMERIC(10, 2) NOT NULL DEFAULT 65535, -- Drag-and-drop tartibi
    is_archived BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. VAZIFA KARTALARI (CARDS)
CREATE TABLE cards (
    id SERIAL PRIMARY KEY,
    list_id INT NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    position NUMERIC(10, 2) NOT NULL DEFAULT 65535,
    start_date TIMESTAMP,
    due_date TIMESTAMP,
    is_completed BOOLEAN DEFAULT FALSE,
    is_archived BOOLEAN DEFAULT FALSE,
    cover_image_url VARCHAR(255),
    created_by INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. KARTA MAS'ULLARI (CARD MEMBERS)
CREATE TABLE card_members (
    id SERIAL PRIMARY KEY,
    card_id INT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(card_id, user_id)
);

-- 10. YORLIQLAR / TEGLAR (LABELS)
CREATE TABLE labels (
    id SERIAL PRIMARY KEY,
    board_id INT NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
    name VARCHAR(50),
    color_code VARCHAR(20) NOT NULL, -- Masalan: #61bd4f (yashil), #f2d600 (sariq)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. KARTALARDAGI YORLIQLAR (CARD LABELS)
CREATE TABLE card_labels (
    id SERIAL PRIMARY KEY,
    card_id INT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    label_id INT NOT NULL REFERENCES labels(id) ON DELETE CASCADE,
    UNIQUE(card_id, label_id)
);

-- 12. CHECKLISTLAR (CHECKLISTS)
CREATE TABLE checklists (
    id SERIAL PRIMARY KEY,
    card_id INT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL DEFAULT 'Checklist',
    position NUMERIC(10, 2) NOT NULL DEFAULT 65535,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. CHECKLIST BANDLARI (CHECKLIST ITEMS)
CREATE TABLE checklist_items (
    id SERIAL PRIMARY KEY,
    checklist_id INT NOT NULL REFERENCES checklists(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    position NUMERIC(10, 2) NOT NULL DEFAULT 65535,
    due_date TIMESTAMP,
    assigned_to INT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. BIRIKTIRILGAN FAYLLAR (ATTACHMENTS)
CREATE TABLE attachments (
    id SERIAL PRIMARY KEY,
    card_id INT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    uploaded_by INT NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    file_name VARCHAR(255) NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_size INT, -- baytlarda
    file_type VARCHAR(100),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. IZOHLAR (COMMENTS)
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    card_id INT NOT NULL REFERENCES cards(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 16. FAOLIYAT TARIXI (ACTIVITIES / AUDIT LOG)
CREATE TABLE activities (
    id SERIAL PRIMARY KEY,
    board_id INT NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
    card_id INT REFERENCES cards(id) ON DELETE SET NULL,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL, -- card_created, moved_list, comment_added va h.k.
    details JSON, -- o'zgarishlar tafsiloti
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
