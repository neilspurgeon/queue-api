require "shrine"
require "shrine/storage/file_system"
require "shrine/storage/s3"

s3_options = {
  access_key_id: Rails.application.secrets.aws_id,
  secret_access_key: Rails.application.secrets.aws_key,
  bucket: Rails.application.secrets.aws_bucket,
  region: 'us-west-2'
}

Shrine.storages = {
  cache: Shrine::Storage::S3.new(prefix: "uploads/cache", public: true, **s3_options),
  store: Shrine::Storage::S3.new(prefix: "uploads", public: true, **s3_options),
}

Shrine.plugin :activerecord # or :sequel
Shrine.plugin :cached_attachment_data # for retaining the cached file across form redisplays
Shrine.plugin :restore_cached_data # re-extract metadata when attaching a cached file
Shrine.plugin :rack_file # for non-Rails apps