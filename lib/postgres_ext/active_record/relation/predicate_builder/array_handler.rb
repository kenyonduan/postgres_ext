require 'active_record/relation/predicate_builder'
require 'active_record/relation/predicate_builder/array_handler'
require 'active_support/core_ext/module/aliasing'

module ActiveRecord
  class PredicateBuilder
    module ArrayHandlerPatch
      def call(attribute, value)
        column = case attribute.try(:relation)
                 when Arel::Nodes::TableAlias, NilClass
                 else
                   cache = ActiveRecord::Base.connection.schema_cache
                   if cache.table_exists? attribute.relation.name
                     cache.columns(attribute.relation.name).detect{ |col| col.name.to_s == attribute.name.to_s }
                   end
                 end
        if column && column.respond_to?(:array) && column.array
          attribute.eq(value)
        else
          super(attribute, value)
        end
      end
    end
  end
end

ActiveRecord::PredicateBuilder::ArrayHandler.send(:prepend, ActiveRecord::PredicateBuilder::ArrayHandlerPatch)
