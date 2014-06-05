from abc import ABCMeta, abstractment, abstractproperty
class Stackable:
	__metaclass__ = ABCMeta
	@abstractmethod
	def push(self, item):
		pass
	@abstractmethod
	def pop(self):
		pass
	@abstractproperty
	def size(self):
		return len(self.items)
