#SECURE_PROTOCOL = (ENV["RAILS_ENV"] =~ /production/ ? "https" : "http")
SECURE_PROTOCOL = "http"

LANGUAGES = [['English', 'en']]

ROWS_PER_PAGE = 10
LESSONS_PER_PAGE = 15
SEARCH_RESULTS_PER_PAGE = 20
ADVANCED_SEARCH_RESULTS_TO_DISPLAY = 25
REVIEWS_ON_LESSON_SHOW_PER_PAGE = 5
COMMENTS_ON_LESSON_SHOW_PER_PAGE = 10
ACTIVITES_PER_PAGE = 5

# Roles
ROLE_ADMIN = 'admin'
ROLE_MODERATOR = 'moderator'
ROLE_COMMUNITY_MGR = 'communitymgr'
ROLE_PAYMENT_MGR = 'paymentmgr'

# Skus
CREDIT_SKU = 'CREDIT'
FREE_CREDIT_SKU = 'FREE_CREDIT'
PROMO_CREDIT_SKU = 'PROMO_CREDIT'
GIFT_CERTIFICATE_SKU = 'GIFT_CERTIFICATE_SKU'

# Configuration properties in the environment.yml file
CONFIG_PROTOCOL = 'protocol'
CONFIG_HOST = 'host'
CONFIG_PORT = 'port'
CONFIG_ADMIN_EMAIL = 'admin_email'
CONFIG_DEFAULT_USER_TIMEZONE = 'default_user_timezone'
CONFIG_PERIODIC_JOB_TIMEOUT = 'periodic_job_timeout'
CONFIG_MAX_VIDEO_SIZE = 'max_video_size'
CONFIG_MAX_ATTACHMENT_SIZE = 'max_attachment_size'
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
CONFIG_ALLOW_UNRECOGNIZED_ACCESS  = 'allow_unrecognized_access'
CONFIG_CRAWLER_ACCESS  = 'crawler_access'
CONFIG_FIREHOZE_INSTRUCTOR_GROUP_ID = 'firehoze_instructors_group_id'
CONFIG_RESTRICT_INSTRUCTOR_SIGNUP = 'restrict_instructor_signup'
CONFIG_FB_CANVAS = 'fb_canvas'
CONFIG_FB_AUTH_TOKEN = 'fb_auth_token'

# Configuration properties in the s3.yml file
CONFIG_AWS_ACCESS_KEY_ID = 'access_key_id'
CONFIG_AWS_SECRET_ACCESS_KEY = 'secret_access_key'

ALL_USERS_AWS_ID = 'http://acs.amazonaws.com/groups/global/AllUsers'
# this value is the canonical id of the zencoder user id that zencoder will use to download the source video to encode from the S3 input bucket.
# you can get it from the zencoder docs that talk about the permissions to set on the S3 input bucket.
FLIX_CLOUD_AWS_ID = '6c8583d84664a381db0c6af0e79b285ede571885fbe768e7ea50e5d3760597dd'
# get this value by logging into zencoder then selecting API in the menu option at the top.  This is the value for the full access key.
FLIX_API_KEY = 'e7a347f1b99adcd268aecd30d3e998a9'
FLIX_FULL_RECIPE_ID = 582
FLIX_PREVIEW_RECIPE_ID = 581
WATERMARK_URL = 'http://ableroad.firehoze.com/images/videos/watermark-video-embed-24.png'

OUTPUT_FTP_USERNAME = 'output'
OUTPUT_FTP_PASSWORD = 'gxdk4v27zmc2th6amguw58'

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

# Lesson levels

LESSON_LEVELS = %w{ disabled family member caregiver provider employer hospital other }

# Lesson video player
# Actual video size should be 4:3 480 X 360 (standard definition)
PLAYER_MENU_BAR = 36
PLAYER_WIDTH = 458
PLAYER_HEIGHT = 305 + PLAYER_MENU_BAR # Play size is taller due to player controls 480 X 396  ==> 480 X 360 + 36px

# Hash codes
HASH_PREFIX = "asdfas"
HASH_SUFFIX = "fdasae"

# flag reason codes
FLAG_LEWD = 'lewd'
FLAG_SPAM = 'spam'
FLAG_OFFENSIVE = 'offensive'
FLAG_DANGEROUS = 'dangerous'
FLAG_OTHER = 'other'
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

# Firehoze Policies
POLICIES = %w(membership_agreement instructor_agreement content_license_agreement terms_of_use privacy copyright)

# Group member types
OWNER = 'OWNER'
MODERATOR = 'MODERATOR'
MEMBER = 'MEMBER'
PENDING = 'PENDING'

# Twitter search types
FIREHOZE_TWEETS = 'FIREHOZE'

# Legal entity types
# see http://en.wikipedia.org/wiki/Types_of_business_entity#Federally_incorporated
#
INCORPORATED = 'INC'
DOING_BUSINESS_AS = 'DBA'
GENERAL_PARTNERSHIP = 'GP'
LIMITED_LIABILITY_CORPORATION = 'LLC'
LIMITED_LIABLITY_LIMITED_PARTNERSHIP = 'LLLP'
LIMITED_LIABILITY_PARTNERSHIP = 'LLP'
LIMITED_PARTNERSHIP = 'LP'
PROFESSIONAL_LIMITED_LIABILITY_COMPANY = 'PLLC'
PROFESSIONAL_CORPORATION = 'PC'
SOLE_PROPRIETORSHIP = 'SP'

# Corporation types.
# see http://en.wikipedia.org/wiki/501(c)#Types
# TODO we need to expand the list to include all the different subtypes
CORP_TYPE_501C = '501C'

# company finance stage
SEED = 'Seed'
ROUND_A = 'Round A'
ROUND_B = 'Round B'
ROUND_C = 'Round C'
ROUND_D = 'Round D'
ROUND_D_PLUS = 'Round D+'

# company development stage
IDEA = 'Idea'
PROTOTYPE = 'Prototype'
ALPHA = 'Alpha'
BETA = 'Beta'
PRODUCTION = 'Production'

PRIZE_MERCHANDISE = 'MERCHANDISE'
PRIZE_CURRENCY = 'CURRENCY'
