module ActiveImagePersist
  extend ActiveSupport::Concern
  included do
    helper_method :persisted_img

    def attach_img_to(_obj, params)
      return if @keys.blank? || !params.is_a?(ActionController::Parameters) || _obj.blank?
      begin
        @keys.each do |k|
          s = k.to_s.gsub('{:', '').gsub('_attributes=>:', '.').gsub('}', '')
          obj = _obj
          file = k.is_a?(Hash) ? params[k.first[0].to_s][k.first[1].to_s] : params[k]
          cache = k.is_a?(Hash) ? cookies["#{k.first[0].to_s}_#{k.first[1].to_s}".to_sym] : cookies[k]
          if k.is_a?(Hash)
            s_ar = s.split('.')
            obj = _obj.send(s_ar[0])
            s = s_ar[1]
          end

          obj.send(s).purge if obj.send(s).attached?

          if file.present?
            obj.send(s).attach(file)
          elsif cache.present?
            obj.send(s).attach(ActiveStorage::Blob.find_by(key: cache))
          end
        end
      rescue; end
      delete_cache
    end

    def persist_img params
      return if @keys.blank? || !params.is_a?(ActionController::Parameters)
      begin
        @keys.each do |k|
          file = k.is_a?(Hash) ? params[k.first[0]][k.first[1]] : params[k]
          cache_sym = k.is_a?(Hash) ? "#{k.first[0].to_s}_#{k.first[1].to_s}".to_sym : k
          if file.present?
            img = ActiveStorage::Blob.create_and_upload!(io: file, filename: file.original_filename)
            cookies[cache_sym] = img.key
          end
        end
      rescue; end
    end

    def delete_cache
      return if @keys.blank?
      begin
        @keys.each do |k|
          cache_sym = k.is_a?(Hash) ? "#{k.first[0].to_s}_#{k.first[1].to_s}".to_sym : k
          cookies.delete cache_sym
        end
      rescue; end
    end

    def persisted_img(k=nil, klass='', style='')
      begin
        cache_sym = k.is_a?(Hash) ? "#{k.first[0].to_s}_#{k.first[1].to_s}".to_sym : k
        blob = ActiveStorage::Blob.find_by(key: cookies[cache_sym])
        unless blob.blank?
          ("<img src='#{url_for(blob)}' style='#{style}' class='#{klass}'>").html_safe
        else
          nil
        end
      rescue; end
    end

    def setup_persist_img arr
      return if arr.blank? || !arr.is_a?(Array)
      @keys = arr
    end
  end
end
