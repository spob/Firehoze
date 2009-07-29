LANGUAGES = [['English', 'en'],['Wookie', 'wk']]

ROWS_PER_PAGE = 10
LESSONS_PER_PAGE = 10

# Roles
ROLE_ADMIN = 'admin'
ROLE_MODERATOR = 'moderator'

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

# Configuration properties in the s3.yml file
CONFIG_AWS_ACCESS_KEY_ID = 'access_key_id'
CONFIG_AWS_SECRET_ACCESS_KEY = 'secret_access_key'

FLIX_CLOUD_AWS_ID = '99293b905e1e3610f938fccb8405c4d56e913c2f0acf7bf1b74af1fdc107294c'
FLIX_API_KEY = 'b997:klpibn:0:8x72:gsvz'
FLIX_RECIPE_ID = 438
WATERMARK_URL = 's3://assets.firehoze.com/watermark.png'

# Video statuses
VIDEO_STATUS_PENDING = "Pending"
VIDEO_STATUS_CONVERTING = "Converting"
VIDEO_STATUS_FAILED = "Failed"
VIDEO_STATUS_READY = "Ready"

# Video format
VIDEO_FORMAT_ORIGINAL = "Original"
VIDEO_FORMAT_FLASH = "Flash"