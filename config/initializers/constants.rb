SECURE_PROTOCOL = (ENV["RAILS_ENV"] =~ /production/ ? "https" : "http")

LANGUAGES = [['English', 'en']]

ROWS_PER_PAGE = 10
LESSONS_PER_PAGE = 10
REVIEWS_ON_LESSON_SHOW_PER_PAGE = 5
COMMENTS_ON_LESSON_SHOW_PER_PAGE = 5

# Roles
ROLE_ADMIN = 'admin'
ROLE_MODERATOR = 'moderator'
ROLE_PAYMENT_MGR = 'paymentmgr'

# Skus
CREDIT_SKU = 'CREDIT'
FREE_CREDIT_SKU = 'FREE_CREDIT'
GIFT_CERTIFICATE_SKU = 'GIFT_CERTIFICATE_SKU'

# Configuration properties in the environment.yml file
CONFIG_PROTOCOL = 'protocol'
CONFIG_HOST = 'host'
CONFIG_PORT = 'port'
CONFIG_ADMIN_EMAIL = 'admin_email'
CONFIG_DEFAULT_USER_TIMEZONE = 'default_user_timezone'
CONFIG_PERIODIC_JOB_TIMEOUT = 'periodic_job_timeout'
CONFIG_MAX_VIDEO_SIZE = 'max_video_size'
CONFIG_S3_DIRECTORY = 's3_directory'
CONFIG_MIN_CREDIT_PURCHASE = 'min_credit_purchase'
CONFIG_KEEP_PERIODIC_JOB_DAYS = 'keep_periodic_job_days'
CONFIG_EXPIRE_CREDITS_AFTER_DAYS = 'expire_credits_after_days'
CONFIG_WARN_BEFORE_CREDIT_EXPIRATION_DAYS = 'warn_before_credit_expiration_days'
CONFIG_GIFT_CERTIFICATE_EXPIRES_DAYS = 'gift_certificate_expires_days'
CONFIG_AWS_S3_INPUT_VIDEO_BUCKET = 'aws_s3_input_video_bucket'
CONFIG_AWS_S3_OUTPUT_VIDEO_BUCKET = 'aws_s3_output_video_bucket'
CONFIG_AWS_S3_THUMBS_BUCKET = 'aws_s3_thumbs_bucket'
CONFIG_AWS_S3_IMAGES_BUCKET = 'aws_s3_images_bucket'
CONFIG_ZOMBIE_VIDEO_PROCESS_MINUTES = 'zombie_video_process_minutes'
CONFIG_NUMBER_OF_BUY_PATTERNS_TO_SHOW = 'number_of_buy_patterns_to_show'
CONFIG_CDN_OUTPUT_SERVER = 'cdn_output_server'
CONFIG_CDN_THUMBS_SERVER = 'cdn_thumbs_server'
CONFIG_FTP_CDN_PATH = 'ftp_cdn_path'
CONFIG_FTP_CDN_USER = 'ftp_cdn_user'
CONFIG_FTP_CDN_PASSWORD = 'ftp_cdn_password'
CONFIG_CDN_VIDEO_BUCKET = 'cdn_video_bucket'
CONFIG_RESTRICT_REGISTRATION = 'restrict_registration'

# Configuration properties in the s3.yml file
CONFIG_AWS_ACCESS_KEY_ID = 'access_key_id'
CONFIG_AWS_SECRET_ACCESS_KEY = 'secret_access_key'

FLIX_CLOUD_AWS_ID = '99293b905e1e3610f938fccb8405c4d56e913c2f0acf7bf1b74af1fdc107294c'
FLIX_API_KEY = 'b997:klpibn:0:8x72:gsvz'
FLIX_FULL_RECIPE_ID = 582
FLIX_PREVIEW_RECIPE_ID = 581
WATERMARK_URL = 's3://assets.firehoze.com/watermark.png'

# Video statuses
VIDEO_STATUS_PENDING = "Pending"
VIDEO_STATUS_CONVERTING = "Converting"
VIDEO_STATUS_FAILED = "Failed"
VIDEO_STATUS_READY = "Ready"

# Lesson statuses
LESSON_STATUS_PENDING = VIDEO_STATUS_PENDING
LESSON_STATUS_CONVERTING = VIDEO_STATUS_CONVERTING
LESSON_STATUS_FAILED = VIDEO_STATUS_FAILED
LESSON_STATUS_READY = VIDEO_STATUS_READY
LESSON_STATUS_REJECTED = 'Rejected'

# Hash codes
HASH_PREFIX = "asdfas"
HASH_SUFFIX = "fdasae"

# flag reason codes
FLAG_LEWD = 'lewd'
FLAG_SPAM = 'spam'
FLAG_OFFENSIVE = 'offensive'
FLAG_DANGEROUS = 'dangerous'
FLAG_IP = 'ip'

# flag status
FLAG_STATUS_PENDING = 'pending'
FLAG_STATUS_REJECTED = 'rejected'
FLAG_STATUS_RESOLVED = 'resolved'
FLAG_STATUS_RESOLVED_MANUALLY = 'resolved_manually'

# comment status
COMMENT_STATUS_ACTIVE = 'active'
COMMENT_STATUS_REJECTED = 'rejected'

# review status
REVIEW_STATUS_ACTIVE = 'active'
REVIEW_STATUS_REJECTED = 'rejected'

# Who can contact users directly
USER_ALLOW_CONTACT_NONE = 'NONE'
USER_ALLOW_CONTACT_ANYONE = 'ANYONE'
USER_ALLOW_CONTACT_STUDENTS_ONLY = 'STUDENTS_ONLY'

# Status of users who wish to become authors
AUTHOR_STATUS_NO = "NO"
AUTHOR_STATUS_INPROGRESS = "INPROGRESS"
AUTHOR_STATUS_OK = "OK"