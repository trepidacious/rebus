require 'gtk2'

class StringListModel
  
  def initialize(list)
    @list = list
  end
  
  def flags
    Gtk::TreeModel::LIST_ONLY
  end
  
  def n_columns
    @list.size
  end
  
  def get_column_type(index)
    return String
  end
  
  def iter_first
    if @list.empty?
      nil
    else
      
    end
  end
  
end

if __FILE__ == $0
  model = StringListModel.new ["a","b","c"]
  puts model.n_columns
  puts model.get_column_type 0
  puts "Hello"
end
