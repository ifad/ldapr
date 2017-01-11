object @entry

node(false) do |entry|
  entry.attribute_names.each do |attr_name|
    node(attr_name) do |entry|
      value = entry.send(attr_name)
      value = value.respond_to?(:join) ? value.join(", ") : value

      value.encoding == Encoding::BINARY ? Base64.encode64(value) : value
    end
  end
end
