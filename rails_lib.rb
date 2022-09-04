#modifications for Rails

HIDE = "display:none;".freeze
FLOATRIGHT = "float:right;".freeze
BLOCK = {style: "display:block"}.freeze

Routes = Rails.application.routes.url_helpers
Helpers = ActionController::Base.helpers
#@default_logger = ActiveRecord::Base.logger #for some reason this is nil at this point

module Kernel
  def timelog msg
    Rails.logger.info("#{Time.now}: #{msg}")
  end

  def toggle_log
    @default_logger ||= ActiveRecord::Base.logger
    ActiveRecord::Base.logger = if ActiveRecord::Base.logger
                                  nil
                                else
                                  @default_logger
                                end
  end

  def r
    reload!
  end

  def truthy param
    param == "true"
  end

  def checked? param
    param == "1"
  end

  def auto_upgrade_all! #for use with mini_record
    #.models currently includes SchemaMigration but mini_record now skips it so it doesn't matter
    ActiveRecord::Base.models.map(&:auto_upgrade!)
  end

  def external_link text, url, **args
    #need in controller
    Helpers.link_to(text, url, args.merge(target: :_blank))
  end
end

module Lib
  class << self
    def scrypt_with_salt secret, salt
      SCrypt::Engine.hash_secret(secret, salt)
    end

    def scrypt secret, **opts
      SCrypt::Password.create(secret, **opts)
    end

    def scrypt_from_hash hash
      SCrypt::Password.new(hash)
    end

    def random_code len=20
      SecureRandom.alphanumeric(len)
    end

    def backendify_value val
      if val.is_a?(ActiveRecord::Base)
        val.id
      else
        val #should be string/integer/Boolean/etc.
      end
    end

    def backendify hash
      hash.transform_values {|v| backendify_value(v)}
    end
  end
end

class ActiveRecord::Base
  class << self
    #alias [] find
    def [](spec)
      norm = find_by_id(spec)
      return norm if norm

      _naming_attrs.each do |attr|
        if res = find_by(attr => spec)
          return res
        end
      end
      raise ActiveRecord::RecordNotFound
    end

    def _naming_attrs
      [:name]
    end

    def find_by_last *args, **kwargs
      where(*args, **kwargs).last
    end
  end

  def self.nth(n)
    #very inefficient!
    first(n + 1).last
  end

  def self.nth(n)
    #if you don't specify order, the order will NOT be by id or anything sensical
    order(:id).offset(n).limit(1).first
  end

  def self.second
    nth(1)
  end

  def self.third
    nth(2)
  end

  #def self.random q
  #  #returns q unique(!) random records
  #  (0..q).map {
  #end

  def self.models(include_habtm: false)
    #"This makes sure all models in your application, regardless of where they are, are loaded, and any gems you are using which provide models are also loaded."
    Rails.application.eager_load!
    ms = ActiveRecord::Base.descendants
    ms.delete(ActiveRecord::SchemaMigration) if defined?(ActiveRecord::SchemaMigration)
    include_habtm ? ms : ms.reject {|kls| kls.name.starts_with?("HABTM")}
  end

  def self.invalids
    bad = []
    find_each {|u| bad << u if !u.valid?}
    bad
  end

  def upd *args
    update(*args)
  end

  def self.slap
    all.slap
  end
end

class ActiveRecord::Relation
  def slap
    #quickly prints all items
    find_each {|x| p x}
    nil
  end
end
