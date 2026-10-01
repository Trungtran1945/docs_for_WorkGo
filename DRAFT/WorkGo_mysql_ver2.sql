-- ============================================================
-- 1. IDENTITY SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS identity_service;

CREATE TABLE IF NOT EXISTS identity_service.users (
    id                  VARCHAR(26) PRIMARY KEY,
    email               VARCHAR(320) NOT NULL UNIQUE,
    password_hash       TEXT NOT NULL,
    full_name           VARCHAR(255) NOT NULL,
    phone               VARCHAR(50),
    avatar_url          TEXT,
    status              ENUM('ACTIVE','INACTIVE','SUSPENDED','BANNED','PENDING_VERIFICATION') NOT NULL DEFAULT 'ACTIVE',
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS identity_service.user_role (
    user_id             VARCHAR(26) NOT NULL,
    role                ENUM('ADMIN','CLIENT','PROVIDER') NOT NULL,
    granted_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role),
    CONSTRAINT fk_user_role_user
        FOREIGN KEY (user_id) REFERENCES identity_service.users(id)
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS identity_service.provider_profile (
    user_id                 VARCHAR(26) PRIMARY KEY,
    provider_type           ENUM('FREELANCER','AGENCY','COMPANY'),
    business_name           VARCHAR(255),
    bio                     TEXT,
    verification_status     ENUM('UNVERIFIED','PENDING','VERIFIED','REJECTED'),
    rating_avg              NUMERIC(3,2),
    rating_count            INTEGER NOT NULL DEFAULT 0,
    completed_order_count   INTEGER NOT NULL DEFAULT 0,
    is_accepting_orders     BOOLEAN NOT NULL DEFAULT TRUE,
    joined_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_provider_profile_user
        FOREIGN KEY (user_id) REFERENCES identity_service.users(id)
        ON DELETE CASCADE,
    CONSTRAINT chk_provider_rating_avg CHECK (rating_avg IS NULL OR rating_avg BETWEEN 0 AND 5),
    CONSTRAINT chk_provider_rating_count CHECK (rating_count >= 0),
    CONSTRAINT chk_provider_completed_orders CHECK (completed_order_count >= 0)
);

CREATE TABLE IF NOT EXISTS identity_service.address (
    id                  VARCHAR(26) PRIMARY KEY,
    user_id             VARCHAR(26) NOT NULL,
    label               VARCHAR(100),
    contact_name        VARCHAR(255),
    contact_phone       VARCHAR(50),
    line1               TEXT NOT NULL,
    ward                VARCHAR(150),
    district            VARCHAR(150),
    city                VARCHAR(150),
    country_code        CHAR(2),
    latitude            NUMERIC(10,7),
    longitude           NUMERIC(10,7),
    note                TEXT,
    is_default          BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_address_user
        FOREIGN KEY (user_id) REFERENCES identity_service.users(id)
        ON DELETE CASCADE
);
CREATE INDEX idx_address_user_id ON identity_service.address(user_id);
CREATE INDEX idx_address_default_user ON identity_service.address(user_id, is_default);

-- EDA Tables for Identity
CREATE TABLE IF NOT EXISTS identity_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS identity_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);

-- ============================================================
-- 2. CATALOG SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS catalog_service;

CREATE TABLE IF NOT EXISTS catalog_service.category (
    id                  VARCHAR(26) PRIMARY KEY,
    parent_id           VARCHAR(26),
    name                VARCHAR(150) NOT NULL,
    slug                VARCHAR(180) NOT NULL UNIQUE,
    description         TEXT,
    status              ENUM('ACTIVE','INACTIVE','ARCHIVED') NOT NULL,
    sort_order          INTEGER NOT NULL DEFAULT 0,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_id) REFERENCES catalog_service.category(id)
        ON DELETE SET NULL
);
CREATE INDEX idx_category_parent_id ON catalog_service.category(parent_id);

CREATE TABLE IF NOT EXISTS catalog_service.service (
    id                  VARCHAR(26) PRIMARY KEY,
    provider_id         VARCHAR(26) NOT NULL,
    category_id         VARCHAR(26) NOT NULL,
    execution_type      ENUM('DIGITAL','ONSITE','APPOINTMENT','HOURLY','PROJECT','DELIVERY') NOT NULL,
    title               VARCHAR(255) NOT NULL,
    slug                VARCHAR(255) NOT NULL UNIQUE,
    description         TEXT,
    base_price          NUMERIC(19,4) NOT NULL,
    currency            ENUM('VND','USD','EUR') NOT NULL,
    status              ENUM('DRAFT','PUBLISHED','ARCHIVED','SUSPENDED') NOT NULL,
    avg_rating          NUMERIC(3,2),
    review_count        INTEGER NOT NULL DEFAULT 0,
    order_count         INTEGER NOT NULL DEFAULT 0,
    published_at        TIMESTAMP,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_category FOREIGN KEY (category_id) REFERENCES catalog_service.category(id),
    CONSTRAINT chk_service_rating CHECK (avg_rating IS NULL OR avg_rating BETWEEN 0 AND 5),
    CONSTRAINT chk_service_price CHECK (base_price >= 0)
);
CREATE INDEX idx_service_provider_id ON catalog_service.service(provider_id);
CREATE INDEX idx_service_category_id ON catalog_service.service(category_id);

CREATE TABLE IF NOT EXISTS catalog_service.service_media (
    id                  VARCHAR(26) PRIMARY KEY,
    service_id          VARCHAR(26) NOT NULL,
    url                 TEXT NOT NULL,
    media_type          ENUM('IMAGE','VIDEO','DOCUMENT') NOT NULL,
    is_cover            BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order          INTEGER NOT NULL DEFAULT 0,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_media_service FOREIGN KEY (service_id) REFERENCES catalog_service.service(id) ON DELETE CASCADE
);
CREATE INDEX idx_service_media_service_id ON catalog_service.service_media(service_id);

CREATE TABLE IF NOT EXISTS catalog_service.service_package (
    id                  VARCHAR(26) PRIMARY KEY,
    service_id          VARCHAR(26) NOT NULL,
    name                VARCHAR(100) NOT NULL,
    description         TEXT,
    price               NUMERIC(19,4) NOT NULL,
    currency            ENUM('VND','USD','EUR') NOT NULL,
    delivery_days       INTEGER,
    duration_minutes    INTEGER,
    revision_limit      INTEGER,
    features            JSON,
    sort_order          INTEGER NOT NULL DEFAULT 0,
    status              ENUM('ACTIVE','INACTIVE') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_package_service FOREIGN KEY (service_id) REFERENCES catalog_service.service(id) ON DELETE CASCADE
);
CREATE INDEX idx_service_package_service_id ON catalog_service.service_package(service_id);

CREATE TABLE IF NOT EXISTS catalog_service.service_addon (
    id                  VARCHAR(26) PRIMARY KEY,
    service_id          VARCHAR(26) NOT NULL,
    name                VARCHAR(150) NOT NULL,
    description         TEXT,
    price               NUMERIC(19,4) NOT NULL,
    currency            ENUM('VND','USD','EUR') NOT NULL,
    status              ENUM('ACTIVE','INACTIVE') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_service_addon_service FOREIGN KEY (service_id) REFERENCES catalog_service.service(id) ON DELETE CASCADE
);
CREATE INDEX idx_service_addon_service_id ON catalog_service.service_addon(service_id);

CREATE TABLE IF NOT EXISTS catalog_service.availability_rule (
    id                      VARCHAR(26) PRIMARY KEY,
    service_id              VARCHAR(26) NOT NULL,
    day_of_week             SMALLINT NOT NULL,
    start_time              TIME NOT NULL,
    end_time                TIME NOT NULL,
    slot_duration_minutes   INTEGER NOT NULL,
    status                  ENUM('ACTIVE','INACTIVE') NOT NULL,
    CONSTRAINT fk_availability_rule_service FOREIGN KEY (service_id) REFERENCES catalog_service.service(id) ON DELETE CASCADE
);
CREATE INDEX idx_availability_rule_service_id ON catalog_service.availability_rule(service_id);

CREATE TABLE IF NOT EXISTS catalog_service.booking_slot (
    id                  VARCHAR(26) PRIMARY KEY,
    service_id          VARCHAR(26) NOT NULL,
    start_at            TIMESTAMP NOT NULL,
    end_at              TIMESTAMP NOT NULL,
    status              ENUM('AVAILABLE','LOCKED','BOOKED','CANCELLED','COMPLETED') NOT NULL,
    hold_expires_at     TIMESTAMP NULL,
    order_id            VARCHAR(26),
    version             BIGINT NOT NULL DEFAULT 0,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_booking_slot_service FOREIGN KEY (service_id) REFERENCES catalog_service.service(id) ON DELETE CASCADE
);
CREATE INDEX idx_booking_slot_service_time ON catalog_service.booking_slot(service_id, start_at, end_at);

-- EDA Tables for Catalog
CREATE TABLE IF NOT EXISTS catalog_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS catalog_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);

-- ============================================================
-- 3. POST SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS post_service;

CREATE TABLE IF NOT EXISTS post_service.post (
    id                  VARCHAR(26) PRIMARY KEY,
    client_id           VARCHAR(26) NOT NULL,
    category_id         VARCHAR(26) NOT NULL,
    title               VARCHAR(255) NOT NULL,
    description         TEXT NOT NULL,
    budget_min          NUMERIC(19,4),
    budget_max          NUMERIC(19,4),
    currency            ENUM('VND','USD','EUR') NOT NULL,
    execution_type      ENUM('DIGITAL','ONSITE','APPOINTMENT','HOURLY','PROJECT','DELIVERY') NOT NULL,
    location_snapshot   JSON,
    deadline_at         TIMESTAMP NULL,
    status              ENUM('DRAFT','PUBLISHED','CLOSED','CANCELLED') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_post_client_id ON post_service.post(client_id);
CREATE INDEX idx_post_category_id ON post_service.post(category_id);
CREATE INDEX idx_post_status ON post_service.post(status);

CREATE TABLE IF NOT EXISTS post_service.post_attachment (
    id                  VARCHAR(26) PRIMARY KEY,
    job_id              VARCHAR(26) NOT NULL,
    file_url            TEXT NOT NULL,
    file_name           VARCHAR(255),
    mime_type           VARCHAR(150),
    size_bytes          BIGINT,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_post_attachment_post FOREIGN KEY (job_id) REFERENCES post_service.post(id) ON DELETE CASCADE
);
CREATE INDEX idx_post_attachment_post_id ON post_service.post_attachment(job_id);

CREATE TABLE IF NOT EXISTS post_service.application (
    id                  VARCHAR(26) PRIMARY KEY,
    job_id              VARCHAR(26) NOT NULL,
    provider_id         VARCHAR(26) NOT NULL,
    message             TEXT,
    status              ENUM('PENDING','ACCEPTED','REJECTED','WITHDRAWN') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_application_post FOREIGN KEY (job_id) REFERENCES post_service.post(id) ON DELETE CASCADE,
    CONSTRAINT uq_application_post_provider UNIQUE (job_id, provider_id)
);
CREATE INDEX idx_application_provider_id ON post_service.application(provider_id);

CREATE TABLE IF NOT EXISTS post_service.proposal (
    id                  VARCHAR(26) PRIMARY KEY,
    job_id              VARCHAR(26) NOT NULL,
    application_id      VARCHAR(26) NOT NULL,
    price               NUMERIC(19,4) NOT NULL,
    currency            ENUM('VND','USD','EUR') NOT NULL,
    estimated_days      INTEGER,
    message             TEXT,
    terms               TEXT,
    expires_at          TIMESTAMP NULL,
    status              ENUM('PENDING','ACCEPTED','REJECTED','EXPIRED') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_proposal_post FOREIGN KEY (job_id) REFERENCES post_service.post(id) ON DELETE CASCADE,
    CONSTRAINT fk_proposal_application FOREIGN KEY (application_id) REFERENCES post_service.application(id) ON DELETE CASCADE
);
CREATE INDEX idx_proposal_job_id ON post_service.proposal(job_id);
CREATE INDEX idx_proposal_application_id ON post_service.proposal(application_id);

-- EDA Tables for Post
CREATE TABLE IF NOT EXISTS post_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS post_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);

-- ============================================================
-- 4. COMMUNICATION SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS communication_service;

CREATE TABLE IF NOT EXISTS communication_service.conversation (
    id                  VARCHAR(26) PRIMARY KEY,
    conversation_type   ENUM('DIRECT_MESSAGE','GROUP_CHAT','SUPPORT_TICKET') NOT NULL,
    context_type        ENUM('ORDER','DISPUTE','GENERAL') NOT NULL,
    context_id          VARCHAR(26),
    status              ENUM('ACTIVE','ARCHIVED','CLOSED') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_message_at     TIMESTAMP NULL
);
CREATE INDEX idx_conversation_context ON communication_service.conversation(context_type, context_id);

CREATE TABLE IF NOT EXISTS communication_service.conversation_participant (
    conversation_id     VARCHAR(26) NOT NULL,
    user_id             VARCHAR(26) NOT NULL,
    joined_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_read_at        TIMESTAMP NULL,
    PRIMARY KEY (conversation_id, user_id),
    CONSTRAINT fk_conversation_participant_conversation FOREIGN KEY (conversation_id) REFERENCES communication_service.conversation(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS communication_service.message (
    id                  VARCHAR(26) PRIMARY KEY,
    conversation_id     VARCHAR(26) NOT NULL,
    sender_id           VARCHAR(26) NOT NULL,
    content             TEXT,
    message_type        ENUM('TEXT','IMAGE','FILE','SYSTEM_EVENT','PROPOSAL') NOT NULL,
    sent_at             TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at             TIMESTAMP NULL,
    CONSTRAINT fk_message_conversation FOREIGN KEY (conversation_id) REFERENCES communication_service.conversation(id) ON DELETE CASCADE
);
CREATE INDEX idx_message_conversation_sent ON communication_service.message(conversation_id, sent_at);

CREATE TABLE IF NOT EXISTS communication_service.media_attachment (
    id                  VARCHAR(26) PRIMARY KEY,
    message_id          VARCHAR(26) NOT NULL,
    file_url            TEXT NOT NULL,
    file_name           VARCHAR(255),
    mime_type           VARCHAR(150),
    size_bytes          BIGINT,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_media_attachment_message FOREIGN KEY (message_id) REFERENCES communication_service.message(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS communication_service.notification (
    id                  VARCHAR(26) PRIMARY KEY,
    recipient_id        VARCHAR(26) NOT NULL,
    type                VARCHAR(100) NOT NULL,
    title               VARCHAR(255) NOT NULL,
    content             TEXT,
    reference_type      VARCHAR(50),
    reference_id        VARCHAR(26),
    read_at             TIMESTAMP NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_notification_recipient ON communication_service.notification(recipient_id, created_at DESC);

-- EDA Tables for Communication
CREATE TABLE IF NOT EXISTS communication_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS communication_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);

-- ============================================================
-- 5. LOGISTIC SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS logistic_service;

CREATE TABLE IF NOT EXISTS logistic_service.logistics_delivery (
    id                    VARCHAR(26) PRIMARY KEY,
    order_id              VARCHAR(26) NOT NULL,
    execution_id          VARCHAR(26) NOT NULL,
    provider_id           VARCHAR(26) NOT NULL,
    pickup_address        JSON NOT NULL,
    destination_address   JSON NOT NULL,
    status                ENUM('PENDING','PICKING_UP','IN_TRANSIT','DELIVERED','FAILED') NOT NULL,
    current_latitude      NUMERIC(10,7),
    current_longitude     NUMERIC(10,7),
    estimated_arrival_at  TIMESTAMP NULL,
    started_at            TIMESTAMP NULL,
    completed_at          TIMESTAMP NULL,
    created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_logistics_delivery_order ON logistic_service.logistics_delivery(order_id);
CREATE INDEX idx_logistics_delivery_execution ON logistic_service.logistics_delivery(execution_id);

CREATE TABLE IF NOT EXISTS logistic_service.location_update (
    id                  VARCHAR(26) PRIMARY KEY,
    delivery_id         VARCHAR(26) NOT NULL,
    latitude            NUMERIC(10,7) NOT NULL,
    longitude           NUMERIC(10,7) NOT NULL,
    captured_at         TIMESTAMP NOT NULL,
    CONSTRAINT fk_location_update_delivery FOREIGN KEY (delivery_id) REFERENCES logistic_service.logistics_delivery(id) ON DELETE CASCADE
);
CREATE INDEX idx_location_update_delivery_time ON logistic_service.location_update(delivery_id, captured_at);

CREATE TABLE IF NOT EXISTS logistic_service.delivery_proof (
    id                  VARCHAR(26) PRIMARY KEY,
    delivery_id         VARCHAR(26) NOT NULL,
    file_url            TEXT NOT NULL,
    file_hash           VARCHAR(255),
    note                TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_delivery_proof_delivery FOREIGN KEY (delivery_id) REFERENCES logistic_service.logistics_delivery(id) ON DELETE CASCADE
);

-- EDA Tables for Logistic
CREATE TABLE IF NOT EXISTS logistic_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS logistic_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);

-- ============================================================
-- 6. PAYMENT SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS payment_service;

CREATE TABLE IF NOT EXISTS payment_service.payment (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL,
    payer_id            VARCHAR(26) NOT NULL,
    purpose             ENUM('ORDER_PAYMENT','ESCROW_DEPOSIT','SUBSCRIPTION_FEE','PENALTY') NOT NULL,
    amount              NUMERIC(19,4) NOT NULL,
    currency            ENUM('VND','USD','EUR') NOT NULL,
    gateway             VARCHAR(100),
    payment_method      ENUM('CREDIT_CARD','PAYPAL','BANK_TRANSFER','E_WALLET','INTERNAL_BALANCE') NOT NULL,
    gateway_txn_id      VARCHAR(255),
    idempotency_key     VARCHAR(255) NOT NULL UNIQUE,
    status              ENUM('PENDING','PROCESSING','SUCCESS','FAILED','CANCELLED') NOT NULL,
    failure_code        VARCHAR(100),
    failure_message     TEXT,
    raw_response        JSON,
    paid_at             TIMESTAMP NULL,
    expires_at          TIMESTAMP NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_payment_order ON payment_service.payment(order_id);

CREATE TABLE IF NOT EXISTS payment_service.escrow_account (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL UNIQUE,
    payment_id          VARCHAR(26),
    held_amount         NUMERIC(19,4) NOT NULL DEFAULT 0,
    released_amount     NUMERIC(19,4) NOT NULL DEFAULT 0,
    refunded_amount     NUMERIC(19,4) NOT NULL DEFAULT 0,
    currency            ENUM('VND','USD','EUR') NOT NULL,
    status              ENUM('HELD','PARTIALLY_RELEASED','RELEASED','REFUNDED') NOT NULL,
    held_at             TIMESTAMP NULL,
    auto_release_at     TIMESTAMP NULL,
    released_at         TIMESTAMP NULL,
    version             BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS payment_service.escrow_transaction (
    id                  VARCHAR(26) PRIMARY KEY,
    escrow_account_id   VARCHAR(26) NOT NULL,
    txn_type            ENUM('DEPOSIT','RELEASE_TO_PROVIDER','REFUND_TO_CLIENT','PLATFORM_FEE_DEDUCTION') NOT NULL,
    amount              NUMERIC(19,4) NOT NULL,
    balance_after       NUMERIC(19,4) NOT NULL,
    triggered_by        VARCHAR(100),
    actor_id            VARCHAR(26),
    reason_code         VARCHAR(100),
    saga_id             VARCHAR(26),
    CONSTRAINT fk_escrow_transaction_account FOREIGN KEY (escrow_account_id) REFERENCES payment_service.escrow_account(id) ON DELETE RESTRICT
);
CREATE INDEX idx_escrow_transaction_account ON payment_service.escrow_transaction(escrow_account_id);

CREATE TABLE IF NOT EXISTS payment_service.refund (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL,
    payment_id          VARCHAR(26) NOT NULL,
    escrow_account_id   VARCHAR(26),
    amount              NUMERIC(19,4) NOT NULL,
    reason_code         VARCHAR(100) NOT NULL,
    initiated_by        VARCHAR(26),
    status              ENUM('PENDING','PROCESSING','SUCCESS','FAILED') NOT NULL,
    gateway_ref         VARCHAR(255),
    processed_at        TIMESTAMP NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_refund_payment FOREIGN KEY (payment_id) REFERENCES payment_service.payment(id) ON DELETE RESTRICT
);
CREATE INDEX idx_refund_order ON payment_service.refund(order_id);
CREATE INDEX idx_refund_payment ON payment_service.refund(payment_id);

-- EDA Tables for Payment
CREATE TABLE IF NOT EXISTS payment_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS payment_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);

-- ============================================================
-- 7. TRUST SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS trust_service;

CREATE TABLE IF NOT EXISTS trust_service.rating (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL,
    reviewer_id         VARCHAR(26) NOT NULL,
    reviewee_id         VARCHAR(26) NOT NULL,
    direction           ENUM('CLIENT_TO_PROVIDER','PROVIDER_TO_CLIENT') NOT NULL,
    rating              SMALLINT NOT NULL,
    comment             TEXT,
    is_published        BOOLEAN NOT NULL DEFAULT FALSE,
    moderation_status   ENUM('PENDING','APPROVED','REJECTED','HIDDEN') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_rating_order_direction UNIQUE (order_id, direction)
);
CREATE INDEX idx_rating_order ON trust_service.rating(order_id);
CREATE INDEX idx_rating_reviewee ON trust_service.rating(reviewee_id);

CREATE TABLE IF NOT EXISTS trust_service.report (
    id                  VARCHAR(26) PRIMARY KEY,
    reporter_id         VARCHAR(26) NOT NULL,
    target_type         ENUM('USER','POST','SERVICE','MESSAGE','REVIEW') NOT NULL,
    target_id           VARCHAR(26) NOT NULL,
    reason              VARCHAR(150) NOT NULL,
    description         TEXT,
    status              ENUM('PENDING','REVIEWING','RESOLVED','REJECTED') NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at         TIMESTAMP NULL
);
CREATE INDEX idx_report_target ON trust_service.report(target_type, target_id);

CREATE TABLE IF NOT EXISTS trust_service.dispute (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL,
    opened_by           VARCHAR(26) NOT NULL,
    reason              VARCHAR(150) NOT NULL,
    description         TEXT,
    status              ENUM('OPEN','UNDER_REVIEW','RESOLVED_CLIENT','RESOLVED_PROVIDER','CLOSED') NOT NULL,
    resolution          TEXT,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at         TIMESTAMP NULL
);
CREATE INDEX idx_dispute_order ON trust_service.dispute(order_id);

CREATE TABLE IF NOT EXISTS trust_service.provider_verification (
    id                  VARCHAR(26) PRIMARY KEY,
    provider_id         VARCHAR(26) NOT NULL,
    verification_type   ENUM('IDENTITY','BUSINESS','CERTIFICATION') NOT NULL,
    document_type       ENUM('ID_CARD','PASSPORT','BUSINESS_LICENSE','CERTIFICATE'),
    status              ENUM('PENDING','VERIFIED','REJECTED') NOT NULL,
    submitted_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    verified_at         TIMESTAMP NULL,
    rejected_reason     TEXT,
    verified_by         VARCHAR(26),
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_provider_verification_provider ON trust_service.provider_verification(provider_id);

-- EDA Tables for Trust
CREATE TABLE IF NOT EXISTS trust_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS trust_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);

-- ============================================================
-- 8. ORDER SERVICE
-- ============================================================
CREATE SCHEMA IF NOT EXISTS order_service;

-- SAGA PATTERN TABLE (Orchestrator Tracking)
CREATE TABLE IF NOT EXISTS order_service.saga_instances (
    id                  VARCHAR(26) PRIMARY KEY,
    saga_type           VARCHAR(100) NOT NULL, 
    order_id            VARCHAR(26) NOT NULL,  
    current_step        VARCHAR(100) NOT NULL, 
    status              ENUM('STARTED','COMPLETED','FAILED','COMPENSATING','COMPENSATED') NOT NULL,  
    state_data          JSON,                  
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_saga_order ON order_service.saga_instances(order_id);

CREATE TABLE IF NOT EXISTS order_service.orders (
    id                  VARCHAR(26) PRIMARY KEY,
    order_number        VARCHAR(50) NOT NULL UNIQUE,
    client_id           VARCHAR(26) NOT NULL,
    provider_id         VARCHAR(26) NOT NULL,
    service_id          VARCHAR(26),
    workflow_code       VARCHAR(50),
    subtotal            NUMERIC(19,4) NOT NULL,
    platform_fee        NUMERIC(19,4) NOT NULL DEFAULT 0,
    total_amount        NUMERIC(19,4) NOT NULL,
    provider_net_amount NUMERIC(19,4) NOT NULL DEFAULT 0,
    currency            ENUM('VND','USD','EUR') NOT NULL,
    status              ENUM('DRAFT','PENDING_PAYMENT','CONFIRMED','IN_PROGRESS','DELIVERED','COMPLETED','CANCELLED') NOT NULL,
    payment_status      ENUM('UNPAID','HELD_IN_ESCROW','PAID','REFUNDED'),
    placed_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    confirmed_at        TIMESTAMP NULL,
    cancelled_at        TIMESTAMP NULL,
    completed_at        TIMESTAMP NULL,
    auto_complete_at    TIMESTAMP NULL,
    version             BIGINT NOT NULL DEFAULT 0,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_orders_client ON order_service.orders(client_id);
CREATE INDEX idx_orders_provider ON order_service.orders(provider_id);
CREATE INDEX idx_orders_service ON order_service.orders(service_id);
CREATE INDEX idx_orders_status ON order_service.orders(status);

CREATE TABLE IF NOT EXISTS order_service.order_snapshot (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL UNIQUE,
    service_snapshot    JSON NOT NULL,
    provider_snapshot   JSON NOT NULL,
    requirement_values  JSON,
    price_breakdown     JSON,
    terms_snapshot      JSON,
    captured_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_snapshot_order FOREIGN KEY (order_id) REFERENCES order_service.orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_service.order_item (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL,
    item_type           ENUM('MAIN_SERVICE','ADDON','EXTRA_REVISION','CUSTOM_FEE') NOT NULL,
    reference_id        VARCHAR(26),
    name                VARCHAR(255) NOT NULL,
    quantity            INTEGER NOT NULL DEFAULT 1,
    unit_price          NUMERIC(19,4) NOT NULL,
    amount              NUMERIC(19,4) NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NULL,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id) REFERENCES order_service.orders(id) ON DELETE CASCADE
);
CREATE INDEX idx_order_item_order ON order_service.order_item(order_id);

CREATE TABLE IF NOT EXISTS order_service.cancellation_request (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL UNIQUE,
    requested_by        VARCHAR(26) NOT NULL,
    requested_by_role   ENUM('CLIENT','PROVIDER','ADMIN','SYSTEM') NOT NULL,
    reason_code         VARCHAR(100) NOT NULL,
    note                TEXT,
    refund_percent      NUMERIC(5,2),
    status              ENUM('PENDING','APPROVED','REJECTED') NOT NULL,
    responsed_at        TIMESTAMP NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP NULL,
    CONSTRAINT fk_cancellation_order FOREIGN KEY (order_id) REFERENCES order_service.orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_service.execution (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL UNIQUE,
    execution_type      ENUM('DIGITAL','ONSITE','APPOINTMENT','HOURLY','PROJECT','DELIVERY') NOT NULL,
    status              ENUM('PENDING_REQUIREMENTS','IN_PROGRESS','IN_REVISION','COMPLETED') NOT NULL,
    started_at          TIMESTAMP NULL,
    completed_at        TIMESTAMP NULL,
    metadata            JSON,
    CONSTRAINT fk_execution_order FOREIGN KEY (order_id) REFERENCES order_service.orders(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_service.digital_execution (
    id                  VARCHAR(26) PRIMARY KEY,
    requirement_submitted_at TIMESTAMP NULL,
    deadline_at         TIMESTAMP NULL,
    revision_at         TIMESTAMP NULL,
    revison_limit       INTEGER,
    revision_used       INTEGER NOT NULL DEFAULT 0,
    version             BIGINT NOT NULL DEFAULT 0,
    `updated-at`        TIMESTAMP NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_digital_execution_execution FOREIGN KEY (id) REFERENCES order_service.execution(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_service.onsite_execution (
    id                  VARCHAR(26) PRIMARY KEY,
    address_snapshot    JSON,
    travel_started_at   TIMESTAMP NULL,
    latitude            NUMERIC(10,7),
    longtitude          NUMERIC(10,7),
    checkin_code        TEXT,
    arrived_at          TIMESTAMP NULL,
    checkin_lat         NUMERIC(10,7),
    checkin_lng         NUMERIC(10,7),
    service_completed_at TIMESTAMP NULL,
    booking_slot_at     TIMESTAMP NULL,
    scheduled_at        TIMESTAMP NULL,
    scheduled_end       TIMESTAMP NULL,
    CONSTRAINT fk_onsite_execution_execution FOREIGN KEY (id) REFERENCES order_service.execution(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS order_service.delivery_file (
    id                  VARCHAR(26) PRIMARY KEY,
    file_url            TEXT NOT NULL,
    file_name           VARCHAR(255),
    mime_type           VARCHAR(150),
    size_bytes          BIGINT,
    execution_type      ENUM('DIGITAL','ONSITE','APPOINTMENT','HOURLY','PROJECT','DELIVERY'),
    is_preview          BOOLEAN,
    download_count      INTEGER NOT NULL DEFAULT 0,
    uploaded_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    checksum            VARCHAR(255),
    delivery_package_id VARCHAR(26)
);

CREATE TABLE IF NOT EXISTS order_service.work_evidence (
    id                  VARCHAR(26) PRIMARY KEY,
    execution_id        VARCHAR(26) NOT NULL,
    phase               ENUM('BEFORE_WORK','DURING_WORK','AFTER_WORK') NOT NULL,
    uploaded_by         VARCHAR(26) NOT NULL,
    file_url            TEXT NOT NULL,
    latitude            NUMERIC(10,7),
    longtitude          NUMERIC(10,7),
    captured_at         TIMESTAMP NULL,
    upload_at           TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_work_evidence_execution FOREIGN KEY (execution_id) REFERENCES order_service.execution(id) ON DELETE CASCADE
);
CREATE INDEX idx_work_evidence_execution ON order_service.work_evidence(execution_id);

CREATE TABLE IF NOT EXISTS order_service.delivery_package (
    id                  VARCHAR(26) PRIMARY KEY,
    execution_id        VARCHAR(26) NOT NULL,
    version_no          INTEGER NOT NULL,
    status              ENUM('SUBMITTED','ACCEPTED','REJECTED_FOR_REVISION') NOT NULL,
    deliverd_at         TIMESTAMP NULL,
    message             TEXT,
    is_final            BOOLEAN NOT NULL DEFAULT FALSE,
    responsed_at        TIMESTAMP NULL,
    CONSTRAINT fk_delivery_package_execution FOREIGN KEY (execution_id) REFERENCES order_service.execution(id) ON DELETE CASCADE,
    CONSTRAINT uq_delivery_package_version UNIQUE (execution_id, version_no)
);
CREATE INDEX idx_delivery_package_execution ON order_service.delivery_package(execution_id);

CREATE TABLE IF NOT EXISTS order_service.revision_request (
    id                  VARCHAR(26) PRIMARY KEY,
    delivery_package_id VARCHAR(26),
    requested_by        VARCHAR(26) NOT NULL,
    reason              TEXT,
    updated_at          TIMESTAMP NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_within_limit     BOOLEAN,
    attachments         JSON,
    CONSTRAINT fk_revision_request_delivery_package FOREIGN KEY (delivery_package_id) REFERENCES order_service.delivery_package(id) ON DELETE CASCADE
);

ALTER TABLE order_service.delivery_file
    ADD CONSTRAINT fk_delivery_file_delivery_package
    FOREIGN KEY (delivery_package_id) REFERENCES order_service.delivery_package(id)
    ON DELETE CASCADE;

CREATE TABLE IF NOT EXISTS order_service.order_status_history (
    id                  VARCHAR(26) PRIMARY KEY,
    order_id            VARCHAR(26) NOT NULL,
    from_status         VARCHAR(30),
    to_status           VARCHAR(30) NOT NULL,
    actor_id            VARCHAR(26),
    actor_role          VARCHAR(50),
    reason_code         VARCHAR(100),
    note                TEXT,
    metadata            JSON,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_status_history_order FOREIGN KEY (order_id) REFERENCES order_service.orders(id) ON DELETE CASCADE
);
CREATE INDEX idx_order_status_history_order ON order_service.order_status_history(order_id, created_at);

-- EDA Tables for Order
CREATE TABLE IF NOT EXISTS order_service.outbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    aggregate_type      VARCHAR(100) NOT NULL,
    aggregate_id        VARCHAR(26) NOT NULL,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    created_at          TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL,
    error_message       TEXT,
    INDEX idx_outbox_unprocessed (created_at)
);
CREATE TABLE IF NOT EXISTS order_service.inbox_events (
    id                  VARCHAR(26) PRIMARY KEY,
    event_id            VARCHAR(26) NOT NULL UNIQUE,
    event_type          VARCHAR(100) NOT NULL,
    payload             JSON NOT NULL,
    received_at         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at        TIMESTAMP NULL
);
