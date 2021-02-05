# ActiveImagePersist

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_image_persist'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_image_persist

## Usage

This gem is intended to help with image files lost or corruption in the view from validation error with active storage.
ActiveStorage's installation is required.
https://edgeguides.rubyonrails.org/active_storage_overview.html

There are 5 methods provided by this gem, 4 for the controller and 1 for the view.
- setup_persist_img([:sym...])
- attach_img_to(@record, record_params)
- persist_img(record_params)
- delete_cache
- persisted_img(:sym, 'class', 'style')

detailed explanation below

example of usage
controller
```
class DummyController < ApplicationController
  include ActiveImagePersist # include the gem
  before_action { setup_persist_img [:avatar, association_attributes: :avatar] } # needed for the setup of the gem, must be an array

  def new # or edit
    @record = DummyClass.new
    delete_cache # cache needs to be fresh upon reloading new or edit page, this method will clean up the caches
  end

  def create # or update
    @record.build_association_tag
    @record.assign_attributes(record_params.except(:avatar, association_attributes: :avatar))

    if @record.save
      attach_img_to @record, record_params # this method will attach images persisted by the cache or an image files that have just been uploaded
      redirect_to record_path(@record.id)
    else
      persist_img record_params # this method will persist the image files upon validation error, by saving it into the ActiveStorage
      render 'new'
    end
  end

  def record_params
    params.require(:record).permit(:dummy_attribute, :avatar, association_attributes: [:dummy_attribute, :avatar])
  end
end
```

view(slim ver)
this is just my way to show the images, original if attached, cache if persisted
```
- if persisted_img(:avatar)
    = persisted_img(:avatar, 'dummy-class', 'height: 250px')
- else
    = image_tag @record.avatar, style: 'height: 250px' if @record.avatar.attached?
```
and for association *up to 1 level only
```
- if persisted_img({association_attributes: :avatar})
    = persisted_img({association_attributes: :avatar}, 'dummy-class', 'height: 250px')
- else
    = image_tag @record.association.avatar, style: 'height: 250px' if @record.association.avatar.attached?
```

IMPORTANT: the persisted files stored in the ActiveStorage will not be purged by itself, you might need to use whenever to set up a cron task to delete unassociated ActiveStorage's blobs like so

```
unassociated_blob_ids = ActiveStorage::Blob.all.select{|e| e.attachments.blank? }.pluck(:id)
ActiveStorage::Blob.where(id: unassociated_blob_ids).each {|e| e.purge }
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gengosha/active_image_persist. This project is intended to be a safe, welcoming space for collaboration.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
