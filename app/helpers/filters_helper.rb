module FiltersHelper
  def filter_button_id(value, name)
    "#{name}_filter--#{value}"
  end

  def filter_buttons(filter, **)
    filter.to_h.map do |kind, object|
      filter_button_from kind, object, **
    end.join.html_safe
  end

  def filter_button_tag(display:, value:, name:, **options)
    tag.button id: filter_button_id(value, name), class: [ "btn txt-small btn--remove", options.delete(:class) ], data: { action: "filter-form#removeFilter form#submit" } do
      concat hidden_field_tag(name, value, id: nil)
      concat tag.span(display)
      concat image_tag("close.svg", aria: { hidden: true }, size: 24)
    end
  end

  def button_to_filter(text, kind:, object:, data: {})
    if object
      button_to text, filter_buttons_path, method: :post, class: "btn btn--plain", params: filter_attrs(kind, object), data: data
    else
      button_tag text, type: :button, class: "btn btn--plain", data: data
    end
  end

  private
    def filter_button_from(kind, object, **)
      if object.respond_to? :map
        safe_join object.map { |o| filter_button_tag(**filter_attrs(kind, o), **) }
      else
        filter_button_tag(**filter_attrs(kind, object), **)
      end
    end

    def filter_attrs(kind, object)
      case kind&.to_sym
      when :tags
        [ object.hashtag, object.id, "tag_ids[]" ]
      when :buckets
        [ "in #{object.name}", object.id, "bucket_ids[]" ]
      when :assignees
        [ "for #{object.name}", object.id, "assignee_ids[]" ]
      when :assigners
        [ "by #{object.name}", object.id, "assigner_ids[]" ]
      when :indexed_by
        [ object.humanize, object, "indexed_by" ]
      when :assignments
        [ object.humanize, object, "assignments" ]
      end.then do |display, value, name|
        { display: display, value: value, name: name }
      end
    end
end
