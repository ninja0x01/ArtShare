-- ArtShare Complete Database Schema
-- Comprehensive social media platform for artists database design
-- Combining best features from both schemas with enhancements

-- Create database
CREATE DATABASE IF NOT EXISTS artshare_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE artshare_db;

-- =============================================
-- CORE USER MANAGEMENT TABLES
-- =============================================

-- Users table - Enhanced with all necessary fields
CREATE TABLE `users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `uuid` VARCHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `first_name` VARCHAR(100) DEFAULT NULL,
  `last_name` VARCHAR(100) DEFAULT NULL,
  `full_name` VARCHAR(200) GENERATED ALWAYS AS (CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, ''))) STORED,
  `bio` TEXT DEFAULT NULL,
  `profile_image` VARCHAR(500) DEFAULT NULL,
  `cover_image` VARCHAR(500) DEFAULT NULL,
  `location` VARCHAR(255) DEFAULT NULL,
  `website` VARCHAR(500) DEFAULT NULL,
  `portfolio_url` VARCHAR(500) DEFAULT NULL,
  `social_links` JSON DEFAULT NULL,
  `date_of_birth` DATE DEFAULT NULL,
  `gender` ENUM('male','female','other','prefer_not_to_say') DEFAULT NULL,
  `art_styles` TEXT DEFAULT NULL,
  `is_verified` BOOLEAN DEFAULT FALSE,
  `is_active` BOOLEAN DEFAULT TRUE,
  `is_profile_private` BOOLEAN DEFAULT FALSE,
  `email_verified` BOOLEAN DEFAULT FALSE,
  `email_verification_token` VARCHAR(255) DEFAULT NULL,
  `password_reset_token` VARCHAR(255) DEFAULT NULL,
  `password_reset_expires` DATETIME DEFAULT NULL,
  `status` ENUM('active','inactive','banned','pending','suspended') DEFAULT 'active',
  `last_login` DATETIME DEFAULT NULL,
  `last_seen` DATETIME DEFAULT NULL,
  `followers_count` INT DEFAULT 0,
  `following_count` INT DEFAULT 0,
  `artworks_count` INT DEFAULT 0,
  `total_views` BIGINT DEFAULT 0,
  `total_likes` BIGINT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  UNIQUE KEY `uk_email` (`email`),
  UNIQUE KEY `uk_uuid` (`uuid`),
  KEY `idx_status` (`status`),
  KEY `idx_email_verified` (`email_verified`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_last_login` (`last_login`),
  KEY `idx_is_verified` (`is_verified`),
  KEY `idx_username_status` (`username`, `status`),
  KEY `idx_email_status` (`email`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User preferences table
CREATE TABLE `user_preferences` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `email_notifications` BOOLEAN DEFAULT TRUE,
  `push_notifications` BOOLEAN DEFAULT TRUE,
  `wants_notifications` BOOLEAN DEFAULT TRUE,
  `privacy_profile` ENUM('public', 'followers_only', 'private') DEFAULT 'public',
  `show_mature_content` BOOLEAN DEFAULT FALSE,
  `allow_downloads` BOOLEAN DEFAULT TRUE,
  `watermark_enabled` BOOLEAN DEFAULT FALSE,
  `theme` ENUM('light', 'dark', 'auto') DEFAULT 'auto',
  `language` VARCHAR(10) DEFAULT 'en',
  `timezone` VARCHAR(50) DEFAULT 'UTC',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_preferences` (`user_id`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User sessions table
CREATE TABLE `user_sessions` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `session_token` VARCHAR(255) NOT NULL UNIQUE,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT DEFAULT NULL,
  `device_info` JSON DEFAULT NULL,
  `expires_at` DATETIME NOT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `last_activity` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_session_token` (`session_token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `idx_is_active` (`is_active`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- ARTWORK CATEGORIZATION TABLES
-- =============================================

-- Art categories table
CREATE TABLE `art_categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT DEFAULT NULL,
  `icon_url` VARCHAR(500) DEFAULT NULL,
  `parent_id` INT DEFAULT NULL,
  `artworks_count` INT DEFAULT 0,
  `is_active` BOOLEAN DEFAULT TRUE,
  `sort_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_sort_order` (`sort_order`),
  FOREIGN KEY (`parent_id`) REFERENCES `art_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Art mediums table
CREATE TABLE `art_mediums` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT DEFAULT NULL,
  `category_id` INT DEFAULT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `usage_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_is_active` (`is_active`),
  FOREIGN KEY (`category_id`) REFERENCES `art_categories` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tags table
CREATE TABLE `tags` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT DEFAULT NULL,
  `usage_count` INT DEFAULT 0,
  `is_trending` BOOLEAN DEFAULT FALSE,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_name` (`name`),
  KEY `idx_usage_count` (`usage_count`),
  KEY `idx_is_trending` (`is_trending`),
  KEY `idx_is_featured` (`is_featured`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- ARTWORK TABLES
-- =============================================

-- Artworks table - Main artwork/images table
CREATE TABLE `artworks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `uuid` VARCHAR(36) UNIQUE NOT NULL DEFAULT (UUID()),
  `user_id` BIGINT NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `media_url` VARCHAR(500) NOT NULL,
  `media_type` ENUM('image', 'video', 'gif') NOT NULL DEFAULT 'image',
  `thumbnail_url` VARCHAR(500) DEFAULT NULL,
  `original_filename` VARCHAR(255) NOT NULL,
  `file_path` VARCHAR(500) NOT NULL,
  `file_size` BIGINT NOT NULL,
  `width` INT NOT NULL,
  `height` INT NOT NULL,
  `dimensions` VARCHAR(50) GENERATED ALWAYS AS (CONCAT(width, 'x', height)) STORED,
  `mime_type` VARCHAR(100) NOT NULL,
  `color_palette` JSON DEFAULT NULL,
  `category_id` INT DEFAULT NULL,
  `medium_id` INT DEFAULT NULL,
  `is_private` BOOLEAN DEFAULT FALSE,
  `is_mature_content` BOOLEAN DEFAULT FALSE,
  `is_process_reel` BOOLEAN DEFAULT FALSE,
  `allow_downloads` BOOLEAN DEFAULT TRUE,
  `allow_comments` BOOLEAN DEFAULT TRUE,
  `watermark_enabled` BOOLEAN DEFAULT FALSE,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `is_editor_choice` BOOLEAN DEFAULT FALSE,
  `view_count` BIGINT DEFAULT 0,
  `like_count` INT DEFAULT 0,
  `comment_count` INT DEFAULT 0,
  `share_count` INT DEFAULT 0,
  `download_count` INT DEFAULT 0,
  `popularity_score` DECIMAL(10,2) DEFAULT 0,
  `upload_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` ENUM('active','deleted','pending','reported','draft') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_uuid` (`uuid`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_category_id` (`category_id`),
  KEY `idx_medium_id` (`medium_id`),
  KEY `idx_upload_date` (`upload_date`),
  KEY `idx_status` (`status`),
  KEY `idx_title` (`title`),
  KEY `idx_is_featured` (`is_featured`),
  KEY `idx_is_private` (`is_private`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_like_count` (`like_count`),
  KEY `idx_popularity_score` (`popularity_score`),
  KEY `idx_user_status` (`user_id`, `status`),
  KEY `idx_category_status` (`category_id`, `status`),
  KEY `idx_upload_date_status` (`upload_date`, `status`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`category_id`) REFERENCES `art_categories` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`medium_id`) REFERENCES `art_mediums` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Artwork tags junction table
CREATE TABLE `artwork_tags` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `artwork_id` BIGINT NOT NULL,
  `tag_id` INT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_artwork_tag` (`artwork_id`, `tag_id`),
  KEY `idx_artwork_id` (`artwork_id`),
  KEY `idx_tag_id` (`tag_id`),
  FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Artwork views table
CREATE TABLE `artwork_views` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `artwork_id` BIGINT NOT NULL,
  `user_id` BIGINT DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT DEFAULT NULL,
  `referrer` VARCHAR(500) DEFAULT NULL,
  `session_id` VARCHAR(255) DEFAULT NULL,
  `viewed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_artwork_id` (`artwork_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_viewed_at` (`viewed_at`),
  KEY `idx_ip_address` (`ip_address`),
  KEY `idx_session_id` (`session_id`),
  FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- SOCIAL INTERACTION TABLES
-- =============================================

-- Likes table
CREATE TABLE `likes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `artwork_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_artwork_like` (`user_id`, `artwork_id`),
  KEY `idx_artwork_id` (`artwork_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comments table
CREATE TABLE `comments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `artwork_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `parent_id` BIGINT DEFAULT NULL,
  `comment` TEXT NOT NULL,
  `like_count` INT DEFAULT 0,
  `reply_count` INT DEFAULT 0,
  `is_edited` BOOLEAN DEFAULT FALSE,
  `is_pinned` BOOLEAN DEFAULT FALSE,
  `status` ENUM('active','deleted','reported','hidden') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_artwork_id` (`artwork_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_like_count` (`like_count`),
  FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`parent_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comment likes table
CREATE TABLE `comment_likes` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `comment_id` BIGINT NOT NULL,
  `user_id` BIGINT NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_comment_like` (`user_id`, `comment_id`),
  KEY `idx_comment_id` (`comment_id`),
  KEY `idx_user_id` (`user_id`),
  FOREIGN KEY (`comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Followers table
CREATE TABLE `followers` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `follower_id` BIGINT NOT NULL,
  `following_id` BIGINT NOT NULL,
  `is_mutual` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_follow_relationship` (`follower_id`, `following_id`),
  KEY `idx_follower_id` (`follower_id`),
  KEY `idx_following_id` (`following_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_mutual` (`is_mutual`),
  FOREIGN KEY (`follower_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`following_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_no_self_follow` CHECK (`follower_id` != `following_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- COLLECTIONS AND CURATION
-- =============================================

-- Collections table
CREATE TABLE `collections` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `slug` VARCHAR(255) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `cover_artwork_id` BIGINT DEFAULT NULL,
  `is_public` BOOLEAN DEFAULT TRUE,
  `is_featured` BOOLEAN DEFAULT FALSE,
  `artworks_count` INT DEFAULT 0,
  `view_count` INT DEFAULT 0,
  `like_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_slug` (`user_id`, `slug`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_public` (`is_public`),
  KEY `idx_is_featured` (`is_featured`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`cover_artwork_id`) REFERENCES `artworks` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Collection artworks junction table
CREATE TABLE `collection_artworks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `collection_id` BIGINT NOT NULL,
  `artwork_id` BIGINT NOT NULL,
  `sort_order` INT DEFAULT 0,
  `added_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_collection_artwork` (`collection_id`, `artwork_id`),
  KEY `idx_collection_id` (`collection_id`),
  KEY `idx_artwork_id` (`artwork_id`),
  KEY `idx_sort_order` (`sort_order`),
  FOREIGN KEY (`collection_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Featured artworks table
CREATE TABLE `featured_artworks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `artwork_id` BIGINT NOT NULL,
  `featured_by` BIGINT NOT NULL,
  `feature_type` ENUM('trending', 'editor_choice', 'artist_spotlight', 'daily_feature') NOT NULL,
  `title` VARCHAR(255) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `start_date` DATE NOT NULL,
  `end_date` DATE DEFAULT NULL,
  `position` INT DEFAULT 0,
  `is_active` BOOLEAN DEFAULT TRUE,
  `view_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_artwork_id` (`artwork_id`),
  KEY `idx_featured_by` (`featured_by`),
  KEY `idx_feature_type` (`feature_type`),
  KEY `idx_start_date` (`start_date`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_position` (`position`),
  FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`featured_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- MESSAGING AND COMMUNICATION
-- =============================================

-- Direct messages table
CREATE TABLE `direct_messages` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `sender_id` BIGINT NOT NULL,
  `recipient_id` BIGINT NOT NULL,
  `message` TEXT NOT NULL,
  `message_type` ENUM('text', 'image', 'artwork_share') DEFAULT 'text',
  `related_artwork_id` BIGINT DEFAULT NULL,
  `is_read` BOOLEAN DEFAULT FALSE,
  `is_deleted_by_sender` BOOLEAN DEFAULT FALSE,
  `is_deleted_by_recipient` BOOLEAN DEFAULT FALSE,
  `read_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sender_id` (`sender_id`),
  KEY `idx_recipient_id` (`recipient_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_conversation` (`sender_id`, `recipient_id`, `created_at`),
  FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`recipient_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`related_artwork_id`) REFERENCES `artworks` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Notifications table
CREATE TABLE `notifications` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `type` ENUM('like', 'comment', 'follow', 'mention', 'system', 'artwork_featured', 'collection_add') NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `related_user_id` BIGINT DEFAULT NULL,
  `related_artwork_id` BIGINT DEFAULT NULL,
  `related_comment_id` BIGINT DEFAULT NULL,
  `related_collection_id` BIGINT DEFAULT NULL,
  `action_url` VARCHAR(500) DEFAULT NULL,
  `is_read` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_user_unread` (`user_id`, `is_read`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`related_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`related_artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`related_comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`related_collection_id`) REFERENCES `collections` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- ADMINISTRATION AND MODERATION
-- =============================================

-- Admin users table
CREATE TABLE `admin_users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `role` ENUM('admin', 'moderator', 'super_admin') NOT NULL,
  `permissions` JSON DEFAULT NULL,
  `granted_by` BIGINT DEFAULT NULL,
  `granted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_active` BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_user` (`user_id`),
  KEY `idx_role` (`role`),
  KEY `idx_is_active` (`is_active`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`granted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reports table
CREATE TABLE `reports` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `reporter_id` BIGINT NOT NULL,
  `reported_user_id` BIGINT DEFAULT NULL,
  `reported_artwork_id` BIGINT DEFAULT NULL,
  `reported_comment_id` BIGINT DEFAULT NULL,
  `report_type` ENUM('spam', 'harassment', 'inappropriate_content', 'copyright_violation', 'fake_profile', 'hate_speech', 'other') NOT NULL,
  `reason` TEXT NOT NULL,
  `additional_info` TEXT DEFAULT NULL,
  `status` ENUM('pending', 'investigating', 'resolved', 'dismissed', 'escalated') DEFAULT 'pending',
  `admin_notes` TEXT DEFAULT NULL,
  `resolved_by` BIGINT DEFAULT NULL,
  `resolved_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reporter_id` (`reporter_id`),
  KEY `idx_reported_user_id` (`reported_user_id`),
  KEY `idx_reported_artwork_id` (`reported_artwork_id`),
  KEY `idx_reported_comment_id` (`reported_comment_id`),
  KEY `idx_status` (`status`),
  KEY `idx_report_type` (`report_type`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`reported_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`reported_artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`reported_comment_id`) REFERENCES `comments` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_report_has_target` CHECK (
    (`reported_user_id` IS NOT NULL) OR 
    (`reported_artwork_id` IS NOT NULL) OR 
    (`reported_comment_id` IS NOT NULL)
  )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- ANALYTICS AND TRACKING
-- =============================================

-- User activity log
CREATE TABLE `user_activity_log` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `activity_type` ENUM('login', 'logout', 'artwork_upload', 'artwork_view', 'profile_update', 'follow', 'unfollow') NOT NULL,
  `activity_data` JSON DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INITIAL DATA INSERTS
-- =============================================

-- Insert default categories
INSERT INTO `art_categories` (`name`, `slug`, `description`, `sort_order`) VALUES
('Digital Art', 'digital-art', 'Computer-generated artwork and digital illustrations', 1),
('Traditional Painting', 'traditional-painting', 'Oil, acrylic, watercolor, and other traditional painting mediums', 2),
('Drawing & Sketching', 'drawing-sketching', 'Pencil, charcoal, ink drawings and sketches', 3),
('Photography', 'photography', 'Digital and film photography', 4),
('Sculpture', 'sculpture', '3D artworks including clay, stone, metal sculptures', 5),
('Mixed Media', 'mixed-media', 'Artworks combining multiple mediums and techniques', 6),
('Street Art', 'street-art', 'Graffiti, murals, and urban art', 7),
('Illustration', 'illustration', 'Commercial and artistic illustrations', 8),
('Printmaking', 'printmaking', 'Screen printing, lithography, and other print techniques', 9),
('Fiber Arts', 'fiber-arts', 'Textiles, embroidery, and fabric-based art', 10),
('Concept Art', 'concept-art', 'Concept designs and artwork', 11),
('Abstract', 'abstract', 'Abstract and non-representational art', 12);

-- Continue from art mediums inserts
INSERT INTO `art_mediums` (`name`, `slug`, `description`, `category_id`) VALUES
('Digital Painting', 'digital-painting', 'Created using digital painting software', 1),
('3D Modeling', '3d-modeling', 'Three-dimensional computer graphics and modeling', 1),
('Vector Art', 'vector-art', 'Scalable vector graphics and illustrations', 1),
('Photo Manipulation', 'photo-manipulation', 'Digital photo editing and compositing', 1),
('Pixel Art', 'pixel-art', 'Low-resolution digital art with visible pixels', 1),
('Oil Painting', 'oil-painting', 'Traditional oil-based paint on canvas', 2),
('Acrylic Painting', 'acrylic-painting', 'Fast-drying acrylic paint medium', 2),
('Watercolor', 'watercolor', 'Water-based transparent paint', 2),
('Gouache', 'gouache', 'Opaque water-based paint', 2),
('Tempera', 'tempera', 'Egg-based traditional paint medium', 2),
('Pencil Drawing', 'pencil-drawing', 'Graphite pencil artwork', 3),
('Charcoal Drawing', 'charcoal-drawing', 'Charcoal-based drawings', 3),
('Ink Drawing', 'ink-drawing', 'Pen and ink illustrations', 3),
('Pastel Drawing', 'pastel-drawing', 'Soft or oil pastel artwork', 3),
('Colored Pencil', 'colored-pencil', 'Colored pencil illustrations', 3),
('Portrait Photography', 'portrait-photography', 'Human subject photography', 4),
('Landscape Photography', 'landscape-photography', 'Natural scenery photography', 4),
('Street Photography', 'street-photography', 'Urban and candid photography', 4),
('Wildlife Photography', 'wildlife-photography', 'Animal and nature photography', 4),
('Macro Photography', 'macro-photography', 'Close-up detail photography', 4),
('Clay Sculpture', 'clay-sculpture', 'Ceramic and clay-based sculptures', 5),
('Stone Sculpture', 'stone-sculpture', 'Carved stone artworks', 5),
('Metal Sculpture', 'metal-sculpture', 'Welded and forged metal art', 5),
('Wood Sculpture', 'wood-sculpture', 'Carved wooden sculptures', 5),
('Wire Sculpture', 'wire-sculpture', 'Wire-based three-dimensional art', 5),
('Collage', 'collage', 'Mixed paper and material compositions', 6),
('Assemblage', 'assemblage', 'Three-dimensional mixed media art', 6),
('Graffiti', 'graffiti', 'Urban spray paint art', 7),
('Mural', 'mural', 'Large-scale wall paintings', 7),
('Stencil Art', 'stencil-art', 'Template-based street art', 7),
('Book Illustration', 'book-illustration', 'Literary artwork and graphics', 8),
('Editorial Illustration', 'editorial-illustration', 'Magazine and news illustrations', 8),
('Character Design', 'character-design', 'Fictional character artwork', 8),
('Screen Print', 'screen-print', 'Silk screen printing technique', 9),
('Lithography', 'lithography', 'Stone or metal plate printing', 9),
('Etching', 'etching', 'Acid-etched metal printing', 9),
('Embroidery', 'embroidery', 'Decorative needlework', 10),
('Weaving', 'weaving', 'Textile and fiber weaving', 10),
('Quilting', 'quilting', 'Layered fabric artwork', 10),
('Game Concept Art', 'game-concept-art', 'Video game design artwork', 11),
('Film Concept Art', 'film-concept-art', 'Movie and animation concept designs', 11),
('Environment Design', 'environment-design', 'Background and setting artwork', 11),
('Geometric Abstract', 'geometric-abstract', 'Mathematical and geometric forms', 12),
('Expressionist Abstract', 'expressionist-abstract', 'Emotional abstract artwork', 12),
('Color Field', 'color-field', 'Large areas of solid color', 12);

-- Insert popular tags
INSERT INTO `tags` (`name`, `slug`, `description`, `is_trending`) VALUES
('portrait', 'portrait', 'Portrait artwork and photography', TRUE),
('landscape', 'landscape', 'Natural scenery and landscapes', TRUE),
('abstract', 'abstract', 'Abstract and non-representational art', FALSE),
('digital', 'digital', 'Digital artwork and creations', TRUE),
('traditional', 'traditional', 'Traditional art mediums', FALSE),
('fantasy', 'fantasy', 'Fantasy-themed artwork', TRUE),
('nature', 'nature', 'Nature and wildlife themed art', FALSE),
('urban', 'urban', 'City and urban-themed artwork', FALSE),
('minimalist', 'minimalist', 'Simple and clean artistic style', TRUE),
('surreal', 'surreal', 'Surrealistic and dreamlike art', FALSE),
('colorful', 'colorful', 'Vibrant and colorful artwork', TRUE),
('monochrome', 'monochrome', 'Black and white artwork', FALSE),
('realistic', 'realistic', 'Photorealistic artwork', TRUE),
('stylized', 'stylized', 'Artistic interpretation and style', FALSE),
('concept', 'concept', 'Concept art and design', TRUE),
('character', 'character', 'Character design and illustration', TRUE),
('environment', 'environment', 'Environmental and background art', FALSE),
('fan-art', 'fan-art', 'Fan artwork of existing properties', TRUE),
('original', 'original', 'Original artwork and concepts', FALSE),
('commission', 'commission', 'Commissioned artwork', FALSE),
('wip', 'wip', 'Work in progress artwork', TRUE),
('study', 'study', 'Art studies and practice work', FALSE),
('sketch', 'sketch', 'Preliminary sketches and drawings', TRUE),
('painting', 'painting', 'Painted artwork', FALSE),
('drawing', 'drawing', 'Hand-drawn artwork', FALSE);

-- =============================================
-- ADDITIONAL SYSTEM TABLES
-- =============================================

-- Site settings table
CREATE TABLE `site_settings` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `setting_key` VARCHAR(100) NOT NULL UNIQUE,
  `setting_value` TEXT DEFAULT NULL,
  `setting_type` ENUM('string', 'integer', 'boolean', 'json') DEFAULT 'string',
  `description` TEXT DEFAULT NULL,
  `is_public` BOOLEAN DEFAULT FALSE,
  `updated_by` BIGINT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_setting_key` (`setting_key`),
  KEY `idx_is_public` (`is_public`),
  FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Blocked users table
CREATE TABLE `blocked_users` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `blocker_id` BIGINT NOT NULL,
  `blocked_id` BIGINT NOT NULL,
  `reason` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_block_relationship` (`blocker_id`, `blocked_id`),
  KEY `idx_blocker_id` (`blocker_id`),
  KEY `idx_blocked_id` (`blocked_id`),
  FOREIGN KEY (`blocker_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`blocked_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_no_self_block` CHECK (`blocker_id` != `blocked_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Artwork shares table
CREATE TABLE `artwork_shares` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `artwork_id` BIGINT NOT NULL,
  `user_id` BIGINT DEFAULT NULL,
  `platform` ENUM('facebook', 'twitter', 'instagram', 'pinterest', 'email', 'copy_link', 'other') NOT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `user_agent` TEXT DEFAULT NULL,
  `shared_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_artwork_id` (`artwork_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_shared_at` (`shared_at`),
  FOREIGN KEY (`artwork_id`) REFERENCES `artworks` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User badges table
CREATE TABLE `user_badges` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(100) NOT NULL UNIQUE,
  `slug` VARCHAR(100) NOT NULL UNIQUE,
  `description` TEXT DEFAULT NULL,
  `icon_url` VARCHAR(500) DEFAULT NULL,
  `badge_color` VARCHAR(7) DEFAULT '#FF6B35',
  `criteria` JSON DEFAULT NULL,
  `is_active` BOOLEAN DEFAULT TRUE,
  `sort_order` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_slug` (`slug`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- User badge assignments table
CREATE TABLE `user_badge_assignments` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT NOT NULL,
  `badge_id` INT NOT NULL,
  `awarded_by` BIGINT DEFAULT NULL,
  `awarded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_displayed` BOOLEAN DEFAULT TRUE,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_badge` (`user_id`, `badge_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_badge_id` (`badge_id`),
  KEY `idx_awarded_at` (`awarded_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`badge_id`) REFERENCES `user_badges` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`awarded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Search history table
CREATE TABLE `search_history` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `user_id` BIGINT DEFAULT NULL,
  `search_query` VARCHAR(500) NOT NULL,
  `search_type` ENUM('artwork', 'user', 'tag', 'collection') DEFAULT 'artwork',
  `results_count` INT DEFAULT 0,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_search_query` (`search_query`),
  KEY `idx_search_type` (`search_type`),
  KEY `idx_created_at` (`created_at`),
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- INSERT DEFAULT SYSTEM DATA
-- =============================================

-- Insert default site settings
INSERT INTO `site_settings` (`setting_key`, `setting_value`, `setting_type`, `description`, `is_public`) VALUES
('site_name', 'ArtShare', 'string', 'Website name', TRUE),
('site_description', 'A social platform for artists to share and discover amazing artwork', 'string', 'Site description for SEO', TRUE),
('max_file_size', '10485760', 'integer', 'Maximum file upload size in bytes (10MB)', FALSE),
('allowed_file_types', '["jpg", "jpeg", "png", "gif", "webp"]', 'json', 'Allowed file extensions for uploads', FALSE),
('registration_enabled', 'true', 'boolean', 'Whether new user registration is enabled', TRUE),
('email_verification_required', 'true', 'boolean', 'Whether email verification is required for new accounts', FALSE),
('mature_content_enabled', 'true', 'boolean', 'Whether mature content is allowed on the platform', TRUE),
('max_tags_per_artwork', '20', 'integer', 'Maximum number of tags allowed per artwork', FALSE),
('featured_artworks_count', '12', 'integer', 'Number of artworks to display in featured section', TRUE),
('trending_tags_count', '10', 'integer', 'Number of trending tags to display', TRUE),
('watermark_default_enabled', 'false', 'boolean', 'Default watermark setting for new users', FALSE),
('comments_enabled', 'true', 'boolean', 'Whether comments are enabled globally', TRUE),
('downloads_enabled', 'true', 'boolean', 'Whether artwork downloads are enabled globally', TRUE),
('social_sharing_enabled', 'true', 'boolean', 'Whether social media sharing is enabled', TRUE),
('min_password_length', '8', 'integer', 'Minimum password length requirement', FALSE),
('session_timeout', '7200', 'integer', 'Session timeout in seconds (2 hours)', FALSE),
('rate_limit_api', '1000', 'integer', 'API rate limit per hour per user', FALSE),
('maintenance_mode', 'false', 'boolean', 'Whether the site is in maintenance mode', FALSE),
('backup_retention_days', '30', 'integer', 'Number of days to retain database backups', FALSE),
('analytics_enabled', 'true', 'boolean', 'Whether analytics tracking is enabled', TRUE);

-- Insert default user badges
INSERT INTO `user_badges` (`name`, `slug`, `description`, `icon_url`, `badge_color`, `sort_order`) VALUES
('Verified Artist', 'verified-artist', 'Verified professional artist account', '/badges/verified.svg', '#1DA1F2', 1),
('Pioneer', 'pioneer', 'Early adopter of the platform', '/badges/pioneer.svg', '#FFD700', 2),
('Trendsetter', 'trendsetter', 'Creates trending artwork regularly', '/badges/trendsetter.svg', '#FF6B35', 3),
('Community Leader', 'community-leader', 'Active community member and mentor', '/badges/community.svg', '#9B59B6', 4),
('Art Critic', 'art-critic', 'Provides thoughtful artwork reviews', '/badges/critic.svg', '#E74C3C', 5),
('Featured Artist', 'featured-artist', 'Has been featured on the homepage', '/badges/featured.svg', '#F39C12', 6),
('Popular Creator', 'popular-creator', 'Has over 10,000 followers', '/badges/popular.svg', '#E67E22', 7),
('Consistent Creator', 'consistent-creator', 'Uploads artwork regularly', '/badges/consistent.svg', '#27AE60', 8),
('Milestone Master', 'milestone-master', 'Reached major platform milestones', '/badges/milestone.svg', '#8E44AD', 9),
('Collaboration King', 'collaboration-king', 'Frequently collaborates with other artists', '/badges/collaboration.svg', '#3498DB', 10);

-- =============================================
-- CREATE VIEWS FOR COMMON QUERIES
-- =============================================

-- Popular artworks view (last 30 days)
CREATE VIEW `popular_artworks_30d` AS
SELECT 
    a.*,
    u.username,
    u.profile_image as user_profile_image,
    u.is_verified as user_verified,
    c.name as category_name,
    m.name as medium_name,
    (a.view_count * 0.1 + a.like_count * 2 + a.comment_count * 3 + a.share_count * 1.5) as popularity_score_calculated
FROM `artworks` a
JOIN `users` u ON a.user_id = u.id
LEFT JOIN `art_categories` c ON a.category_id = c.id
LEFT JOIN `art_mediums` m ON a.medium_id = m.id
WHERE 
    a.status = 'active' 
    AND a.is_private = FALSE 
    AND u.status = 'active'
    AND a.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
ORDER BY popularity_score_calculated DESC;

-- User profile summary view
CREATE VIEW `user_profiles` AS
SELECT 
    u.id,
    u.uuid,
    u.username,
    u.email,
    u.full_name,
    u.bio,
    u.profile_image,
    u.cover_image,
    u.location,
    u.website,
    u.is_verified,
    u.is_active,
    u.followers_count,
    u.following_count,
    u.artworks_count,
    u.total_views,
    u.total_likes,
    u.created_at,
    u.last_seen,
    COUNT(DISTINCT uba.badge_id) as badges_count,
    GROUP_CONCAT(DISTINCT ub.name SEPARATOR ', ') as badge_names
FROM `users` u
LEFT JOIN `user_badge_assignments` uba ON u.id = uba.user_id AND uba.is_displayed = TRUE
LEFT JOIN `user_badges` ub ON uba.badge_id = ub.id
WHERE u.is_active = TRUE
GROUP BY u.id;

-- Trending tags view (based on recent usage)
CREATE VIEW `trending_tags` AS
SELECT 
    t.*,
    COUNT(at.id) as recent_usage_count
FROM `tags` t
LEFT JOIN `artwork_tags` at ON t.id = at.tag_id
LEFT JOIN `artworks` a ON at.artwork_id = a.id
WHERE 
    a.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
    AND a.status = 'active'
    AND a.is_private = FALSE
GROUP BY t.id
HAVING recent_usage_count > 0
ORDER BY recent_usage_count DESC, t.usage_count DESC
LIMIT 20;

-- =============================================
-- CREATE TRIGGERS FOR MAINTAINING COUNTS
-- =============================================

-- Trigger to update artwork count when artwork is inserted
DELIMITER $$
CREATE TRIGGER `trg_artwork_insert_update_counts` 
AFTER INSERT ON `artworks`
FOR EACH ROW
BEGIN
    UPDATE `users` SET `artworks_count` = `artworks_count` + 1 WHERE `id` = NEW.user_id;
    
    IF NEW.category_id IS NOT NULL THEN
        UPDATE `art_categories` SET `artworks_count` = `artworks_count` + 1 WHERE `id` = NEW.category_id;
    END IF;
END$$
DELIMITER ;

-- Trigger to update artwork count when artwork is deleted
DELIMITER $$
CREATE TRIGGER `trg_artwork_delete_update_counts` 
AFTER DELETE ON `artworks`
FOR EACH ROW
BEGIN
    UPDATE `users` SET `artworks_count` = `artworks_count` - 1 WHERE `id` = OLD.user_id;
    
    IF OLD.category_id IS NOT NULL THEN
        UPDATE `art_categories` SET `artworks_count` = `artworks_count` - 1 WHERE `id` = OLD.category_id;
    END IF;
END$$
DELIMITER ;

-- Trigger to update follower counts
DELIMITER $$
CREATE TRIGGER `trg_follow_insert_update_counts` 
AFTER INSERT ON `followers`
FOR EACH ROW
BEGIN
    UPDATE `users` SET `followers_count` = `followers_count` + 1 WHERE `id` = NEW.following_id;
    UPDATE `users` SET `following_count` = `following_count` + 1 WHERE `id` = NEW.follower_id;
END$$
DELIMITER ;

-- Trigger to update follower counts on unfollow
DELIMITER $$
CREATE TRIGGER `trg_follow_delete_update_counts` 
AFTER DELETE ON `followers`
FOR EACH ROW
BEGIN
    UPDATE `users` SET `followers_count` = `followers_count` - 1 WHERE `id` = OLD.following_id;
    UPDATE `users` SET `following_count` = `following_count` - 1 WHERE `id` = OLD.follower_id;
END$$
DELIMITER ;

-- Trigger to update like counts
DELIMITER $$
CREATE TRIGGER `trg_like_insert_update_counts` 
AFTER INSERT ON `likes`
FOR EACH ROW
BEGIN
    UPDATE `artworks` SET `like_count` = `like_count` + 1 WHERE `id` = NEW.artwork_id;
    UPDATE `users` SET `total_likes` = `total_likes` + 1 WHERE `id` = (SELECT user_id FROM `artworks` WHERE id = NEW.artwork_id);
END$$
DELIMITER ;

-- Trigger to update like counts on unlike
DELIMITER $$
CREATE TRIGGER `trg_like_delete_update_counts` 
AFTER DELETE ON `likes`
FOR EACH ROW
BEGIN
    UPDATE `artworks` SET `like_count` = `like_count` - 1 WHERE `id` = OLD.artwork_id;
    UPDATE `users` SET `total_likes` = `total_likes` - 1 WHERE `id` = (SELECT user_id FROM `artworks` WHERE id = OLD.artwork_id);
END$$
DELIMITER ;

-- Trigger to update comment counts
DELIMITER $$
CREATE TRIGGER `trg_comment_insert_update_counts` 
AFTER INSERT ON `comments`
FOR EACH ROW
BEGIN
    UPDATE `artworks` SET `comment_count` = `comment_count` + 1 WHERE `id` = NEW.artwork_id;
    
    IF NEW.parent_id IS NOT NULL THEN
        UPDATE `comments` SET `reply_count` = `reply_count` + 1 WHERE `id` = NEW.parent_id;
    END IF;
END$$
DELIMITER ;

-- Trigger to update tag usage counts
DELIMITER $$
CREATE TRIGGER `trg_artwork_tag_insert_update_count` 
AFTER INSERT ON `artwork_tags`
FOR EACH ROW
BEGIN
    UPDATE `tags` SET `usage_count` = `usage_count` + 1 WHERE `id` = NEW.tag_id;
END$$
DELIMITER ;

-- =============================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================

-- Additional performance indexes
CREATE INDEX `idx_artworks_featured_active` ON `artworks` (`is_featured`, `status`, `created_at`);
CREATE INDEX `idx_artworks_category_active` ON `artworks` (`category_id`, `status`, `popularity_score`);
CREATE INDEX `idx_artworks_user_active` ON `artworks` (`user_id`, `status`, `created_at`);
CREATE INDEX `idx_users_verification_status` ON `users` (`is_verified`, `status`, `created_at`);
CREATE INDEX `idx_notifications_user_unread_type` ON `notifications` (`user_id`, `is_read`, `type`, `created_at`);
CREATE INDEX `idx_comments_artwork_status_created` ON `comments` (`artwork_id`, `status`, `created_at`);
CREATE INDEX `idx_collections_user_public` ON `collections` (`user_id`, `is_public`, `updated_at`);

-- Full-text search indexes
ALTER TABLE `artworks` ADD FULLTEXT `ft_title_description` (`title`, `description`);
ALTER TABLE `users` ADD FULLTEXT `ft_username_bio` (`username`, `bio`);
ALTER TABLE `tags` ADD FULLTEXT `ft_name_description` (`name`, `description`);

-- =============================================
-- END OF SCHEMA
-- =============================================

-- Schema creation completed successfully
SELECT 'ArtShare database schema created successfully!' as status;