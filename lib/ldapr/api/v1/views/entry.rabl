object @entry

node(false) do |entry|
  entry.attribute_names.each do |attr_name|
    next if [:objectguid, :objectsid].include?(attr_name)

    node(attr_name) do |entry|
      value = entry.send(attr_name)
      value.respond_to?(:join) ? value.join(", ") : value
    end
  end
end
