class Node < ActiveRecord::Base
  belongs_to :resource, inverse_of: :nodes
  # TODO belongs_to :page, inverse_of: :nodes
  belongs_to :parent, class_name: "Node", inverse_of: :children
  belongs_to :scientific_name, inverse_of: :nodes

  has_many :scientific_names, inverse_of: :node
  has_many :media, inverse_of: :node
  has_many :children, class_name: "Node", inverse_of: :parent,
    foreign_key: "parent_id"
end
