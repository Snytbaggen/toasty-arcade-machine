extends ItemList

func _ready():
	self.select(0)

func _on_item_selected(index):
	self.get_item_icon(0)
