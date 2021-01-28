# frozen_string_literal: true

require_relative "active_image_persist/version"

module ActiveImagePersist
  class Error < StandardError; end
  # Your code goes here...

  # def new
  #   delete_cache
  # end

  # def edit
  #   delete_cache
  # end

  # def create
  #   if save
  #     attach_images_to @obj, params
  #   else
  #     persist_img
  #   end
  # end

  # def update
  #   if update
  #     attach_images_to @obj, params
  #   else
  #     persist_img
  #   end
  # end

  def attach_img_to(obj, params)
    return if @keys.blank? || params != Hash || obj.blank?
    @keys.each do |k|
      if params[k].present?
        obj.call(k.to_s).purge if obj.call(k).attached?
        obj.call(k.to_s).attach(params[k])
      elsif cookies[:active_image_persist][k].present?
        obj.call(k.to_s).purge if obj.call(k.to_s).attached?
        obj.call(k.to_s).attach(ActiveStorage::Blob.find_by(key: cookies[:active_image_persist][k]))
      end
    end
    delete_cache
  end

  def persist_img params
    return if @keys.blank? || params != Hash
    @keys.each do |k|
      if params[k].present?
        file = params[k]
        img = ActiveStorage::Blob.create_and_upload!(io: file, filename: file.original_filename)
        cookies['active_image_persist'][k] = img
      end
    end
  end

  def delete_cache
    return if @keys.blank?
    @keys.each do |k|
      cookies.delete ['active_image_persist'][k]
    end
  end

  def persisted_img(k=nil, klass='', style='')
    blob = ActiveStorage::Blob.find_by(key: cookies['active_image_persist'][k])
    unless blob.blank?
      image_tag(blob, style: style, class: klass)
    else
      nil
    end
  end

  def clean_unassociated_blobs
    ids = ActiveStorage::Blob.all.select{|e| e.attachments.blank? }.pluck(:id)
    ActiveStorage::Blob.where(id: unassociated_blob_ids).each {|e| e.purge }
  end

  def setup_persist_img arr
    return if arr.blank? || arr != Array
    @keys = arr
  end
end
