# Skip ahead for the local code.

# From the website (i.e.: Not actually in this codebase, but I need to think
# about it):

# The website would periodically request harvests from the repository:
repository = RepositoryApi.new
per_page = 1000
deltas = {}
types = [:names, :nodes, :concepts, :media, :etc]
actions = [:create, :update, :delete]
# TODO: first we need to communicate which resources are available, so we get new resources,
resources = repository.diffs_since?(RepositorySync.last.created_at)
resources.each do |resource|
  repository.resource_diffs_since?(resource, RepositorySync.last.created_at).each do |diff|
    # { resource_id: 345, deltas: { names: { create: 10000, update: 12,
    # delete: 0}, nodes: { create: 100, update: 0, delete: 10}, etc }
    types.each do |type|
      actions.each do |action|
        next unless diff[:deltas][type][action] &&
                    diff[:deltas][type][action] > 0
        page = 1
        have = 0
        # TODO: protect against infinite loop (if we stop getting results):
        while have < diff[:deltas][type][action]
          # { nodes: { create: [ {id: 123, name: "Foo bar", etc}, {etc} ] } }
          response = repository.get_diff_deltas(resource_id: resource.id,
            since: RepositorySync.last.created_at, type: type, page: page,
            per_page: per_page)
          # TODO: error-handling
          response[type].each do |action, items|
            deltas[type][action] ||= []
            deltas[type][action] += items
          end
          have += response.size
        end
      end
    end
  end
  types.each do |type|
    actions.each do |action|
      # I didn't sketch out these actions. Some of them would be moderately
      # complex, since they need to denormalize things, and the :media type
      # would be broken up into subtypes, etc...
      call(:"bulk_#{action}", deltas[type][action])
    end
  end
end

# The website might want to know the history of a particular object:
node = Node.last
response = repository.history_of(node)
# { klass: "Node", id: 123, versions: [{ on: "2015-12-01 10:09:01 +0000", name:
# "Foo baricus", etc: "etc"}, { on: "2016-04-19 20:49:14 +0000", name: "Foo
# bar", etc: "etc"}] } NOTE - versions[0] will have all attributes;
# versions[1..-1] will have only attributes that have changed from their
# previous state, like a set of diffs. TODO: this MIGHT need pagination, but I
# would hold off on that until we need it.

#
# LOCAL CODE
#

# Harvest workflow:
# TODO: rename validate to normalize
#   download resource file -> validate -> diff -> download media (parallel) -> merging

some_kind_of_cron_thing(:hourly) do
  Resource.enqueue_pending_harvests
end

class ResourceDownloadWorker
  @queue = "downloads"
  def self.enqueue(resource)
    Resqueue.enqueue(self, resource_id: resource.id)
  end

  def perform(resource_id)
    resource = Resource.find(resource_id)
    begin
      resource.download
      ValidationWorker.enqueue(resource)
    rescue Eol::RemoteFileMissing => e
      # email watchers
    rescue Eol::InvalidFileFormat => e
      # etc...
    end
  end
end

class ValidationWorker
  @queue = "harvesting"
  def self.enqueue(resource)
    Resqueue.enqueue(self, resource_id: resource.id)
  end

  def perform(resource_id)
    resource = Resource.find(resource_id)
    begin
      resource.validate
      DiffWorker.enqueue(resource)
    rescue Eol::ValidationError => e
      # Email watchers
    end
  end
end

class DiffWorker
  @queue = "harvesting"
  def self.enqueue(resource)
    Resqueue.enqueue(self, resource_id: resource.id)
  end

  def perform(resource_id)
    resource = Resource.find(resource_id)
    begin
      diff = Diff.resource(resource)
      MediaDownloadWorker.enqueue(diff)
    rescue Eol::DiffError => e
      # Email watchers
    end
  end
end

class MediaDownloadWorker
  @queue = "downloads"
  def self.enqueue(diff)
    Resqueue.enqueue(self, diff_id: diff.id)
  end

  def perform(diff_id)
    diff = Diff.find(diff_id)
    begin
      diff.download_media
    rescue Eol::RemoteFileMissing => e
      # email watchers
    rescue Eol::InvalidFileFormat => e
      # etc...
    end
  end
end

class Resource < AR::B
  # validated_file:string
  has_many :diffs
  scope :pending_harvest { where("complex query here") }
  def self.enqueue_pending_harvests
    Resource.pending_harvest.each { |resource| resource.enqueue_download }
  end

  def download
    # NOTE Actually belongs in its own class.
    # look for the file online
    # fetch it if it needs refreshing
    # unzip it if needed
    # log errors & raise exceptions if invalid, missing, etc...
  end

  def validate
    # NOTE Actually belongs in its own class.
    # Check the file format
    # Check that the fields match expected fields
    # Check for obvious problems in the data (many of these), for example:
      # Unused IDs
      # Missing IDs
      # Illegal characters
      # Illegal values (wrong types, unknown URIs)
      # Etc...
    # log errors (ValidationLog) for all problems (many of these).
    # Raise exceptions for critical problems

    # Store normalized, validated, SORTED files in VERY STRICTLY formatted JSON,
    # in a very simplified form such that each line of the file tells you
    # everything you need to know about it (i.e.: the whole file should just be
    # one long JSON array). We want to be able to diff these. Lines might look
    # like this (missing fields should be blank, like in
    # "normalized_resource.json" here in the docs folder (q.v.).):
  end
end

# TODO: change this. We need to store all versions of everything, so we should
# probably just use a "current" flag on each table and only read the most recent
# things with that flag set. Oh well.

# This is just a log of what was diffed when; something to hang deltas off of.
class Diff < AR::B
  # status:string, error:text
  belongs_to :resource
  has_many :deltas
  enum status: [ :running, :success, :failure ]
  def self.resource(resource)
    Resource::Differ.diff(resource)
  end

  def failed(message)
    update_attributes(status: :failure, error: message)
  end

  def succeeded
    update_attribute(:status, :success)
  end

  def download_media
    # TODO: does this actually happen separately, or should it just be part of
    #   the diff process? Not critical to decide now, but something to think
    #   about.
    # NOTE Actually belongs in its own class.
    # use a DeltaChecker class to find the new media
    # look for the files online
    # unzip them if needed
    # Rename files approriately (not sure yet what that is)
    # Store filename in DB (media_downloads id:integer, resource_id:integer,
    #   identifier:string, filename:string, w:integer, h:integer, timestamps)
    # make all thumbnails if needed
    # log errors if invalid, missing, etc...
    # raise an exception if there were errors
  end
end

# VERY simple table to simply point to things that changed, and how they changed
# (but not specifically; you would look that up if needed).
class Delta < AR::B
  belongs_to :diff
  belongs_to :parent, polymorphic: true
  enum action: [ :create, :update, :delete ]
end

class Resource::Differ
  def self.diff(resource)
    new(resource).diff
  end

  def initialize(resource)
    @resource = resource
  end

  def diff
    previous = @resource.diffs.last
    @diff = Diff.create(resouce: @resource, status: :running)
    vfile = JSON.parse(@resource.validated_file) # or something...
    begin
      new_names = []
      updated_names = []
      vfile[:names].each do |name|
        if old = Name.where(resource_id: @resource.id, string: name[:string],
                            language: name[:language])
          old.update_from_file(name)
          updated_names << old if old.changed?
        else
          new_names << name
        end
      end
      bulk_insert_deltas(:update, updated_names)
      diff_hashes(Name, new_names)
      archive_missing_names

      vfile.nodes.each do |node|
        update_node(node) if node_needs_update?(node)
        create_node(node) if node_needs_create?(node)
        denormalize_hierarchy
        # We DON'T do this as we go, because we need to study the hierarchy,
        # first:
      end
      archive_missing_nodes
      assign_concepts
      vfile.media.each do |medium|
        # NOTE that these will reference @media to pull the latest location...
        update_medium(doc) if medium_needs_update?(doc)
        create_medium(doc) if medium_needs_create?(doc)
      end
      archive_missing_media
      vfile.traits.each do |trait|
        update_trait(trait) if trait_needs_update?(trait)
        create_trait(trait) if trait_needs_create?(trait)
      end
      archive_missing_traits
      # Etc... any more types that need handling...
    rescue => e # TODO
      @diff.failed(e.message)
    end
    # Etc: synonyms, names, references, and anything else we add...
    @diff.succeeded
    @diff
  end

  # Assumes you're diffing only one type of item.
  def bulk_insert_deltas(action, items)
    pt = items.first.class.name
    iid = @diff.id
    items.map! { |item| [action, pt, item.id, iid] }
    items.unshift([:action, :parent_type, :parent_id, :diff_id])
    Delta.diff(items)
  end

  def diff_hashes(klass, items)
    fields = Set.new
    values = []
    # Must scan all items to get all fields FIRST, sigh:
    items.each { |item| fields += items.keys }
    values << fields
    items.each { |item| values << fields.map { |f| item[f] } }
    # This assumes we're using https://github.com/zdennis/activerecord-diff
    klass.send(:diff, values)
  end
end
