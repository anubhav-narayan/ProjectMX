'''
MX Device Template
'''

cdef class MXDEV(dict):
    cpdef public MEM

    def __init__(self):
        pass

    def __setitem__(self, addr:int, data:int):
        return

    def __getitem__(self, addr:int):
        return

    def __repr__(self):
        return self.MEM

    def __len__(self):
        return len(self.MEM)

    def __delitem__(self, addr:int):
        return

    def clear(self):
        return self.__init__()

    def copy(self):
        return self.MEM.copy()

    def __cmp__(self, dict_:MXDEV):
        return self.__cmp__(self.MEM, dict_)

    def __iter__(self):
        return iter(self.MEM)
