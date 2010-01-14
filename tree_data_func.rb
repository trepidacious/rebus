require 'gtk2'

# Add three columns to the GtkTreeView. All three of the
# columns will be displayed as text, although one is a boolean
# value and another is an integer.
def setup_tree_view(treeview)
  # Create a new GtkCellRendererText, add it to the tree
  # view column and append the column to the tree view.
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Buy", renderer, "text" => $buy_index)
  treeview.append_column(column)

  
  renderer = Gtk::CellRendererText.new
  column = Gtk::TreeViewColumn.new("Count", renderer, "text" => $qty_index)
  renderer.editable = true
  renderer.signal_connect('edited') do |w, s1, s2 |
    cell_edited(s1, s2, treeview, $qty_index)
  end
  treeview.append_column(column)

  #  Setup the third column in the tree view to be editable.
  renderer = Gtk::CellRendererTextText.new
  renderer.editable = true
  renderer.signal_connect('edited') do |w, s1, s2 |
    cell_edited(s1, s2, treeview, $prod_index)
  end
  column = Gtk::TreeViewColumn.new("Product", renderer, "text" => $prod_index)
  treeview.append_column(column)
end

# Apply the changed text to the cell.
def cell_edited(path, str, trvu, column_index)
  if str != ""
    puts "Edited to #{str} at #{path}"
    iter = trvu.model.get_iter(path)
    if column_index == $qty_index
      begin
        iter[column_index] = Integer(str)
      rescue
        puts "Invalid integer #{str}"
      end
    elsif column_index == $prod_index
      iter[column_index] = str
    end  
  end
end

window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.resizable = true
window.title = "Grocery List"
window.border_width = 10
window.signal_connect('delete_event') { Gtk.main_quit }
window.set_size_request(275, 300)

class GroceryItem
  attr_accessor :product_type, :buy, :quantity, :product
  def initialize(t,b,q,p)
    @product_type, @buy, @quantity, @product = t, b, q, p
  end
end
$buy_index = 0; $qty_index = 1; $prod_index = 2
$p_category = 0; $p_child = 1

list = Array.new
list[0] = GroceryItem.new($p_category, true,  0, "Cleaning Supplies")
list[1] = GroceryItem.new($p_child,    true,  1, "Paper Towels")
list[2] = GroceryItem.new($p_child,    true,  3, "Toilet Paper")
list[3] = GroceryItem.new($p_category, true,  0, "Food")
list[4] = GroceryItem.new($p_child,    true,  2, "Bread")
list[5] = GroceryItem.new($p_child,    false, 1, "Butter")
list[6] = GroceryItem.new($p_child,    true,  1, "Milk")
list[7] = GroceryItem.new($p_child,    false, 3, "Chips")
list[8] = GroceryItem.new($p_child,    true,  4, "Soda")

treeview = Gtk::TreeView.new
setup_tree_view(treeview)

# Create a new tree model with three columns, as Boolean, 
# integer and string.
store = Gtk::TreeStore.new(TrueClass, Integer, String)

# Avoid creation of iterators on every iteration, since they
# need to provide state information for all iterations. Hence:
# establish closure variables for iterators parent and child.
parent = child = nil

# Add all of the products to the GtkListStore.
list.each_with_index do |e, i|

  # If the product type is a category, count the quantity
  # of all of the products in the category that are going
  # to be bought.
  if (e.product_type == $p_category)
    j = i + 1

    # Calculate how many products will be bought in
    # the category.
    while j < list.size && list[j].product_type != $p_category
      list[i].quantity += list[j].quantity if list[j].buy
      j += 1
    end

    # Add the category as a new root (parent) row (element).
    parent = store.append(nil)
    # store.set_value(parent, $buy_index, list[i].buy) # <= same as below
    parent[$buy_index]  = list[i].buy
    parent[$qty_index]  = list[i].quantity
    parent[$prod_index] = list[i].product

  # Otherwise, add the product as a child row of the category.
  else
    child = store.append(parent)
    # store.set_value(child, $buy_index, list[i].buy) # <= same as below
    child[$buy_index]  = list[i].buy
    child[$qty_index]  = list[i].quantity
    child[$prod_index] = list[i].product
  end
end

# Add the tree model to the tree view
treeview.model = store
treeview.expand_all

scrolled_win = Gtk::ScrolledWindow.new
scrolled_win.add(treeview)
scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
window.add(scrolled_win)
window.show_all
Gtk.main