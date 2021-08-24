from setuptools import setup
from Cython.Build import cythonize

setup(
	name="MX11_ALU",
	ext_modules=cythonize(
		['MX11_ALU.pyx', 'CACHE.pyx', 'MX11.pyx', 'MXDEV.pyx', 'TEST_ROM.pyx'],
		compiler_directives={'language_level': '3'}
	)
)