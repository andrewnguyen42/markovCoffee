class Node

  def initialize(text)
    @text=text
    @adjacency_list=Array.new

  end

  def text
    return @text
  end

  def text=(text)
    @text = text
  end

  def adjacency_list
    return @adjacency_list
  end

  #we have a DAG
  def build_link(node)
  	@adjacency_list.push(node)
  end

end
