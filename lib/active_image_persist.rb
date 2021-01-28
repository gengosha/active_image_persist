# frozen_string_literal: true

require_relative "active_image_persist/version"

module ActiveImagePersist
  class Error < StandardError; end
  # Your code goes here...

    def attach_images_to_meta_tag
    if meta_tag_params[:og_image].present?
      @meta_tag.og_image.purge if @meta_tag.og_image.attached?
      @meta_tag.og_image.attach(meta_tag_params[:og_image])
    elsif cookies[:meta_tag_og_image].present?
      @meta_tag.og_image.purge if @meta_tag.og_image.attached?
      @meta_tag.og_image.attach(ActiveStorage::Blob.find_by(key: cookies[:meta_tag_og_image]))
    end

    delete_image_cookies
  end

  def save_attachment_keys_as_cookies
    if meta_tag_params[:og_image].present?
      og_image = ActiveStorage::Blob.create_and_upload!(io: meta_tag_params[:og_image], filename: meta_tag_params[:og_image].original_filename)
      cookies[:meta_tag_og_image] = og_image.key
    end
  end

  def delete_image_cookies
    cookies.delete :meta_tag_og_image
  end
end
