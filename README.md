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

example of usage
controller
```
class DummyController < ApplicationController
  include ActiveImagePersist
  before_action { setup_persist_img [:avatar, association_attributes: :avatar] } # needed for the setup of the gem, must be an array

  def new // or edit
    @record = DummyClass.new
    delete_cache # cache needs to be fresh upon reloading new or edit page, this method will clean up the caches
  end

  def create // or update
    @record.build_association_tag
    @record.assign_attributes(attributes.except(:avatar, association_attributes: :avatar))

    if @record.save
      attach_img_to @record, record_params # this method will attach images persisted by the cache or an image files that have just been uploaded
      redirect_to tcadmin_record_path(@record.id)
    else
      persist_img record_params # this method will persist the image files upon validation error, by saving it into the ActiveStorage
      render 'new'
    end
  end

  private
  def set_record
    @record = DummyClass.find(params[:id])
  end

  def record_params
    params.require(:record).permit(:dummy_attribute, :avatar, association_attributes: [:dummy_attribute, :avatar])
  end
end
```

view(slim ver)
this is just my way to show the images, original if attached, cache if persisted
```
...
- if persisted_img(:avatar, 'dummy-class', 'height: 250px')
    = persisted_img(:avatar, 'dummy-class', 'height: 250px')
- else
    = image_tag @record.avatar, style: 'height: 250px' if @record.avatar.attached?
```
and for association *up to 1 level only
```
- if persisted_img({association_attributes: :avatar}, 'dummy-class', 'height: 250px')
    = persisted_img({association_attributes: :avatar}, 'dummy-class', 'height: 250px')
- else
    = image_tag @record.association.avatar, style: 'height: 250px' if @record.association.avatar.attached?
```

IMPORTANT: the persisted files stored in the ActiveStorage will not be purged by itself, you might need to use whenever to set up a cron task to delete unassociated ActiveStorage's blobs
## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wonghockchuansugianto/active_image_persist. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/active_image_persist/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveImagePersist project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/active_image_persist/blob/master/CODE_OF_CONDUCT.md).
