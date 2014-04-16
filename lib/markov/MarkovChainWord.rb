require_relative './Node'

#a word-level marko chain generator
class MarkovChainWord


  def initialize(text,order)
    @built_text=""
    @nodes={}
    @random=Random.new
    @order=order
    @text=text
    build_chain(text,order)
  end

  def nodes
    @nodes
  end

  def generate(n)
    n= n.to_i>= @order ? n.to_i : @order 
    nodes = @nodes.values
    current_text=nodes.sample.text
    @built_text<<current_text[0]+" "

    for i in 0..n-2
      current_text=next_state(current_text)
    end
  end

  #add a transition from w to v
  def add_transition(w,v)
    @nodes[w.text].build_link(@nodes[v.text])
  end

  #randomly get the next transition for a state
  def next_state(v)
    node=@nodes[v]
    next_text=node.adjacency_list.sample.text
    @built_text<<next_text[0]+" "
    return next_text

  end

  def to_string
    @built_text
  end


  def build_chain(text,order)

    words=text.split(' ')
    offset=0

    #so that we have something circular
    for i in 0..@order
      words.push(words[i])
      offset+=1
    end


    for i in 0..words.size-@order-2
      current_text= words[i,order]
      next_text= words[i+1,order]

      current_node=@nodes[current_text]
      if current_node.nil?
        current_node=Node.new(current_text)
      end

      next_node=@nodes[next_text]
      if next_node.nil?
        next_node=Node.new(next_text)
        @nodes[next_text]=next_node
      end
      @nodes[current_text]=current_node
      add_transition(current_node,next_node)


    end

  end

  private :build_chain


end
