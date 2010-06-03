class Hash
  # {'foo' => {:bar => 'baz'}}.find_nested('foo.bar') => 'baz'
  def find_nested(keys)
    value = self
    keys.split('.').each do |key|
      value = value[key] || value[key.to_sym]
    end
    
    value
  end
end
