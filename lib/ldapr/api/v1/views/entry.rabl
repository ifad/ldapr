object @entry

node(false) do |entry|
  entry.attribute_names.each do |attr_name|
    next if [:objectguid, :objectsid, "msrtcsip-userenabled"].include?(attr_name)

    node(attr_name) do |entry|
      value = entry.send(attr_name)
      value = value.respond_to?(:join) ? value.join(", ") : value

      value.force_encoding("ISO-8859-1")
    end
  end
end
