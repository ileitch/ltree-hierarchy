module Ltree
  module Hierarchy
    def has_ltree_hierarchy
      belongs_to :parent, :class_name => self.name

      scope :roots, where(:parent_id => nil)

      validate :prevent_circular_paths, :if => :parent_id_changed?

      after_create  :commit_path
      before_update :assign_path, :cascade_path_change, :if => :parent_id_changed?

      include InstanceMethods
    end

    module InstanceMethods
      def prevent_circular_paths
        if parent && parent.path.split('.').include?(id.to_s)
          errors.add(:parent_id, :invalid)
        end
      end

      def ltree_scope
        self.class.base_class
      end

      def compute_path
        if parent
          "#{parent.path}.#{id}"
        else
          id.to_s
        end
      end

      def assign_path
        self.path = compute_path
      end

      def commit_path
        update_column(:path, compute_path)
      end

      def cascade_path_change
        # Equivalent to:
        #  UPDATE whatever
        #  SET    path = NEW.path || subpath(path, NLEVEL(OLD.path))
        #  WHERE  path <@ OLD.path AND id != NEW.id;
        ltree_scope.update_all(
          ['path = :new_path || subpath(path, NLEVEL(:old_path))', :new_path => path, :old_path => path_was],
          ['path <@ :old_path AND id != :id', :old_path => path_was, :id => id]
        )
      end

      def root?
        parent_id.nil?
      end

      def ancestors
        ltree_scope.where('path @> ? AND id != ?', path, id)
      end

      def and_ancestors
        ltree_scope.where('path @> ?', path)
      end

      def siblings
        ltree_scope.where('parent_id = ? AND id != ?', parent_id, id)
      end

      def and_siblings
        ltree_scope.where('parent_id = ?', parent_id)
      end

      def descendents
        ltree_scope.where('path <@ ? AND id != ?', path, id)
      end

      def and_descendents
        ltree_scope.where('path <@ ?', path)
      end

      def children
        ltree_scope.where('parent_id = ?', id)
      end

      def and_children
        ltree_scope.where('id = :id OR parent_id = :id', :id => id)
      end
    end
  end
end
