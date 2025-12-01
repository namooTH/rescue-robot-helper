## A C++-style priority_queue implementation with support for custom comparators.
##
## To create a min-heap, provide a comparator that returns true when the first element is greater than the second, and vice versa.
class_name priority_queue

var _Heap :Array = [];
var _cmp :Callable;
var _size: int;

func _init(compare):
	if compare == null:
		_cmp = func(a,b): return a<b;
	else:
		_cmp = compare;

## Return the highest priority element.
func top():
	return _Heap[0];
		
## Add an element to the Priority Queue.
func push(element):
	_Heap.append(element);
	_size = _Heap.size(); 
	_fix_up(_size-1);
	
## Remove the highest priority element.
func pop():
	_Heap[0] = _Heap[_size-1];
	_size -= 1;
	_fix_down(0);

## Return size of Priority Queue.
func size():
	return _size;
	
## Check if the Priority Queue is empty. 
func empty():
	return _size == 0;

func _fix_up(i: int) -> void:
	var tmp = _Heap[i];
	while i>0:
		var parent := (i-1)/2;
		if (_cmp.call(tmp, _Heap[parent])):
			break;
		_Heap[i] = _Heap[parent];
		i = parent;
	_Heap[i] = tmp;

func _fix_down(i: int) -> void:
	var tmp = _Heap[i];
	var child :int;
	while true:
		child = 2*i+1;
		if child >= _size: break;
		if child+1 < _size && _cmp.call(_Heap[child],_Heap[child+1]):
			child += 1;
		
		if _cmp.call(_Heap[child],tmp): break;
		_Heap[i] = _Heap[child];
		i = child;
	_Heap[i] = tmp
