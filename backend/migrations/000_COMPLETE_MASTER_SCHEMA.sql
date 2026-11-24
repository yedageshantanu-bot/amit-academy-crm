-- ==============================================================================
-- 🚀 MASTER COMPLETE DATABASE SCHEMA (ALL 30 CRM TABLES)
-- Target: Fresh Isolated Supabase PostgreSQL Instance (1 per Client)
-- Safe & Idempotent: Uses CREATE TABLE IF NOT EXISTS / ADD COLUMN IF NOT EXISTS
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. ACADEMY SETTINGS
CREATE TABLE IF NOT EXISTS public.academy_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academy_name TEXT NOT NULL DEFAULT 'My Academy CRM',
    logo_url TEXT NULL DEFAULT '/logo.png',
    phone TEXT NULL,
    email TEXT NULL,
    address TEXT NULL,
    website TEXT NULL,
    currency TEXT NOT NULL DEFAULT 'INR',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. USER PROFILES (Linked 1:1 to Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('ADMIN', 'TEACHER', 'STUDENT', 'DEMO_ADMIN')),
    full_name TEXT NOT NULL,
    phone TEXT NULL,
    email TEXT NOT NULL,
    avatar_url TEXT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    is_trial BOOLEAN NOT NULL DEFAULT false,
    trial_started_at TIMESTAMPTZ NULL,
    trial_expires_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. TEACHERS / COACHES
CREATE TABLE IF NOT EXISTS public.teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NULL,
    subject TEXT NULL,
    username TEXT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. STUDENTS / ATHLETES
CREATE TABLE IF NOT EXISTS public.students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    parent_name TEXT NULL,
    student_mobile TEXT NULL,
    parent_whatsapp TEXT NULL,
    email TEXT NULL,
    course TEXT NULL,
    admission_date DATE NOT NULL DEFAULT CURRENT_DATE,
    monthly_fee NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    fee_due_day INTEGER NOT NULL DEFAULT 5 CHECK (fee_due_day >= 1 AND fee_due_day <= 31),
    whatsapp_opt_in BOOLEAN NOT NULL DEFAULT true,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. BATCHES
CREATE TABLE IF NOT EXISTS public.batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    subject TEXT NULL,
    description TEXT NULL,
    monthly_fee NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    schedule_days TEXT[] NOT NULL DEFAULT '{}',
    start_time TIME NULL,
    end_time TIME NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. BATCH STUDENTS
CREATE TABLE IF NOT EXISTS public.batch_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    joined_at DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    UNIQUE (batch_id, student_id)
);

-- 7. BATCH TEACHERS
CREATE TABLE IF NOT EXISTS public.batch_teachers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    teacher_id UUID NOT NULL REFERENCES public.teachers(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (batch_id, teacher_id)
);

-- 8. ATTENDANCE (Roll Call + Correction Audit)
CREATE TABLE IF NOT EXISTS public.attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    teacher_id UUID NULL REFERENCES public.teachers(id) ON DELETE SET NULL,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    status TEXT NOT NULL CHECK (status IN ('PRESENT', 'ABSENT')),
    marked_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    corrected_at TIMESTAMPTZ NULL,
    corrected_by UUID NULL REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (student_id, batch_id, date)
);

-- 9. FEE PLANS
CREATE TABLE IF NOT EXISTS public.fee_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    amount NUMERIC(12,2) NOT NULL,
    frequency TEXT NOT NULL DEFAULT 'MONTHLY' CHECK (frequency IN ('MONTHLY', 'QUARTERLY', 'YEARLY', 'CUSTOM')),
    due_day INTEGER NULL CHECK (due_day >= 1 AND due_day <= 31),
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 10. STUDENT FEES
CREATE TABLE IF NOT EXISTS public.student_fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    fee_plan_id UUID NULL REFERENCES public.fee_plans(id) ON DELETE SET NULL,
    billing_period TEXT NOT NULL, -- e.g. '2026-11'
    amount_due NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    due_date DATE NOT NULL,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PAID', 'PENDING', 'OVERDUE', 'PARTIAL', 'PARTIALLY_PAID')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (student_id, billing_period)
);

-- 11. PAYMENTS
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_fee_id UUID NULL REFERENCES public.student_fees(id) ON DELETE SET NULL,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    amount NUMERIC(12,2) NOT NULL,
    payment_method TEXT NOT NULL DEFAULT 'UPI',
    provider TEXT NOT NULL DEFAULT 'MANUAL',
    transaction_id TEXT NULL,
    provider_payment_id TEXT NULL,
    provider_order_id TEXT NULL,
    payment_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    paid_at TIMESTAMPTZ NULL DEFAULT now(),
    status TEXT NOT NULL DEFAULT 'SUCCESS' CHECK (status IN ('CREATED', 'PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),
    notes TEXT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 12. RECEIPTS
CREATE TABLE IF NOT EXISTS public.receipts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    receipt_number TEXT NOT NULL UNIQUE,
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    amount NUMERIC(12,2) NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    pdf_url TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 13. ANNOUNCEMENTS (Supports Immediate & Multi-Slot Scheduled Broadcasts via metadata)
CREATE TABLE IF NOT EXISTS public.announcements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'NORMAL' CHECK (priority IN ('LOW', 'NORMAL', 'HIGH', 'URGENT')),
    scope TEXT NOT NULL DEFAULT 'ALL' CHECK (scope IN ('ALL', 'SPECIFIC_BATCHES')),
    status TEXT NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'SENT', 'SCHEDULED', 'SENDING', 'CANCELLED')),
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_by UUID NULL,
    sent_at TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 14. ANNOUNCEMENT BATCHES
CREATE TABLE IF NOT EXISTS public.announcement_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    announcement_id UUID NOT NULL REFERENCES public.announcements(id) ON DELETE CASCADE,
    batch_id UUID NOT NULL REFERENCES public.batches(id) ON DELETE CASCADE,
    UNIQUE (announcement_id, batch_id)
);

-- 15. WHATSAPP TEMPLATES
CREATE TABLE IF NOT EXISTS public.whatsapp_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    event_type TEXT NOT NULL UNIQUE,
    body TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 16. WHATSAPP SETTINGS
CREATE TABLE IF NOT EXISTS public.whatsapp_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    global_automation_enabled BOOLEAN NOT NULL DEFAULT true,
    emergency_stop BOOLEAN NOT NULL DEFAULT false,
    daily_limit INTEGER NOT NULL DEFAULT 100 CHECK (daily_limit >= 1 AND daily_limit <= 5000),
    provider_type TEXT NOT NULL DEFAULT 'openwa',
    device_phone_number TEXT NULL,
    device_status TEXT NOT NULL DEFAULT 'NOT_CONFIGURED',
    last_connected_at TIMESTAMPTZ NULL,
    last_heartbeat_at TIMESTAMPTZ NULL,
    session_metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 17. WHATSAPP QUEUE
CREATE TABLE IF NOT EXISTS public.whatsapp_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_phone TEXT NOT NULL,
    student_id UUID NULL REFERENCES public.students(id) ON DELETE SET NULL,
    template_id UUID NULL REFERENCES public.whatsapp_templates(id) ON DELETE SET NULL,
    event_type TEXT NOT NULL,
    message_body TEXT NOT NULL,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'SENT', 'FAILED', 'CANCELLED')),
    attempts INTEGER NOT NULL DEFAULT 0,
    max_attempts INTEGER NOT NULL DEFAULT 3,
    sent_at TIMESTAMPTZ NULL,
    failure_reason TEXT NULL,
    idempotency_key TEXT UNIQUE NULL,
    provider_message_id TEXT NULL,
    metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 18. WHATSAPP MESSAGES (Audit Outbox)
CREATE TABLE IF NOT EXISTS public.whatsapp_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID NULL REFERENCES public.whatsapp_templates(id) ON DELETE SET NULL,
    student_id UUID NULL REFERENCES public.students(id) ON DELETE SET NULL,
    recipient_phone TEXT NOT NULL,
    event_type TEXT NOT NULL,
    message_body TEXT NOT NULL,
    provider_message_id TEXT NULL,
    status TEXT NOT NULL DEFAULT 'SENT',
    error_message TEXT NULL,
    sent_at TIMESTAMPTZ NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 19. WHATSAPP AUTH STATE (Isolated Baileys Multi-Device Session Store)
CREATE TABLE IF NOT EXISTS public.whatsapp_auth_state (
    session_id TEXT NOT NULL,
    key_id TEXT NOT NULL,
    value TEXT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (session_id, key_id)
);

-- 20. TOURNAMENTS / EVENTS
CREATE TABLE IF NOT EXISTS public.tournaments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    discipline TEXT NULL,
    organizer TEXT NULL,
    venue TEXT NOT NULL,
    tournament_date DATE NOT NULL,
    registration_deadline DATE NULL,
    entry_fee NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    status TEXT NOT NULL DEFAULT 'UPCOMING' CHECK (status IN ('UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED')),
    description TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 21. TOURNAMENT REGISTRATIONS
CREATE TABLE IF NOT EXISTS public.tournament_registrations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tournament_id UUID NOT NULL REFERENCES public.tournaments(id) ON DELETE CASCADE,
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    category TEXT NULL,
    fee_amount NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    payment_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PARTIAL', 'PAID', 'WAIVED')),
    payment_method TEXT NULL,
    payment_date TIMESTAMPTZ NULL,
    settlement_notes TEXT NULL,
    selection_status TEXT NOT NULL DEFAULT 'SELECTED',
    whatsapp_notified BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tournament_id, student_id)
);

-- 22. DISCIPLINES / SKILL TRACKS (Martial Arts / Sports / Academic Levels)
CREATE TABLE IF NOT EXISTS public.martial_arts_disciplines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 23. RANKS / BELTS / LEVELS
CREATE TABLE IF NOT EXISTS public.martial_arts_ranks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    discipline_code TEXT NOT NULL REFERENCES public.martial_arts_disciplines(code) ON DELETE CASCADE,
    rank_order INTEGER NOT NULL DEFAULT 1,
    rank_name TEXT NOT NULL,
    belt_color TEXT NOT NULL DEFAULT 'White',
    description TEXT NULL,
    syllabus TEXT NULL,
    badge_bg TEXT NOT NULL DEFAULT '#1e293b',
    badge_text TEXT NOT NULL DEFAULT '#ffffff',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 24. STUDENT RANKS
CREATE TABLE IF NOT EXISTS public.student_ranks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    discipline_code TEXT NOT NULL REFERENCES public.martial_arts_disciplines(code) ON DELETE CASCADE,
    current_rank_id UUID NULL REFERENCES public.martial_arts_ranks(id) ON DELETE SET NULL,
    reg_number TEXT NULL,
    dob DATE NULL,
    represented_from TEXT NULL,
    promoted_at DATE NULL,
    promoted_by TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (student_id, discipline_code)
);

-- 25. RANK PROMOTIONS & CERTIFICATE REGISTRY
CREATE TABLE IF NOT EXISTS public.rank_promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES public.students(id) ON DELETE CASCADE,
    discipline_code TEXT NOT NULL,
    previous_rank_name TEXT NULL,
    new_rank_id UUID NULL REFERENCES public.martial_arts_ranks(id) ON DELETE SET NULL,
    new_rank_name TEXT NOT NULL,
    reg_number TEXT NULL,
    dob DATE NULL,
    represented_from TEXT NULL,
    promotion_date DATE NOT NULL DEFAULT CURRENT_DATE,
    promoted_by TEXT NULL,
    certificate_number TEXT NULL,
    notes TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 26. PUBLICATION / ANNUAL MANUAL STUDENTS
CREATE TABLE IF NOT EXISTS public.publication_students (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NULL REFERENCES public.students(id) ON DELETE SET NULL,
    is_external BOOLEAN NOT NULL DEFAULT false,
    student_name TEXT NOT NULL,
    parent_name TEXT NULL,
    contact_number TEXT NOT NULL,
    email TEXT NULL,
    publication_title TEXT NOT NULL,
    academic_year TEXT NOT NULL DEFAULT '2026-2027',
    annual_fee NUMERIC(12,2) NOT NULL DEFAULT 200.00,
    amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0.00,
    fee_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (fee_status IN ('PAID', 'PENDING', 'PARTIAL', 'OVERDUE')),
    renewal_due_date DATE NULL,
    delivery_status TEXT NOT NULL DEFAULT 'PENDING' CHECK (delivery_status IN ('DISPATCHED', 'HANDED_OVER', 'IN_PRINT', 'PENDING')),
    payment_method TEXT NULL,
    notes TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 27. TEAMS / GROUPS DIRECTORY
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    marathi_name TEXT NULL,
    description TEXT NULL,
    color TEXT NOT NULL DEFAULT 'indigo',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 28. TEAM MEMBERS
CREATE TABLE IF NOT EXISTS public.team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NULL,
    phone TEXT NOT NULL,
    position TEXT NULL,
    team_code TEXT NOT NULL DEFAULT 'ALL',
    district TEXT NULL,
    notes TEXT NULL,
    status TEXT NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 29. TEAM MESSAGES
CREATE TABLE IF NOT EXISTS public.team_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_name TEXT NULL,
    sender_position TEXT NULL,
    recipient_role TEXT NOT NULL DEFAULT 'ALL_STAFF',
    subject TEXT NULL,
    message TEXT NOT NULL,
    priority TEXT NOT NULL DEFAULT 'NORMAL',
    status TEXT NOT NULL DEFAULT 'SENT',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 30. ENQUIRIES / ADMISSIONS LEADS
CREATE TABLE IF NOT EXISTS public.enquiries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NULL,
    course_interest TEXT NULL,
    source TEXT NULL DEFAULT 'DIRECT',
    status TEXT NOT NULL DEFAULT 'NEW',
    notes TEXT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ==============================================================================
-- PERFORMANCE INDEXES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_students_status ON public.students(status);
CREATE INDEX IF NOT EXISTS idx_students_parent_whatsapp ON public.students(parent_whatsapp);
CREATE INDEX IF NOT EXISTS idx_batches_status ON public.batches(status);
CREATE INDEX IF NOT EXISTS idx_batch_students_batch_id ON public.batch_students(batch_id);
CREATE INDEX IF NOT EXISTS idx_batch_students_student_id ON public.batch_students(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_batch_date ON public.attendance(batch_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_student_date ON public.attendance(student_id, date);
CREATE INDEX IF NOT EXISTS idx_student_fees_status_due ON public.student_fees(status, due_date);
CREATE INDEX IF NOT EXISTS idx_payments_student_created ON public.payments(student_id, created_at);
CREATE INDEX IF NOT EXISTS idx_whatsapp_queue_status_scheduled ON public.whatsapp_queue(status, scheduled_at);
CREATE INDEX IF NOT EXISTS idx_whatsapp_auth_state_session ON public.whatsapp_auth_state(session_id);
CREATE INDEX IF NOT EXISTS idx_team_members_team_code ON public.team_members(team_code);

-- ==============================================================================
-- SEED DEFAULT WHATSAPP SETTINGS & TEMPLATES (CLEAN, CLIENT-NEUTRAL)
-- ==============================================================================
INSERT INTO public.whatsapp_settings (
    global_automation_enabled, emergency_stop, daily_limit, provider_type, device_status
)
SELECT true, false, 100, 'openwa', 'NOT_CONFIGURED'
WHERE NOT EXISTS (SELECT 1 FROM public.whatsapp_settings);

INSERT INTO public.whatsapp_templates (name, event_type, body, active) VALUES
('Absent Alert', 'ATTENDANCE_ABSENT', 'Dear {{parent_name}}, {{student_name}} was marked ABSENT today in batch {{batch_name}}. Please inform the academy if on leave.', true),
('Attendance Correction Alert', 'ATTENDANCE_CORRECTION', 'Dear {{parent_name}}, {{student_name}} has now arrived and is marked PRESENT in batch {{batch_name}}.', true),
('Fee Due Reminder', 'FEE_REMINDER', 'Dear {{parent_name}}, tuition fee of ₹{{amount_due}} for {{student_name}} ({{billing_period}}) is due on {{due_date}}. Kindly settle at your convenience.', true),
('Payment Receipt Confirmation', 'PAYMENT_RECEIPT', 'Dear {{parent_name}}, thank you! Payment of ₹{{amount_paid}} for {{student_name}} has been received. Receipt: {{receipt_number}}.', true)
ON CONFLICT (event_type) DO NOTHING;
