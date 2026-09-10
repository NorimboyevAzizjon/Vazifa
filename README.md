# Trello Maʼlumotlar Bazasi Strukturasi (Database Schema & ERD)

Ushbu loyiha **Trello** topshiriqlar va loyihalarni boshqarish tizimining toʻliq relatsion maʼlumotlar bazasi (Relational Database) strukturasi boʻlib, topshiriq talabidagi barcha qismlarni (`Workspaces`, `Boards`, `Lists`, `Cards`, `Members`, `Templates` va boshqalar) qamrab oladi.

---

## 📌 Topshirish uchun havola (Link) olish — 1 daqiqalik yoʻriqnoma:

Siz ushbu tayyorlangan maʼlumotlar bazasi chizmasini tekshiruvchiga topshirish uchun quyidagi qadamlarni bajaring:

### 1-USUL: [dbdiagram.io](https://dbdiagram.io) (Eng oson va qulay)
1. Brauzerda [dbdiagram.io](https://dbdiagram.io) saytiga kiring.
2. Ushbu loyihadagi **`schema.dbml`** fayli ichidagi barcha kodni nusxalang (`Ctrl+A`, `Ctrl+C`).
3. **dbdiagram.io** chap tomonidagi maydonga kodni qoʻying (`Ctrl+V`). Oʻng tomonda barcha jadvallar va ularning bogʻlanishlari chiroyli ranglar bilan avtomatik chiziladi.
4. Yuqori oʻng tarafdagi **"Share"** tugmasini bosing va havola (URL)ni nusxalab, vazifaga yuboring!

### 2-USUL: [drawsql.app](https://drawsql.app)
1. [drawsql.app](https://drawsql.app) saytiga kiring.
2. Yangi diagramma yarating va **"Import SQL"** tugmasini bosing.
3. Ushbu loyihadagi **`database_schema.sql`** fayli ichidagi SQL kodni qoʻying.
4. Tizim jadvallarni avtomatik joylashtiradi, **"Share"** orqali public havolani oling.

---

## 🏗 Maʼlumotlar Bazasi Jadvallari Roʻyxati (Tables)

| № | Jadval nomi | Tavsifi va Vazifasi | Asosiy maydonlar |
|---|-------------|---------------------|------------------|
| 1 | **`users`** | Tizim foydalanuvchilari | `id`, `username`, `email`, `password_hash`, `full_name`, `avatar_url` |
| 2 | **`workspaces`** | Ishchi maydonlar (Jamoalar) | `id`, `name`, `slug`, `workspace_type`, `owner_id` |
| 3 | **`workspace_members`** | Ishchi maydon aʼzolari va rollari | `id`, `workspace_id`, `user_id`, `role` (owner/admin/member) |
| 4 | **`boards`** | Doskalar (Loyiha maydonlari) | `id`, `workspace_id`, `title`, `visibility`, `background_color`, `is_template` |
| 5 | **`board_members`** | Doskaga biriktirilgan aʼzolar | `id`, `board_id`, `user_id`, `role` (admin/normal/observer) |
| 6 | **`templates`** | Doska va vazifa shablonlari | `id`, `board_id`, `title`, `description`, `category`, `is_public` |
| 7 | **`lists`** | Ustunlar / Bosqichlar ("To Do", "In Progress", "Done") | `id`, `board_id`, `title`, `position`, `is_archived` |
| 8 | **`cards`** | Vazifa kartochkalari | `id`, `list_id`, `title`, `description`, `position`, `due_date`, `is_completed` |
| 9 | **`card_members`** | Kartochka ijrochilari (Many-to-Many) | `id`, `card_id`, `user_id`, `assigned_at` |
| 10 | **`labels`** | Yorliqlar / Rangli teglar | `id`, `board_id`, `name`, `color_code` |
| 11 | **`card_labels`** | Kartalarga yorliqlarni biriktirish | `id`, `card_id`, `label_id` |
| 12 | **`checklists`** | Karta ichidagi tekshiruv roʻyxatlari | `id`, `card_id`, `title`, `position` |
| 13 | **`checklist_items`** | Tekshiruv roʻyxatidagi kichik bandlar | `id`, `checklist_id`, `title`, `is_completed`, `due_date`, `assigned_to` |
| 14 | **`attachments`** | Biriktirilgan fayllar va rasmlar | `id`, `card_id`, `uploaded_by`, `file_name`, `file_url`, `file_size` |
| 15 | **`comments`** | Kartalarga yozilgan izohlar | `id`, `card_id`, `user_id`, `content`, `created_at` |
| 16 | **`activities`** | Harakatlar va oʻzgarishlar tarixi (Audit log) | `id`, `board_id`, `card_id`, `user_id`, `action_type`, `details` |

---

## 🔗 Jadvallar Oʻrtasidagi Bogʻlanishlar (Relationships)

1. **Workspaces & Users**:
   - `workspaces.owner_id` $\rightarrow$ `users.id` (Har bir ishchi maydon bitta egasiga tegishli).
   - `workspace_members`: Bir foydalanuvchi bir nechta workspace'da a'zo bo'lishi mumkin (Many-to-Many).
2. **Boards & Workspaces**:
   - `boards.workspace_id` $\rightarrow$ `workspaces.id` (Bitta workspace ichida ko'plab doskalar bo'ladi: One-to-Many).
   - `board_members`: Doskada ishtirok etuvchi a'zolar (Many-to-Many).
3. **Templates & Boards**:
   - `templates.board_id` $\rightarrow$ `boards.id` (Shablon doska asosida yaratiladi).
4. **Lists & Boards**:
   - `lists.board_id` $\rightarrow$ `boards.id` (Bitta doska ichida bir nechta ustunlar bo'ladi: One-to-Many).
5. **Cards & Lists**:
   - `cards.list_id` $\rightarrow$ `lists.id` (Har bir karta muayyan ustunga tegishli).
   - `card_members`: Kartada bir yoki bir nechta a'zo mas'ul bo'lishi mumkin (Many-to-Many).
6. **Labels, Checklists, Attachments, Comments**:
   - Barchasi tegishli `cards` va `boards` jadvallariga Foreign Key orqali bog'langan.

---

## 📂 Loyiha Fayllari:
- **`schema.dbml`** — `dbdiagram.io` uchun tayyor deklarativ kod.
- **`database_schema.sql`** — `drawsql.app`, `sqldbm.com` yoki to'g'ridan-to'g'ri PostgreSQL/MySQL uchun DDL skript.
- **`trello_erd_diagram.html`** — Brauzerda ochib ko'rish mumkin bo'lgan interaktiv vizual ko'rinish.
