# frozen_string_literal: true

module Spina
  module Conferences
    module PrimerTheme
      # Helper for computing asset sources
      module AssetHelper
        def srcset(image, **options)
          return if image.blank?

          options = options.symbolize_keys
          variant_options = options.delete(:variant)
          return if variant_options.blank?

          factors = options.delete(:factors) || DEFAULT_FACTORS
          variants_for image, variant_options: variant_options, factors: factors
        end

        def srcset_string(image, **options)
          srcset(image, **options).collect { |key, value| "#{key} #{value}" }
                                  .join(', ')
        end

        private

        METHODS_TO_RESIZE = %i[resize_to_limit resize_to_fit resize_to_fill resize_and_pad].freeze
        DEFAULT_FACTORS = [1, 2, 3, 4].freeze

        def variants_for(image, variant_options:, factors:)
          factors.inject({}) do |srcset, factor|
            srcset.update(variant_url(image, variant_options, factor) => "#{factor}x")
          end
        end

        def variant_url(image, variant_options, factor)
          main_app.url_for(image.variant(resize_options(variant_options, factor)))
        end

        def resize_options(variant_options, factor)
          variant_options.to_h { |key, value| [key, resize_dimensions_for_key(key, factor, value)] }
        end

        def resize_dimensions_for_key(key, factor, dimensions)
          if METHODS_TO_RESIZE.include?(key)
            dimensions.collect do |dimension|
              resize_dimension(dimension, factor)
            end
          else
            dimensions
          end
        end

        def resize_dimension(dimension = 0, factor = 0)
          factor * dimension
        end
      end
    end
  end
end
