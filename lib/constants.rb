module Constants
  ROWS_PER_PAGE = 10

  # Roles
  ROLE_SYSADMIN = 'sysadmin'
  ROLE_MODERATOR = 'moderator'

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
end