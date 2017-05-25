module External
  extend self

  @objects = ['a', 'b', 'c']

  def empty
    @objects.empty?
  end

  def get_next_element
    @objects.shift
  end
end